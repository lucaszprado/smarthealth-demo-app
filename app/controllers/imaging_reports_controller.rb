class ImagingReportsController < ApplicationController
  def index
    @human = Human.find(params[:human_id])

    # 1. Build ActiveRecord collection
    imaging_reports_collection = ImagingReport
      .joins(source: :human)
      .joins(:imaging_method)
      .where(sources: {human_id: @human.id})
      .includes(:labels)
      .order(date: :desc)

    # 2. Transform ActiveRecord collection in a structured hash
    @imaging_reports = imaging_reports_collection.map do |report|
      {
        id: report.id,
        content: report.content,
        date: report.date,
        imaging_method: report.imaging_method.name,
        labels: report.labels.map { |label| { id: label.id, name: label.name } }
      }
    end
    debugger
  end
end
