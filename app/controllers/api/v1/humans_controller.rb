class Api::V1::HumansController < ActionController::API
  def get_human_measures
    human = Human.find(params[:id])

    # Step 1: Create a new Source and store the uploaded PDF
    data_source = human.sources.create!
    data_source.file.attach(params[:file])
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

# def upload_exam_params
#   params.require(:human).permit(:file)
# end

end
