class BioimpedanceMeasuresService
  # This action create bioimpedance biomarkers
  # Params keys => :csv_file, :pdf_file, :human_id
  def self.create(params)
    result = { errors: [] }

    ActiveRecord::Base.transaction do
      # Process the csv file
      csv_data = CSV.parse(params[:csv_file].read, headers: true)

      # Reading data from first bioimpedance measure to create to prepare source_params to SourceCreatorService
      source_params = {
        human_id: params[:human_id],
        health_provider_id: csv_data[1]["health_provider_id"],
        health_professional_id: csv_data[1]["health_professional_id"],
        pdf_files: params[:pdf_files],
        origin: :manual
      }

      source = SourceCreatorService.create_source(source_params, "Bioimpedance")

      csv_data.each_with_index do |row, index|
        row_data = row.to_h.transform_values(&:presence)
        # row.to_h converts CSV row into a hash
        # keys are the headers from the CSV
        # values are the corresponding cell values
        #
        #.transform_values(&:presence) = .transform_values{|v|v.presence}
        # presence is a Rails method that:
        # Returns the value if it’s not blank
        # Returns nil if it's blank

        # Reading data to create source and prepare source_params to SourceCreatorService


        # Instantiate Measure's Human
        human = Human.find(params[:human_id])

        # Define age to create BiomarkersRanges
        date = Time.at(row_data["date"].to_i).to_date
        age = ((date - human.birthdate)/365.25).floor

        # Create Measure
        Measure.create!(
          biomarker_id: row_data["biomarker_id"],
          source: source,
          unit_id: row_data["unit_id"],
          category_id: row_data["category_id"],
          original_value: row_data["original_value"],
          value: row_data["value"],
          date: Time.at(row_data["date"].to_i)
        )

        # Create BiomarkersRange
        BiomarkersRange.create!(
          biomarker_id: row_data["biomarker_id"],
          gender: human.gender,
          age: age,
          possible_min_value: row["common_min"].nil? ? nil : row["common_min"].to_f,
          possible_max_value: row["common_max"].nil? ? nil : row["common_max"].to_f,
          optimal_min_value: row["optimal_min"].nil? ? nil : row["optimal_min"].to_f,
          optimal_max_value: row["optimal_max"].nil? ? nil : row["optimal_max"].to_f
        )
      rescue StandardError => e
        result[:errors] << "Row #{index + 2} : #{e.message}"
        raise ActiveRecord::Rollback
      end
    end
    result
  end
end
