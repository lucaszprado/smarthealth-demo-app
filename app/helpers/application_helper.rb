module ApplicationHelper
# The application_helper.rb file is meant for global helper methods that can be used across multiple views in your Rails application.

  def label_class(label_name)
  # Returns label-type to be use by scss to render label color
    case label_name
    when "Muscoesquelético" then "label-type-1"
    when "Digestivo" then "label-type-2"
    when "Respiratório" then "label-type-3"
    when "Urinário" then "label-type-4"
    when "Reprodutor" then "label-type-5"
    when "Endócrino" then "label-type-6"
    when "Circulatório" then "label-type-7"
    when "Linfático" then "label-type-8"
    when "Nervoso Central" then "label-type-9"
    when "Nervoso Periférico" then "label-type-10"
    when "Tegumentar" then "label-type-11"
    else "label-default"
    end
  end

  def date_dd_mm_aaaa(date)
    date.strftime("%d/%m/%Y")
  end
end
