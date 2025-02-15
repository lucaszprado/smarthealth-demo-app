module ApplicationHelper
# The application_helper.rb file is meant for global helper methods that can be used across multiple views in your Rails application.

  def label_class(label_name)
  # Returns label-type to be use by scss to render label color
    case label_name
    when "Muscoesquelético" then "type1"
    when "Digestivo" then "type2"
    when "Respiratório" then "type3"
    when "Urinário" then "type4"
    when "Reprodutor" then "type5"
    when "Endócrino" then "type6"
    when "Circulatório" then "type7"
    when "Linfático" then "type8"
    when "Nervoso Central" then "type9"
    when "Nervoso Periférico" then "type10"
    when "Tegumentar" then "type11"
    else "default"
    end
  end

  def date_dd_mm_aaaa(date)
    date.strftime("%d/%m/%Y")
  end
end
