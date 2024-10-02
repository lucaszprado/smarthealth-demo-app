class MeasureProcessor
  # TODO create biomarkers_ranges and categories from this loop
  def self.save_measures_from_vendor(source, hash_data)
    begin
      ActiveRecord::Base.transaction do
        hash_data["biomarkers"].each do |biomarker_data|
          biomarker = Biomarker.find_or_create_by!(external_ref: biomarker_data["id"])
          category = Category.find_by(external_ref: biomarker_data["categoryId"])
          biomarker_data["entries"].each do |entry|
            Measure.create!(
              source: source,
              biomarker: biomarker,
              category: category,
              value: entry["value"],
              original_value: entry["originalValue"],
              date: Time.at(entry["date"]),
              unit: Unit.find_by(external_ref: entry["originalUnitId"])
            )
          end
        end

        puts hash_data[:refs]

        hash_data["refs"].each do |external_ref, ranges|
          # Step 1: Find the corresponding Biomarker by its external_ref
          biomarker = Biomarker.find_or_create_by!(external_ref: external_ref.to_s.to_i)
          common_min = ranges["common"][0]
          common_max = ranges["common"][1]
          optimal_min = ranges["optimal"][0]
          optimal_max = ranges["optimal"][1]

          #puts "\n\n\n\n\n\n#{biomarker.name}\n\n\n\n\n\n"


        # Step 2: Insert the range values
          BiomarkersRange.create!(
            biomarker: biomarker,
            gender: nil,    # You can adjust as per your needs
            age: nil,       # You can add logic if needed
            possible_min_value: common_min,
            possible_max_value: common_max,
            optimal_min_value: optimal_min.presence, # Use `presence` to handle empty arrays
            optimal_max_value: optimal_max.presence
          )
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ActiveRecord::RecordInvalid: #{e.message}"
      puts
      raise
    rescue StandardError => e
      Rails.logger.error "StandardError: #{e.message}"
      raise
    end
  end
end
