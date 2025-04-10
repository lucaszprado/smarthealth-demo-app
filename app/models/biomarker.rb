class Biomarker < ApplicationRecord
  has_many :synonyms
  has_many :measures
  has_many :biomarkers_ranges
  has_many :unit_factors

  # This class method. It's applied on the class all the time.
  def self.ransackable_associations(auth_object = nil)
    ["synonyms", "measures", "biomarkers_ranges", "unit_factors"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "external_ref", "id", "id_value", "name", "updated_at"]
  end

  # 1. Used in Active Admin filters
  scope :with_distinct_pt_synonyms, -> {
    left_joins(:synonyms) # Brings biomarkers w/ and w/o a synonym.
      .where("synonyms.language = 'PT' OR synonyms.id IS NULL")
      .includes(:synonyms)
      .select("DISTINCT ON (biomarkers.id) biomarkers.*, COALESCE(synonyms.name, biomarkers.name) AS sort_name")
      #.distinct -> distinct without proper control over which row wins can behave unpredictably in SQL
      # Because of it we moved it to the select statement
      .order(Arel.sql("biomarkers.id, COALESCE(synonyms.name, biomarkers.name)"))
      # .order(...) is required by DISTINCT ON, and must start with the same fields used in DISTINCT ON (...)
      # When you use DISTINCT ON (something) in PostgreSQL, the first part of the ORDER BY clause must exactly match the DISTINCT ON fields.
      #
      # Arel.sql tells Rails that it can trust this SQL. No SQL Injection.
      # Arel is a Ruby library used internally by Rails to build SQL queries
      # .oder method doesn't accept parameters, it accepts only column references.
      # Because of that we can't use the placeholder ?
      #
      #.reorder("sort_name")
      #.reorder(...) tells ActiveRecord/PostgreSQL how to actually order the final output
      # However reorder messed up how distinct works -> We need second query just to reorder.
  }

  # This query return a Partial Active Record relation.
  # Because of it it's not defined as a scope.
  def self.with_pt_synonyms_ordered_by_name
    from(with_distinct_pt_synonyms, :biomarkers).order("sort_name")
  end

  # Build ActiveRecord collection of measures with the latest measure per biomarker,
  # Build the Inner Query to select the latest measure per biomarker,
  # human_id: 1
  # birthdate: '1990-01-01'
  # gender: 'M'
  # source_type_names: ['Blood', 'Bioimpedance']
  def self.last_measure_by_source(human_id, birthdate, gender, source_type_names)
    calculated_age_sql = "FLOOR(DATE_PART('year', AGE(DATE(measures.date), ?)))"

    inner_query = joins(measures: {source: :human}) # Inner joins from biomarkers <- measures <- source <- human
      .left_joins(:biomarkers_ranges, :unit_factors, :synonyms, measures: [:unit, source: :source_type])
      .includes(:biomarkers_ranges, :synonyms, :unit_factors, measures: [:unit, source: [:source_type, :health_professional, :health_provider]]) # includes are often best placed on the final query if possible, but might be needed here depending on usage.
      .where(sources: {human_id: human_id})
      .where(source_types: {name: source_type_names})
      .where("(unit_factors.biomarker_id = measures.biomarker_id AND unit_factors.unit_id = measures.unit_id) OR unit_factors.id IS NULL")
      # Allow records even if unit_factor doesn't exist
      .where("(biomarkers_ranges.biomarker_id = biomarkers.id AND biomarkers_ranges.age = #{calculated_age_sql} AND biomarkers_ranges.gender = ?) OR biomarkers_ranges.id IS NULL", birthdate, gender)
      # Allow records even if biomarker_range doesn't exist for the specific age/gender
      #
      # When you use .select(...) explicitly, ActiveRecord only includes the specified columns.
      # Select necessary columns, calculate display_name
      .select(<<~SQL)
        DISTINCT ON (measures.biomarker_id)
        measures.*,
        biomarkers.name,
        CASE WHEN synonyms.language = 'PT' THEN synonyms.name ELSE biomarkers.name END AS display_name,
        units.name AS unit_name,
        units.value_type AS unit_value_type,
        biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_original_value_possible_min_value,
        biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_original_value_possible_max_value,
        source_types.name AS source_type_name
      SQL
      #
      # Order strictly for DISTINCT
      # Order must have the same parameters as DISTINCT ON
      .order(Arel.sql("measures.biomarker_id,
                      measures.date DESC,
                      CASE WHEN synonyms.language = 'PT' THEN 0 ELSE 1 END,
                      synonyms.id DESC"))


    # Build the Outer Query to apply the final sorting on display_name
    # COLLATE \"pt_BR.UTF-8\" to treat Portuguese characters correctly
    # The alias 'biomarkers' allows referring to columns from the inner query.
    final_query = Biomarker.from(inner_query, :biomarkers)
                           .order(Arel.sql("biomarkers.display_name COLLATE \"pt_BR\" ASC"))

    # 3. Structure the data from the final sorted query
    results = final_query.map(&:attributes).map(&:symbolize_keys)

    # 4. Transform dataset for rendering (operates on the Array of Hashes)
    results = add_measure_text(results).yield_self{ |query| add_measure_status(query) }

    return results
  end

  def self.search_last_measure_by_source(human_id, birthdate, gender, query, source_type_names)
    calculated_age_sql = "FLOOR(DATE_PART('year', AGE(DATE(measures.date), ?)))"

    inner_query = joins(measures: {source: :human}) # Inner joins from biomarkers <- measures <- source <- human
      .left_joins(:biomarkers_ranges, :unit_factors, :synonyms, measures: [:unit, source: :source_type])
      .includes(:biomarkers_ranges, :synonyms, :unit_factors, measures: [:unit, source: [:source_type, :health_professional, :health_provider]])
      .where(sources: {human_id: human_id})
      .where(source_types: {name: source_type_names})
      # Allow records even if unit_factor doesn't exist
      .where("(unit_factors.biomarker_id = measures.biomarker_id AND unit_factors.unit_id = measures.unit_id) OR unit_factors.id IS NULL")
      # Allow records even if biomarker_range doesn't exist for the specific age/gender
      .where("(biomarkers_ranges.biomarker_id = biomarkers.id AND biomarkers_ranges.age = #{calculated_age_sql} AND biomarkers_ranges.gender = ?) OR biomarkers_ranges.id IS NULL", birthdate, gender)
      .where(
            "(to_tsvector('portuguese', unaccent(synonyms.name)) ||
              to_tsvector('portuguese', unaccent(biomarkers.name))) @@
              to_tsquery('portuguese', unaccent(:query))",
            query: query
          )
      #
      # When you use .select(...) explicitly, ActiveRecord only includes the specified columns.
      # Select necessary columns, calculate display_name
      .select(<<~SQL)
        DISTINCT ON (measures.biomarker_id)
        measures.*,
        biomarkers.name,
        CASE WHEN synonyms.language = 'PT' THEN synonyms.name ELSE biomarkers.name END AS display_name,
        units.name AS unit_name,
        units.value_type AS unit_value_type,
        biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_original_value_possible_min_value,
        biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_original_value_possible_max_value,
        source_types.name AS source_type_name
      SQL
      # Order strictly for DISTINCT ON correctness
      .order(Arel.sql("measures.biomarker_id,
                      measures.date DESC,
                      CASE WHEN synonyms.language = 'PT' THEN 0 ELSE 1 END,
                      synonyms.id DESC"))

   # 2. Build the Outer Query to apply the final sorting on display_name
    # COLLATE \"pt_BR.UTF-8\" to treat Portuguese characters correctly
    # The alias 'biomarkers' allows referring to columns from the inner query.
    final_query = Biomarker.from(inner_query, :biomarkers)
                           .order(Arel.sql("biomarkers.display_name COLLATE \"pt_BR\" ASC"))

    # 3. Structure the data from the final sorted query
    results = final_query.map(&:attributes).map(&:symbolize_keys)

    # 4. Transform dataset for rendering (operates on the Array of Hashes)
    results = add_measure_text(results).yield_self{ |query| add_measure_status(query) }

    return results
  end

  # Instance method
  # Return biomarker PT synonym or its name in english
  # Used in the measure model
  def title
    synonyms.find_by(language: "PT")&.name || name
  end

  private

  # Removed sort_by_display_name as sorting is now handled by the database
  # def self.sort_by_display_name(collection)
  #   collection.sort_by do |biomarker|
  #     biomarker[:display_name]
  #   end
  # end

  def self.sort_by_synonym_or_name(collection)
    collection.sort_by do |biomarker|
      synonym = biomarker[:synonym_name]
      synonym ? biomarker[:synonym_name] : biomarker[:name]
    end
  end

  def self.add_measure_text(collection)
    collection.each do |biomarker|
      if biomarker[:unit_value_type] == 2
        case biomarker[:value]
        when 0
          biomarker[:measure_text] = "Negativo"
        else 1
          biomarker[:measure_text] = "Positivo"
        end
      else
        biomarker[:measure_text] = ""
      end
    end
  end

  def self.add_measure_status(collection)
    collection.each do |biomarker|
      if biomarker[:unit_value_type] == 1 && !biomarker[:same_unit_original_value_possible_max_value].nil?
        if biomarker[:original_value] > biomarker[:same_unit_original_value_possible_max_value]
          biomarker[:measure_status] = "yellow"
        elsif biomarker[:original_value] < biomarker[:same_unit_original_value_possible_min_value]
          biomarker[:measure_status] = "yellow"
        else
          biomarker[:measure_status] = "green"
        end
      else
        biomarker[:measure_status] = nil
      end
    end
  end

end
