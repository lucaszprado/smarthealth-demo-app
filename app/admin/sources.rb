ActiveAdmin.register Source do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :source_type_id, :human_id, { files: [] }, :other, :health_professional_id, :health_provider_id
  #
  # or
  #

  # permit_params do
  #   permitted = :source_type_id, :human_id, {files: []}
  #   permitted << :other if params[:action] == 'create' #&& current_user.admin?
  #   permitted
  # end

  # Override ActiveAdmin's default Controller for source resource
  controller do
    # Override ActiveAdmin's default update action
    def update
      puts "🔥🔥🔥 Controller override is working"

      # permitted_params[:source] = params.require(:source).permit(:source_type_id, :human_id, :other, :health_professional_id, :health_provider_id, files: []) => ActiveAdmin Helper
      puts "📦 RESOURCE PARAMS: #{permitted_params[:source].inspect}"

      if resource.update(permitted_params[:source])
        puts "✅ Update succeeded"
        redirect_to resource_path(resource)
      else
        puts "🚨 ERRORS: #{resource.errors.full_messages.inspect}"

        # Flash is a standard Rails hash, available in controllers and views.
        # It’s used to pass one-time messages across requests (e.g., success or error notices).
        # flash[:notice] → green success box
        # flash[:error] → red error box
        # flash[:alert] → yellow warning box
        # The rendering of flash messages are done by ActiveAdmin internally: activeadmin/app/views/active_admin/base/_flashes.html.erb
        # More at https://www.notion.so/lucaspradonotes/Mounting-Engines-1c14ac7d9d29802d9f90e0f188c2ad12?pvs=4#1c14ac7d9d29804893cfcf9e3867c39e
        flash[:error] = resource.errors.full_messages.join(", ")

        # Rails renders ActiveAdmin’s own edit template, not your app’s standard
        # activeadmin/lib/active_admin/views/pages/edit.rb
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
    column(:date) {|source| source.date}
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
