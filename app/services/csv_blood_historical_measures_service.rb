require 'csv'

class CsvBloodHistoricalMeasuresService
  def self.process(csv_file, pdf_files)
    result = {success_count: 0, errors: []}
    sources = {} # Cache for created sources by health_provider_id

    ActiveRecord::Base.transaction do
      csv_data = CSV.parse(csv_file.read, headers: true)
      csv_data.each_with_index do |row, index|
      # row is a CSV::Row object
        row_data = row.to_h.transform_values(&:presence)
        # row.to_h converts CSV row into a hash
        # keys are the headers from the CSV
        # values are the corresponding cell values
        #
        #.transform_values(&:presence) = .transform_values{|v|v.presence}
        # presence is a Rails method that:
        # Returns the value if it’s not blank
        # Returns nil if it's blank

        begin
          # Retrieve human and helath provider from CSV row
          human = Human.find(row_data["human_id"])
          health_provider = row_data["health_provider_id"].present? ? HealthProvider.find(row_data["health_provider_id"]) : nil

          # Determine the key for the source cache (use a default key for nil).
          source_key = health_provider&.id || 'nil'
          # nil is different from 'nil'
          # 'nil' will be the key when no health_provider is associated with the measure / row

          # # Create a new source only if one doesn't already exist for a measure's health provider.
          # # Call SourceCreatorService to create the source
          unless sources[source_key]
            source_params = {
              human_id: human.id,
              source_type: SourceType.find_by(name: "Blood"),
              health_professional: nil, # Historical measures have no associated health professional
              health_provider: health_provider,
              pdf_files: pdf_files
            }

            sources[source_key] = SourceCreatorService.create_source(source_params, "Blood")
          end

          source = sources[source_key]

          # Create the measure record.
          measure_date = DateTime.parse(row_data["date"])
          measure = Measure.create!(
            biomarker_id: row_data["biomarker_id"],
            source: source,
            unit_id: row_data["unit_id"],
            category_id: row_data["category_id"],
            original_value: row_data["original_value"],
            value: row_data["value"],
            date: measure_date
          )

          # Create the associated biomarker range record
          BiomarkersRange.create!(
            biomarker_id: row_data["biomarker_id"],
            gender: row_data["gender"],
            age: row_data["age"],
            possible_min_value: row_data["possible_min_value"].present? ? row_data["possible_min_value"].to_f : nil,
            possible_max_value: row_data["possible_max_value"].present? ? row_data["possible_max_value"].to_f : nil,
          )

          result[:success_count] += 1

        rescue StandardError => e
          Rails.logger.error("Error on row #{index + 2}: #{e.message}")
          result[:errors] << "Row #{index + 2} : #{e.message}"
          # Index starts at zero and we move on up to disconsider headers
        end
      end
      raise ActiveRecord::Rollback if result[:errors].any?
      # Raise (triggering the rollback) must execute before the transaction block completes.
    end
    result
  end
end
