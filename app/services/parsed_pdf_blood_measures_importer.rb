class ParsedPdfBloodMeasuresImporter
  def self.import(source, hash_data, human)
    begin
      ActiveRecord::Base.transaction do
        date = Time.at(hash_data["biomarkers"][0]["entries"][0]["date"]).to_date
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

        hash_data["refs"].each do |external_ref, ranges|
          # Step 1: Find the corresponding Biomarker by its external_ref
          biomarker = Biomarker.find_or_create_by!(external_ref: external_ref.to_s.to_i)
          common_min = ranges["common"][0]
          common_max = ranges["common"][1]
          optimal_min = ranges["optimal"][0]
          optimal_max = ranges["optimal"][1]

          # Step 2: Defining human variables
          gender = human.gender
          age = ((date - human.birthdate)/365.25).floor

          # Step 3: Insert the range values
          BiomarkersRange.find_or_create_by!(
            biomarker: biomarker,
            gender: gender,
            age: age,
            possible_min_value: common_min,
            possible_max_value: common_max,
            optimal_min_value: optimal_min.presence, # Use `presence` to handle empty arrays
            optimal_max_value: optimal_max.presence
          )
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "ActiveRecord::RecordInvalid: #{e.message}"
      raise ActiveRecord::Rollback
    rescue StandardError => e
      Rails.logger.error "StandardError: #{e.message}"
      raise ActiveRecord::Rollback
    end
  end
end
