class MeasuresController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    biomarker = Biomarker.find(params[:biomarker_id])

    # Fetch processed data from Measure model
    @measure_data = Measure.process_biomarker_data(@human, biomarker)
  end
end
