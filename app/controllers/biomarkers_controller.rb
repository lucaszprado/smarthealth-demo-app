class BiomarkersController < ApplicationController
  def index
    if params[:query].present?
      @human = Human.find(params[:human_id])
      @last_measures = Measure
        .joins(:source)
        .joins("INNER JOIN humans ON humans.id = sources.human_id")
        .joins(:biomarker)
        .left_joins(biomarker: :synonyms)
        .joins(:unit)
        .left_joins(biomarker: :biomarkers_ranges)
        .left_joins(unit: :unit_factors)
        .where("synonyms.name ILIKE (?) OR biomarkers.name ILIKE (?)", "%#{params[:query]}%", "%#{params[:query]}%")
        .where(sources: {human_id: @human.id})
        .where("unit_factors.biomarker_id = measures.biomarker_id")
        .where("unit_factors.unit_id = measures.unit_id")
        .select('DISTINCT ON (measures.biomarker_id) measures.*,'\
        'COALESCE(biomarkers_ranges.possible_min_value / unit_factors.factor, NULL) AS same_unit_possible_min_value, '\
        'COALESCE(biomarkers_ranges.possible_max_value / unit_factors.factor, NULL) AS same_unit_possible_max_value')
        .order('measures.biomarker_id, measures.date DESC');

      # @last_measures = Measure
      # .select('DISTINCT ON (measures.biomarker_id) measures.*')
      # .joins(:source)
      # .joins(biomarker: :synonyms)
      # .where("synonyms.name ILIKE ?", "%#{params[:query]}%")
      # .where(source: { human_id: @human.id });
    else
      @human = Human.find(params[:human_id])
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
        .select('DISTINCT ON (measures.biomarker_id) measures.*,'\
        'COALESCE(biomarkers_ranges.possible_min_value / unit_factors.factor, NULL) AS same_unit_possible_min_value, '\
        'COALESCE(biomarkers_ranges.possible_max_value / unit_factors.factor, NULL) AS same_unit_possible_max_value')
        .order('measures.biomarker_id, measures.date DESC');

      # @last_measures = Measure
      # .select('DISTINCT ON (measures.biomarker_id) measures.*')
      # .joins(:source)
      # .where(sources: { human_id: @human.id })
      # .order('measures.biomarker_id, measures.date DESC');
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
