# app/controllers/humans_controller.rb
class HumansController < ApplicationController
  def show
    @human_biomarkers = {}
    human = Human.find(params[:id])
    human.measures.each do |measure|
      biomarker_id = measure.biomarker.id
      biomarker_name = measure.biomarker.name
      biomarker_original_value = measure.original_value
      measure_date = measure.date.strftime("%Y-%m-%d")

      # Initialize the nested hash for the biomarker name if it doesn't exist
      @human_biomarkers[biomarker_id] ||= {}

      # Add the date as key and biomarker name as original value inside the nested hash
      @human_biomarkers[biomarker_id][measure_date] = biomarker_original_value
      @human_biomarkers[biomarker_id] = @human_biomarkers[biomarker_id].sort_by { |key, value| key}.to_h
    end

    # # Step 1: Fetch all sources associated with the human
    # sources = human.sources.includes(measures: :biomarker)

    # # Step 2: Collect all measures from those sources
    # # measures = sources.flat_map(&:measures)
    # debugger
    # # TODO: create a View to render this controller in HTML and not in json
    # # Step 3: Render JSON response
    # render json: {
    #   human: human.as_json(only: [:id, :name]),  # You can include other human attributes as needed
    #   sources: sources.map do |source|
    #     {
    #       source_id: source.id,
    #       measures: source.measures.map do |measure|
    #         {
    #           biomarker: measure.biomarker.name,
    #           value: measure.value,
    #           date: measure.date
    #         }
    #       end
    #     }
    #   end
    # }
  end
end
