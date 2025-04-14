module ImagingReportsHelper
  def render_imaging_reports_partial(imaging_reports)
    if imaging_reports.empty?
      'shared/no_data'
    else
      'imaging_reports/data'
    end
  end
end
