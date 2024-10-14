require 'json'

class PagesController < ApplicationController
  # 1. Puxar 1 biomarker

  def home
    @biomarker_measures = {"2024-07-03" => 90, "2024-08-15" => 40, "2024-12-02" => 79}
    @biomarker_measures_json = @biomarker_measures.to_json
    @biomarker_upper_band = 85
    @biomarker_lower_band = 45

  end


  def about
  end
end
