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


  def self.with_last_measure_for_human(human_id, birthdate, gender)
    # 1. Build ActiveRecord collection of measures
    base_query = joins(measures: {source: :human}) # Inner joins from biomarkers <- measures <- source <- human
    .left_joins(:biomarkers_ranges, :unit_factors, :synonyms, measures: :unit)
    .includes(:biomarkers_ranges, :synonyms, :unit_factors, measures: :unit) # unit is included through measures
    .where(sources: {human_id: human_id})
    .where("unit_factors.biomarker_id = measures.biomarker_id")
    .where("unit_factors.unit_id = measures.unit_id")
    .where("biomarkers_ranges.age = FLOOR(DATE_PART('year', AGE(DATE(measures.date), ?)))", birthdate)
    .where("biomarkers_ranges.gender = ?", gender)
    .where("synonyms.language = 'PT'")
    # When you use .select(...) explicitly, ActiveRecord only includes the specified columns.
    .select('DISTINCT ON (measures.biomarker_id) measures.*, biomarkers.name, synonyms.name AS synonym_name, units.name AS unit_name, units.value_type AS unit_value_type,'\
    'biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_original_value_possible_min_value, '\
    'biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_original_value_possible_max_value')
    .order('measures.biomarker_id, measures.date DESC')

    # 2. Order collection by synonym or name, structure the data with all select selection and not just AR defult class and transform strings into symbols as keys.
    base_query = sort_by_synonym_or_name(base_query.map(&:attributes).map(&:symbolize_keys))
    # base_query = sort_by_synonym_or_name(base_query).map(&:attributes).map(&:symbolize_keys)

    # 3. Transform dataset for rendering
    base_query = add_measure_text(base_query).yield_self{ |query| add_measure_status(query) }

    return base_query
  end

  def self.search_for_human(human_id, birthdate, gender, query)
    base_query = joins(measures: {source: :human}) # Inner joins from biomarkers <- measures <- source <- human
    .left_joins(:biomarkers_ranges, :unit_factors, :synonyms, measures: :unit)
    .includes(:biomarkers_ranges, :synonyms, :unit_factors, measures: :unit) # unit is included through measures
    .where(sources: {human_id: human_id})
    .where(
          "(to_tsvector('portuguese', unaccent(synonyms.name)) ||
            to_tsvector('portuguese', unaccent(biomarkers.name))) @@
            to_tsquery('portuguese', unaccent(:query))",
          query: query
        )
    .where("unit_factors.biomarker_id = measures.biomarker_id")
    .where("unit_factors.unit_id = measures.unit_id")
    .where("biomarkers_ranges.age = FLOOR(DATE_PART('year', AGE(DATE(measures.date), ?)))", birthdate)
    .where("biomarkers_ranges.gender = ?", gender)
    .where("synonyms.language = 'PT'")
    # When you use .select(...) explicitly, ActiveRecord only includes the specified columns.
    .select('DISTINCT ON (measures.biomarker_id) measures.*, biomarkers.name, synonyms.name AS synonym_name, units.name AS unit_name, units.value_type AS unit_value_type,'\
    'biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_original_value_possible_min_value, '\
    'biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_original_value_possible_max_value')
    .order('measures.biomarker_id, measures.date DESC');

    # 2. Order collection by synonym or name, structure the data with all select selection and not just AR defult class and transform strings into symbols as keys.
    base_query = sort_by_synonym_or_name(base_query.map(&:attributes).map(&:symbolize_keys))

    # 3. Transform dataset for rendering
    base_query = add_measure_text(base_query).yield_self{ |query| add_measure_status(query) }

  end

  # Instance method
  # Return biomarker PT synonym or its name in english
  def title
    synonyms.find_by(language: "PT")&.name || name
  end

  private

  def self.sort_by_synonym_or_name(collection)
    collection.sort_by do |biomarker|
      synonym = biomarker[:synonym_name]
      synonym ? biomarker[:synonym_name] : biomarker[:name]
    end
  end

  # def self.sort_by_synonym_or_name(collection)
  #   collection.sort_by do |biomarker|
  #     synonym = biomarker.synonyms.detect { |s| s.language == "PT" }
  #     synonym ? synonym.name : biomarker.name
  #   end
  # end

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
      if biomarker[:unit_value_type] == 1
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
