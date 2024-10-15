class MeasuresController < ApplicationController
  def index

    @human = Human.find(params[:human_id])
    @biomarker = Biomarker.find(params[:biomarker_id])
    @measures = @human.measures.where(biomarker: @biomarker)

    if @measures.nil?
      render json: {error: "Measure not found"}, status: :not_found
    end

    @biomarker_measures = {"2024-07-03" => 85, "2024-08-15" => 100, "2024-12-02" => 65, "2024-12-23" => 80, "2025-02-23" => 80}
    @biomarker_measures_json = @biomarker_measures.to_json
    @biomarker_upper_band = 90
    @biomarker_lower_band = 70

  end
end
