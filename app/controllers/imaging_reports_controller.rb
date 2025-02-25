class ImagingReportsController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    # 1. Build ActiveRecord collection of imaging_reports -> Simillar an array

    if params[:query].present?
      #Pre fixing matching with OR conditions
      search_query = params[:query].split.map {|term| "#{term}:*"}.join(" | ")

      imaging_reports_collection = ImagingReport
        .joins(source: :human)
        .joins(:imaging_method)
        .left_joins(:labels)
        .where(sources: {human_id: @human.id})
        .where(
          "(to_tsvector('portuguese', unaccent(imaging_reports.content)) ||
          to_tsvector('portuguese', unaccent(labels.name)) ||
          to_tsvector('portuguese', unaccent(imaging_methods.name))) @@ to_tsquery('portuguese', unaccent(:query))",
          query: search_query
        )
        .distinct
        .includes(:labels)
        .order(date: :desc)

    elsif
      imaging_reports_collection = ImagingReport
        .joins(source: :human)
        .joins(:imaging_method)
        .where(sources: {human_id: @human.id})
        .includes(:labels)
        .order(date: :desc)
    end

    # Since imaging_reports ActiveRecord collection of ImagingReports, Rails (Ruby specifically) looks for a method inside ImagingReport Class (model)
    # @imaging_reports is an array of hashs
    @imaging_reports = imaging_reports_collection.map(&:structured_data)
    # For @imaging_report debug
    # @imaging_reports = imaging_reports_collection.map do |report|
    #   puts "===================================="
    #   puts "===================================="
    #   report.labels.each {|label| puts label.name}
    #   puts "===================================="
    #   puts "===================================="
    #   report.structured_data
    # end

    respond_to do |format|
      format.html # Follow regular flow of Rails
      format.text { render partial: "imaging_reports/list", locals: {imaging_reports: @imaging_reports}, formats: [:html] }
    end

  end

  def show
    human = Human.find(params[:human_id])
    @imaging_report = ImagingReport.find(params[:id]).structured_data
  end

end
