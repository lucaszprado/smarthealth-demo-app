module BiomarkersHelper
  # Returns attributes for view partial depending on numeric and non numeric measures
  def result_card_attributes(human, biomarker)
    {
      link: human_biomarker_measures_path(human.id, biomarker[:biomarker_id]),
      icon_path: biomarker[:source_type_name] == "Blood" ? "fa-solid fa-vial" : "fa-solid fa-weight-scale",
      title: biomarker[:display_name],
      key_info: biomarker[:unit_value_type] == 1 ? "#{format_value_2_decimals(biomarker[:original_value])} #{biomarker[:unit_name]}" : biomarker[:measure_text],
      status: biomarker[:unit_value_type] == 1 ? biomarker[:measure_status] : nil,
      date: biomarker[:date],
      labels: nil,
      data_type: biomarker[:source_type_name]
    }
  end

  def render_biomarkers_partial(biomarkers)
    if biomarkers.empty?
      'shared/no_data'
    else
      'biomarkers/data'
    end
  end

end
