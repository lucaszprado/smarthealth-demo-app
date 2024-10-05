# app/controllers/humans_controller.rb
class HumansController < ApplicationController
  def show
    human = Human.find(params[:id])
    @measures = human.measures

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
