class Api::V1::HumansController < ActionController::API
  def get_human_measures #create
    #measures_controller
    pdf_file = params[:pdf_file]
    health_professional_id = params[:health_professional_id]
    health_provider_id = params[:health_provider_id]
    human = Human.find(params[:id])
    # Fifo: Create measures dentro do namespace do human
    # api/v1/humans/:id/measures#create

    # Step 1: Create a new Source and store the uploaded PDF

    data_source = human.sources.new
    data_source.source_type = SourceType.find_by(name: "Blood")
    data_source.health_professional = HealthProfessional.find(health_professional_id)
    data_source.health_provider = HealthProvider.find(health_provider_id)
    data_source.files.attach(pdf_file)
    data_source.save!

    # Step 2: Send the PDF for parsing via vendor OR via internal service
    # TODO in the future

    # Step 3: Get parsed information from parsing process

    # Differenciate by male and female
    gender = human.gender
    hash_data = VendorApi.get_parsed_data(gender)

    # # Step 3: Process the hash and create Measures for the Source
    MeasureProcessor.save_measures_from_vendor(data_source, hash_data, human)

    render json: { message: "Measures created successfully" }, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def upload_bioimpedance
    ActiveRecord::Base.transaction do
      csv_file = params[:csv_file]
      pdf_file = params[:pdf_file]
      human_id = params[:id]


      # Ensure the human exists and defining variable to create ranges
      human = Human.find(human_id)
      gender = human.gender


      # Validate the presence of required files
      raise "Missing files" unless csv_file && pdf_file && human

      # Create the source and attah the PDF file
      source = human.sources.new
      source.files.attach(pdf_file)
      source.source_type = SourceType.find_by(name: "Bioimpedance")

      # Process the CSV file -> Create associated Measures and references
      csv_data = CSV.parse(csv_file.read, headers: true)
      csv_data.each do |row|
        # Transforming row to treat empty spaces
        row = row.to_h.transform_values { |v| v.presence }

        # Define Biomarker
        biomarker = Biomarker.find(row["biomarker_id"])

        # Determining age to create ranges
        date = Time.at(row["date"].to_i).to_date
        age = ((date - human.birthdate)/365.25).floor

        # Read and save source parameters depending on Operator Input
        source.health_professional = HealthProfessional.find(row["health_professional_id"])
        source.health_provider = HealthProvider.find(row["health_provider_id"])
        source.save

        Measure.create!(
          biomarker: biomarker,
          source: source,
          unit_id: row["unit_id"],
          category_id: row["category_id"],
          original_value: row["original_value"],
          value: row["value"],
          date: Time.at(row["date"].to_i)
        )

        BiomarkersRange.create!(
          biomarker: biomarker,
          gender: gender,
          age: age,
          possible_min_value: row["common_min"].nil? ? nil : row["common_min"].to_f,
          possible_max_value: row["common_max"].nil? ? nil : row["common_max"].to_f,
          optimal_min_value: row["optimal_min"].nil? ? nil : row["optimal_min"].to_f,
          optimal_max_value: row["optimal_max"].nil? ? nil : row["optimal_max"].to_f
        )

      end

      render json: {message: "Upload successful"}, status: :created
    rescue => e
      puts "Error type: #{e.class}"
      puts "Error message: #{e.message}"
      puts "Cleaned backtrace:"
      puts Rails.backtrace_cleaner.clean(e.backtrace)
      render json: {error: e.message}, status: :unprocessable_entity
      #If exceptions are rescued without re-raising (raise an error), the transaction commits all previous successful operations, resulting in partial changes.
      raise ActiveRecord::Rollback
    end
  end

  def upload_imaging_report
    ActiveRecord::Base.transaction do
      #Rails.logger.debug "Params received: #{params.inspect}"


      source = SourceCreator.create_source(api_params)
      if source.nil?
        render json: { error: "Failed to create Source" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end



      imaging_report = ImagingReport.new(
        imaging_method_id: params[:imaging_method_id],
        # report_summary_id: 1, # Placeholder -> To
        source_id: source.id,
        content: params[:content],
        date: Date.parse(params[:date])
      )

      unless imaging_report.save
        render json: { error: "Failed to create ImagingReport: #{imaging_report.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      labels = LabelAssignmentService.create(imaging_report, api_params)
      if labels.nil?
        render json: { error: "Failed to create Labels" }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      else
        render json: { message: "Imaging report, source and Labels successfully created", imaging_report_id: imaging_report.id, source_id: source.id, labels: labels}, status: :created
      end

    end
  end

  private

  # This method returns a hash that matches matches the keyword arguments expected by create_source in SourceCreator service
  def api_params

    # Debugging: Log the type of `pdf_files`
    #Rails.logger.debug "Before Processing: pdf_files is a #{params[:pdf_files].class}"

    # Ensure `pdf_files` is always an array (handles single & multiple file uploads)
    if params[:pdf_files].present?
      params[:pdf_files] = params[:pdf_files].is_a?(Array) ? params[:pdf_files] : [params[:pdf_files]]
    end

    permitted_params = params.permit(
      :id,
      :health_professional_id,
      :health_provider_id,
      :imaging_method_id,
      :date,
      :content,
      {pdf_files: []}, # Allow multiple files (array)
      {metadata: [:file_type]}, # Allow nested metadata -> In hash format.
      {label_system_id: []}, # Allow multiple labels ID (array)
      {label_organ_id: []},
      {label_part_id: []},
      {label_spacial_group_id: []},
      {label_positioning_id: []}
    )

    # # Debugging: Log the final permitted parameters
    # Rails.logger.debug "Permitted Params: #{permitted_params.inspect}"
  end

end
