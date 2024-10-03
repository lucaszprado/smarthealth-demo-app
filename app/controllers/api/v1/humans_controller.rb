class Api::V1::HumansController < ActionController::API
  def upload_exam
    human = Human.find(params[:id])
    debugger
    # Step 1: Create a new Source and store the uploaded PDF
    data_source = human.sources.create!
    data_source.file.attach(params[:file])

    # Step 2: Send the PDF to the vendor API for processing
    hash_data = VendorApi.send_pdf_to_vendor(data_source)

    # # Step 3: Process the hash and create Measures for the Source
    MeasureProcessor.save_measures_from_vendor(data_source, hash_data)

    render json: { message: "Measures created successfully" }, status: :created
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

# def upload_exam_params
#   params.require(:human).permit(:file)
# end

end
