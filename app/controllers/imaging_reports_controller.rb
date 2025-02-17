class ImagingReportsController < ApplicationController
  def index
    @human = Human.find(params[:human_id])

    # 1. Build ActiveRecord collection of imaging_reports -> Simillar an array
    imaging_reports_collection = ImagingReport
      .joins(source: :human)
      .joins(:imaging_method)
      .where(sources: {human_id: @human.id})
      .includes(:labels)
      .order(date: :desc)

    # Since imaging_reports ActiveRecord collection of ImagingReports, Rails (Ruby specifically) looks for a method inside ImagingReport Class (model)
    # @imaging_reports is an array of hashs
    @imaging_reports = imaging_reports_collection.map(&:structured_data)
  end

  def show
    human = Human.find(params[:human_id])
    @imaging_report = ImagingReport.includes(labels: :parents).find(params[:id]).structured_data
  end

end
