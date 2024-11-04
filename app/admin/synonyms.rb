ActiveAdmin.register Synonym do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :biomarker_id, :language
  #
  # or
  #
  permit_params do
    permitted = [:name, :biomarker_id, :language]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end

  preserve_default_filters!

  filter :biomarker, as: :select, collection: -> { Biomarker.order(:name).pluck(:name, :id) }
end
