class MeasureProcessor

  # TODO create biomarkers_ranges and categories from this loop
  def self.save_measures_from_vendor(source, hash_data)
    ActiveRecord::Base.transaction do
      hash_data["biomarkers"].each do |biomarker_data|
        biomarker = Biomarker.find_or_create_by!(external_ref: biomarker_data["id"])

        biomarker_data["entries"].each do |entry|
          Measure.create!(
            source: source,
            biomarker: biomarker,
            value: entry["value"],
            original_value: entry["originalValue"],
            date: Time.at(entry["date"]),
            unit: Unit.find_by(external_ref: entry["originalUnitId"])
          )
        end
      end
    end
  rescue => e
    raise "Error processing measures: #{e.message}"
  end
end

