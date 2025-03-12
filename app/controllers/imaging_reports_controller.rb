class ImagingReportsController < ApplicationController
  def index
    @human = Human.find(params[:human_id])

    # Get structured data directly from the model
    @imaging_reports = ImagingReport.search_for_human(@human.id, params[:query])

    # Define controller response (normal render vs AJAX response)
    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: "list", locals: {imaging_reports: @imaging_reports, human: @human}, formats: [:html]}
    end

  end

  def show
    @human = Human.find(params[:human_id])
    @imaging_report = ImagingReport.find_structured(params[:id])
  end

end
