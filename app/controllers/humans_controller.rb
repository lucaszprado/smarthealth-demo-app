# app/controllers/humans_controller.rb
class HumansController < ApplicationController
  def show
    @human_biomarkers = {}
    human = Human.find(params[:id])
    human.measures.each do |measure|
      biomarker_id = measure.biomarker.id
      biomarker_original_value = measure.original_value
      measure_date = measure.date.strftime("%Y-%m-%d")

      # Initialize the nested hash for the biomarker name if it doesn't exist
      @human_biomarkers[biomarker_id] ||= {}

      # Add the date as key and biomarker name as original value inside the nested hash
      @human_biomarkers[biomarker_id][measure_date] = biomarker_original_value
      @human_biomarkers[biomarker_id] = @human_biomarkers[biomarker_id].sort_by { |key, value| key}.to_h
    end
  end
end
