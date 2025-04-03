class Measure < ApplicationRecord
  belongs_to :biomarker, optional: true
  belongs_to :category, optional: true
  belongs_to :unit, optional: true
  belongs_to :source, optional: true
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments

  def self.ransackable_associations(auth_object = nil)
    %w[source unit category biomarker label_assignments labels]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["biomarker_id", "category_id", "created_at", "date", "human_id", "id", "id_value", "original_value", "unit_id", "updated_at", "value", "source"]
  end

  # Includes Biomarkers and Synonyms when bringing a Mesure
  # Used @
  # - ActiveAdmin Resource file
  scope :with_biomarker_and_synonyms, -> {
    includes(biomarker: :synonyms)
  }

  # Fetch Measures from a given human for a specific biomarker
  #
  # Rails best practics
  # This's a scope. Very similar to a class method. It's defined by using a lambda function
  scope :for_human_biomarker, ->(human, biomarker) {
    joins(:source)
    .where(sources: { human_id: human.id }, biomarker: biomarker)
    .order(:date)
  }

  # Fetch the most recent measure for a biomarker for a given human
  def self.most_recent(human, biomarker)
    for_human_biomarker(human, biomarker).order(date: :desc).first
  end

  # Tranform measure object into a hash with:
  # Key: Measure date
  # Value: Measure value
  def self.for_human_biomarker_in_last_measure_unit(measures, unit_factor)
    measures.each_with_object({}) do |measure, hash|
      hash[measure.date] = [(measure.value / unit_factor).round(DECIMAL_PLACES), measure.source]
    end
  end



  # Queries all the required data for the controller send to the view
  def self.process_biomarker_data(human, biomarker)
    most_recent_measure = most_recent(human, biomarker)
    return {} unless most_recent_measure

    unit = most_recent_measure.unit
    unit_factor = UnitFactor.find_by(biomarker: biomarker, unit: unit)&.factor || 1

    measures = for_human_biomarker(human, biomarker)
    converted_measures = for_human_biomarker_in_last_measure_unit(measures, unit_factor)

    ranges = BiomarkersRange.bands_by_date(human, biomarker, unit_factor, measures)
    upper_band_measures = ranges[0]
    lower_band_measures = ranges[1]

    last_date = converted_measures.keys.last

    # Treat return for non-numeric measures
    if unit.value_type == 2
      converted_measures = converted_measures.transform_values do |value|
        if value.first == 1
          ["Positivo", value[1]]
        else
          ["Negativo", value[1]]
        end
      end

      return{
        last_measure_attributes: {
          unit_name: unit.name,
          unit_value_type: unit.value_type,
          value: converted_measures[last_date]&.first,
          upper_band: upper_band_measures[last_date],
          lower_band: lower_band_measures[last_date],
          biomarker_title: biomarker.title,
          band_type: upper_band_measures.values.first ? 1 : 0,
          gender: human.gender == "M" ? "Homem" : "Mulher",
          human_age: human.age_at_measure(last_date),
          status: nil
        },
        measure_series: {
          measures_with_sources: converted_measures,
          measures_with_sources_desc: converted_measures.to_a.reverse.to_h,
          upper_band: upper_band_measures,
          lower_band: lower_band_measures
        }
      }
    end

    # Treat return for numeric measures without reference values
    if unit.value_type == 1 && upper_band_measures[last_date] == nil
      return{
        last_measure_attributes: {
          unit_name: unit.name,
          unit_value_type: unit.value_type,
          value: converted_measures[last_date]&.first,
          upper_band: upper_band_measures[last_date],
          lower_band: lower_band_measures[last_date],
          biomarker_title: biomarker.title,
          band_type: upper_band_measures.values.first ? 1 : 0,
          gender: human.gender == "M" ? "Homem" : "Mulher",
          human_age: human.age_at_measure(last_date),
          status: nil
        },
        measure_series: {
          measures_with_sources: converted_measures,
          measures_with_sources_desc: converted_measures.to_a.reverse.to_h,
          upper_band: upper_band_measures,
          lower_band: lower_band_measures
        }
      }
    end

    {
      last_measure_attributes: {
        unit_name: unit.name,
        unit_value_type: unit.value_type,
        value: converted_measures[last_date]&.first,
        upper_band: upper_band_measures[last_date],
        lower_band: lower_band_measures[last_date],
        biomarker_title: biomarker.title,
        band_type: upper_band_measures.values.first ? 1 : 0,
        gender: human.gender == "M" ? "Homem" : "Mulher",
        human_age: human.age_at_measure(last_date),
        status: converted_measures[last_date]&.first <= upper_band_measures[last_date] &&
                converted_measures[last_date]&.first >= lower_band_measures[last_date] ? "green" : "yellow"
      },
      measure_series: {
        measures_with_sources: converted_measures,
        measures_with_sources_desc: converted_measures.to_a.reverse.to_h,
        upper_band: upper_band_measures,
        lower_band: lower_band_measures
      }
    }
  end
end
