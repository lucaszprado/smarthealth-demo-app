class MeasuresController < ApplicationController
  def index
    # New code
    @human_biomarker_measures = {}
    @human = Human.find(params[:human_id])
    @biomarker = Biomarker.find(params[:biomarker_id])
    @measures = @human.measures.where(biomarker: @biomarker)

    if @measures.nil?
      render json: {error: "Measure not found"}, status: :not_found
    end

    @measures.each do |measure|
      biomarker_original_value = measure.original_value
      measure_date = measure.date.strftime("%Y-%m-%d")

      # Initialize the nested hash for the biomarker name if it doesn't exist
      @human_biomarker_measures ||= {}

      # Add the date as key and biomarker name as original value inside the nested hash
      @human_biomarker_measures[measure_date] = biomarker_original_value
      @human_biomarker_measures = @human_biomarker_measures.sort_by { |key, value| key}.to_h
      @human_biomarker_measures_json = @human_biomarker_measures.to_json
      unit = measure.unit
      unit_factor = UnitFactor.find_by(biomarker: @biomarker, unit: unit).factor
      biomarker_range = BiomarkersRange.find_by(biomarker: @biomarker)
      @biomarker_upper_band = biomarker_range.possible_max_value/unit_factor
      @biomarker_lower_band = biomarker_range.possible_min_value/unit_factor
    end
  end
end
