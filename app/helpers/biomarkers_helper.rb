module BiomarkersHelper
  # Returns attributes for view partial depending on numeric and non numeric measures
  def result_card_attributes(human, biomarker)
    {
      link: human_biomarker_measures_path(human.id, biomarker[:biomarker_id]),
      icon_path: "fa-solid fa-vial",
      title: biomarker[:synonym_name],
      key_info: biomarker[:unit_value_type] == 1 ? "#{format_value_2_decimals(biomarker[:original_value])} #{biomarker[:unit_name]}" : biomarker[:measure_text],
      status: biomarker[:unit_value_type] == 1 ? biomarker[:measure_status] : nil,
      date: biomarker[:date],
      labels: nil
    }
  end
end
