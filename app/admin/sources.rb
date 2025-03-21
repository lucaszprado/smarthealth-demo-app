ActiveAdmin.register Source do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :file, :source_type, :human_id
  #
  # or
  #
  permit_params do
    permitted = [:source_type_id, :human_id]
    permitted << {files: []}
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end

  form do |f|
    f.inputs do
      f.input :human, as: :select, collection: Human.all
      f.input :files, as: :file, input_html: {multiple: true} #input_html: { multiple: true } enables the multi-file picker.
      f.input :source_type, as: :select, collection: SourceType.all
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

  controller do
    def update
      Rails.logger.debug("🔎 SOURCE PARAMS: #{params[:source].inspect}")
      super
    end
  end

end
