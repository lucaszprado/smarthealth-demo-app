class BiomarkersController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    @last_measures = Measure
    .select('DISTINCT ON (measures.biomarker_id) measures.*')
    .joins(:source)
    .where(sources: { human_id: @human.id })
    .order('measures.biomarker_id, measures.date DESC')
  end
end
