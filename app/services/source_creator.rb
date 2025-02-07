class SourceCreator
  # params is parameter that receives a hash as an argument
  def self.create_source(params)
    debugger
    source_type = SourceType.find_by(name: "Image")
    raise StandardError, "SourceType 'image' not found" unless source_type

    source = Source.new(
      source_type_id: source_type.id,
      human_id: params[:id],
      health_professional_id: params[:health_professional_id],
      health_provider_id: params[:health_provider_id],
    )

    Rails.logger.debug "Metadata: #{params[:metadata].inspect}"
    # Rails.logger.debug "Index: #{index}"
    # Rails.logger.debug "Metadata at index: #{params[:metadata][index].inspect}"

    ActiveRecord::Base.transaction do
      if source.save
        attach_files_with_metadata(source, params[:pdf_files], params[:metadata])
        return source
      else
        raise ActiveRecord::Rollback, "Failed to create Source: #{source.errors.full_messages.join(', ')}"
      end
    end

  rescue => e
    Rails.logger.error "SourceCreator Error: #{e.message}"
    nil
  end

  private

  def self.attach_files_with_metadata(source, pdf_files, metadata)
    pdf_files.each_with_index do |uploaded_file, index|
      # Attach file along with metadata
      attachment = source.files.attach(
        io: uploaded_file,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type,
        metadata: { file_type: metadata[index.to_s]["file_type"] }
      )

      if attachment.blank?
        raise ActiveRecord::Rollback, "Failed to attach file: #{uploaded_file.original_filename}"
      end
    end
  end
end
