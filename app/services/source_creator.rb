class SourceCreator
  # using keys as arguments allows you to change the arguments when calling the method
  def self.create_source(human:, source_type_id:, health_professional_id:, health_provider_id:, files:, metadata:)

    # Instantiate source object
    source = human.sources.new(
      source_type: SourceType.find(source_type_id),
      health_professional: HealthProfessional.find(health_professional_id),
      health_provider: HealthProvider.find(health_provider_id)
    )

    # Loop through all the attached files linked to source and add them to instantiated source object
    debugger
    puts files.map(&:class)
    files.each_with_index do |file, index|
      file_metadata = extract_metadata(metadata, index)
      source.files.attach(
        io: File.open(file[:path]),   # Open the file from the provided path
        filename: file[:filename],    # Extract filename
        content_type: file[:content_type], # Extract content type
        metadata: file_metadata.to_json   # Ensure metadata is JSON
      )
    end

    if source.save
      {success: true, source: source}
    else
      {success: false, errors: source.error.full_messages}
    end
  end

  private
  # Extract metadata per file
  # "Self" represents the class which this method will be called on
  # metadata_param receives as an argument a hash params[:metadata] from Postman, which is a hash which index are stingfied numbers.

  def self.extract_metadata(metadata_param, index)
    return {} unless metadata_param.present? && metadata_param[index.to_s].present?

    # Since metadata_param comes from params. Its class is an ActionController::Parameters. We must convert it to a hash.
    metadata_param[index.to_s] #.permit!.to_h
  end
end
