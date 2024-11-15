ActiveAdmin.register BiomarkersRange do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :synomys_string, :value_type, :external_ref
  #
  # or
  #
  permit_params do
    permitted = [:biomarker_id, :gender, :age, :possible_min_value, :possible_max_value, :optimal_min_value, :optimal_max_value]
    permitted << :other if params[:action] == 'create'
    permitted
  end

end
