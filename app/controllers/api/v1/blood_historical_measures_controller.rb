class Api::V1::BloodHistoricalMeasuresController < ActionController::API
  # Handles the following endpoint:
  # /api/v1/humans/:human_id/blood_historical_measures
  def create
    # Get params
    human = Human.find(params[:human_id])
    csv_file = params[:csv_file]
    pdf_files = params[:pdf_files]

    # Validate required params
    if csv_file.blank?
      return render json: {error: "Missing CSV file"}, status: :unprocessable_entity
    end

    # Process CSV file synchronously through deidicated service
    result = CsvBloodHistoricalMeasuresService.process(csv_file, pdf_files)

    if result[:errors].any?
      render json: { message: "Error during upload", errors: result[:errors]}, status: :unprocessable_entity
    else
      render json: {message: "Upload successful", uploaded_biomarkers: result[:success_count]}, status: :created
    end

  rescue ActiveRecord::RecordNotFound => e
    render json: {error: e.message}, status: :not_found
  rescue StandardError => e
    render json: {error: e.message}, status: :unprocessable_entity
  end
end
