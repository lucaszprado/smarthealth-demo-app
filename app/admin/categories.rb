ActiveAdmin.register Category do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :external_ref, :parent_id
  #
  # or
  #
  permit_params do
    permitted = [:name, :external_ref, :parent_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
