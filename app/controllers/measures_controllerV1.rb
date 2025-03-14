class MeasuresController < ApplicationController
  def index
    @human_biomarker_measures = {}
    @human = Human.find(params[:human_id])
    @gender = @human.gender
    birthdate = @human.birthdate
    @biomarker = Biomarker.find(params[:biomarker_id])
    @measures = @human.measures.where(biomarker: @biomarker)
    # chart will be on the last measure unit
    most_recent_measure = @measures.order(date: :desc).first
    @unit = most_recent_measure.unit
    unit_factor = UnitFactor.find_by(biomarker: @biomarker, unit: @unit).factor


    @measures.each do |measure|
      biomarker_value = (measure.value/unit_factor).round(decimal_places = 2)
      measure_date = measure.date
      measure_source = measure.source

      # Initialize the hash for the biomarker measures, sources and biomarker ranges
      @human_biomarker_measures ||= {}
      @human_biomarker_upper_band_measures ||= {}
      @human_biomarker_lower_band_measures ||= {}


      # Add the date as key and biomarker original value inside the hash
      @human_biomarker_measures[measure_date] = [biomarker_value, measure_source]

      # Create source references for each measure
      #@human_biomarker_measures_sources[measure_date] = measure_source

      # Add the date as key and biomarker range values inside the hash
      # 1. Which age should be searched?
      @age = ((measure.date.to_date - birthdate)/365.25).floor
      # 2. Find the most recent range
      biomarker_range = BiomarkersRange
        .where(biomarker: @biomarker, gender: @gender, age: @age)
        .order(created_at: :desc)
        .first

      if !biomarker_range.possible_min_value.nil?
        @human_biomarker_upper_band_measures[measure_date] = (biomarker_range.possible_max_value/unit_factor).round(decimal_places = 2)
        @human_biomarker_lower_band_measures[measure_date] = (biomarker_range.possible_min_value/unit_factor).round(decimal_places = 2)
      else
        @human_biomarker_upper_band_measures[measure_date] = nil
        @human_biomarker_lower_band_measures[measure_date] = nil
      end
    end

    # Order the hash by date
    @human_biomarker_measures = @human_biomarker_measures.sort_by { |key, value| key}.to_h
    @human_biomarker_upper_band_measures = @human_biomarker_upper_band_measures.sort_by { |key, value| key}.to_h
    @human_biomarker_lower_band_measures = @human_biomarker_lower_band_measures.sort_by { |key, value| key}.to_h


    # Get the values and sources for a given measure
    @human_biomarker_measures_values = @human_biomarker_measures.transform_values {|array| array.first}
    @human_biomarker_measures_sources = @human_biomarker_measures.transform_values {|array| array[1]}
    #debugger

    # Transform measures into JSON and formatting dates to "%d/%m/%Y"
    @human_biomarker_measures_values_json = @human_biomarker_measures_values.map {|key, value| [key.strftime("%m/%Y"), value]}.to_h.to_json
    @human_biomarker_upper_band_measures_json = @human_biomarker_upper_band_measures.map {|key, value| [key.strftime("%d/%m/%Y"), value]}.to_h.to_json
    @human_biomarker_lower_band_measures_json = @human_biomarker_lower_band_measures.map {|key, value| [key.strftime("%d/%m/%Y"), value]}.to_h.to_json


    # Last measure value
    @last_biomarker_measure_values = @human_biomarker_measures_values[@human_biomarker_measures_values.keys.last]
    @last_biomarker_upper_band_measure = @human_biomarker_upper_band_measures[@human_biomarker_upper_band_measures.keys.last]
    @last_biomarker_lower_band_measure = @human_biomarker_lower_band_measures[@human_biomarker_lower_band_measures.keys.last]

    # Last measure date
    @last_age = ((@human_biomarker_measures_values.keys.last.to_date - birthdate)/365.25).floor
    
  end
end
