ActiveAdmin.register Source do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :source_type_id, :human_id, { files: [] }, :other
  #
  # or
  #

  # permit_params do
  #   permitted = :source_type_id, :human_id, {files: []}
  #   permitted << :other if params[:action] == 'create' #&& current_user.admin?
  #   permitted
  # end

  controller do
    def update
      puts "🔥🔥🔥 Controller override is working"

      params_hash = params.require(:source).permit(:source_type_id, :human_id, :other, :health_professional_id, :health_provider_id, files: [])
      params_hash[:files]&.reject!(&:blank?)

      puts "📦 FINAL PARAMS: #{params_hash.inspect}"

      if resource.update(params_hash)
        puts "✅ Update succeeded"
        redirect_to resource_path(resource)
      else
        puts "🚨 ERRORS: #{resource.errors.full_messages.inspect}"
        flash[:error] = resource.errors.full_messages.join(", ")
        render :edit
      end
    end
  end


  form do |f|
    f.inputs do
      f.input :human, as: :select, collection: Human.all
      f.input :files, as: :file, input_html: {multiple: true} #input_html: { multiple: true } enables the multi-file picker.
      f.input :source_type, as: :select, collection: SourceType.all
      f.input :health_professional, as: :select, collection: HealthProfessional.all
      f.input :health_provider, as: :select, collection: HealthProvider.all
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :human
    column :source_type
    column :created_at
    column :updated_at
    column "PDF File" do |source|
      if source.files.attached?
        link_to "View PDF", rails_blob_path(source.files.first, disposition: "inline"), target: "_blank"
      else
        "No File"
      end
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :human
      row :source_type
      row :health_professional
      row :health_provider
      row :created_at
      row :updated_at
      row :file do |source|
        if source.files.attached?
          ul do
            source.files.each do |file|
              li do
               link_to file.filename, rails_blob_path(source.files.first, disposition: "inline"), target: "_blank"
              end
            end
          end
        else
          "No File"
        end
      end
    end
    active_admin_comments
  end
end
