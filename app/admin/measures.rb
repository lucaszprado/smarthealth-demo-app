ActiveAdmin.register Measure do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :value, :original_value, :date, :biomarker_id, :category_id, :unit_id, :source_id
  #
  # or
  #
  permit_params do
    permitted = [:value, :original_value, :date, :biomarker_id, :category_id, :unit_id, :source_id]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end

  index do
    selectable_column
    id_column
    column :value
    column :original_value
    column :date
    column :biomarker
    column :category
    column :unit
    column :source
    column "Human" do |measure|
      link_to measure.source.human.name, admin_human_path(measure.source.human) if measure.source&.human
    end
    actions
  end

  show do
    attributes_table do
      row :value
      row :original_value
      row :date
      row :biomarker
      row :category
      row :unit
      row :source
      row :created_at
      row :updated_at
      row "Human" do |measure|
        link_to measure.source.human.name, admin_human_path(measure.source.human) if measure.source&.human
      end
    end
  end

  preserve_default_filters!

  filter :source_human_name_cont, as: :string, label: "Human Name"
  filter :biomarker, as: :select, collection: -> { Biomarker.order(:name).pluck(:name, :id) }


end
