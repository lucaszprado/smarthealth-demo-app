class MeasuresController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    @biomarker = Biomarker.find(params[:biomarker_id])

    # Get the unit for the most recent measure
    most_recent_measure = Measure.most_recent
    @unit = most_recent_measure.unit

    # Get the unit factor for the biomarker and unit
    @unit_factor = UnitFactor.find_by(biomarker: @biomarker, unit: @unit).factor

    # Fetch Biomarker measures via the source associated with a human
    # Return an Active Record Collection of measures
    @human_biomarker_measures = Measure.for_human_biomarker(@human, @biomarker)

    # Convert human biomarker measures to the last unit. Receives a hash.
    @human_biomarker_measures_in_last_unit = Measure.for_biomarker_in_last_unit(@human_biomarker_measures, @unit_factor)

    # Fetch biomarkers range for each measure data point
    ranges = BiomarkersRange.bands_by_date(@human, @biomarker, @unit_factor, @human_biomarker_measures)
    @human_biomarker_upper_band_measures_in_last_unit = ranges[0]
    @human_biomarker_lower_band_measures_in_last_unit = ranges[1]

    # Create Hash with measure values as value
    # transform_values replaces only the vale in the hash key value pair
    @human_biomarker_measures_values_in_last_unit = @human_biomarker_measures_in_last_unit.transform_values { |array| array.first }

    # Create Hash with source values as value
    # transform_values replaces only the vale in the hash key value pair
    @human_biomarker_measures_sources = @human_biomarker_measures_in_last_unit.transform_values { |array| array[1] }

    # JSON Formatting
    @human_biomarker_measures_values_in_last_unit_json = @human_biomarker_measures_values_in_last_unit.map {|key, value| [key.strftime ("%m/%Y"), value]}.to_h.to_json
    @human_biomarker_upper_band_measures_in_last_unit_json = @human_biomarker_upper_band_measures_in_last_unit.map {|key, value| [[key.strftime ("%m/%Y"), value]]}.to_h.to_json
    @human_biomarker_lower_band_measures_in_last_unit_json = @human_biomarker_lower_band_measures_in_last_unit.map {|key, value| [[key.strftime ("%m/%Y"), value]]}.to_h.to_json

    # Last measure data
    @last_biomarker_measure_values = @human_biomarker_measures_values_in_last_unit[@human_biomarker_measures_values_in_last_unit.keys.last]
    @last_biomarker_upper_band_measure = @human_biomarker_upper_band_measures_in_last_unit[@human_biomarker_upper_band_measures_in_last_unit.keys.last]
    @last_biomarker_lower_band_measure = @human_biomarker_lower_band_measures_in_last_unit[@human_biomarker_lower_band_measures_in_last_unit.keys.last]

    # Last recorded age in the system
    @last_age = measures.last_age

  end
end
