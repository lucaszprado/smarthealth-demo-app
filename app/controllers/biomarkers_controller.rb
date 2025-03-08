class BiomarkersController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')



    if params[:query].present?
      search_query = params[:query].split.map {|term| "#{term}:*"}.join(" | ")
      @last_measures = Measure
        .joins(:source)
        .joins("INNER JOIN humans ON humans.id = sources.human_id")
        .joins(:biomarker)
        .left_joins(biomarker: :synonyms)
        .joins(:unit)
        .left_joins(biomarker: :biomarkers_ranges)
        .left_joins(unit: :unit_factors)
        .where(
          "(to_tsvector('portuguese', unaccent(synonyms.name)) ||
            to_tsvector('portuguese', unaccent(biomarkers.name))) @@
            to_tsquery('portuguese', unaccent(:query))",
          query: search_query
        )
        .where(sources: {human_id: @human.id})
        .where("unit_factors.biomarker_id = measures.biomarker_id")
        .where("unit_factors.unit_id = measures.unit_id")
        .where("biomarkers_ranges.age = FLOOR(DATE_PART('year', AGE(measures.date, '#{birthdate}')))")
        .where("biomarkers_ranges.gender = ?", @human.gender)
        .select('DISTINCT ON (measures.biomarker_id) measures.*,'\
        'biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_possible_min_value, '\
        'biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_possible_max_value')
        .order('measures.biomarker_id, measures.date DESC');


    else
      @last_measures = Measure
        .joins(:source)
        .joins("INNER JOIN humans ON humans.id = sources.human_id")
        .joins(:biomarker)
        .joins(:unit)
        .left_joins(biomarker: :biomarkers_ranges)
        .left_joins(unit: :unit_factors)
        .where(sources: {human_id: @human.id})
        .where("unit_factors.biomarker_id = measures.biomarker_id")
        .where("unit_factors.unit_id = measures.unit_id")
        .where("biomarkers_ranges.age = FLOOR(DATE_PART('year', AGE(DATE(measures.date), '#{birthdate}')))")
        .where("biomarkers_ranges.gender = ?", @human.gender)
        .select('DISTINCT ON (measures.biomarker_id) measures.*,'\
        'biomarkers_ranges.possible_min_value / unit_factors.factor AS same_unit_possible_min_value, '\
        'biomarkers_ranges.possible_max_value / unit_factors.factor AS same_unit_possible_max_value')
        .order('measures.biomarker_id, measures.date DESC');
    end

    @last_measures = @last_measures.sort_by do |measure|
      if !measure.biomarker.synonyms.find_by(language: "PT").nil?
        measure.biomarker.synonyms.find_by(language: "PT").name
      else
        measure.biomarker.name
      end
    end
  end
end
