require 'json'

class PagesController < ApplicationController
  # 1. Puxar 1 biomarker

  def home
    @biomarker_measures = {"2024-07-03" => 85, "2024-08-15" => 80, "2024-12-02" => 65, "2024-12-23" => 50}
    @biomarker_measures_json = @biomarker_measures.to_json
    @biomarker_upper_band = 60
    @biomarker_lower_band = 20

  end


  def about
  end
end
