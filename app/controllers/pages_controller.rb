require 'json'

class PagesController < ApplicationController
  # 1. Puxar 1 biomarker

  def home
    @biomarker_measures = {"2024-07-03" => 85, "2024-08-15" => 100, "2024-12-02" => 65, "2024-12-23" => 80, "2025-02-23" => 80}
    @biomarker_measures_json = @biomarker_measures.to_json
    @biomarker_upper_band = 90
    @biomarker_lower_band = 70

  end


  def about
  end
end
