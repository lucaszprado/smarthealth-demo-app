ActiveAdmin.register Biomarker do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :external_ref
  #
  # or
  #
  permit_params do
    permitted = [:name, :external_ref, :biomarkers_range_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end

  index do
    column :id
    column :name
    column :external_ref
    column(:biomarker_PT) do |biomarker|
      pt_synonyms = biomarker.synonyms.select { |s| s.language == "PT" }
      # pt_synonyms.map(&:name).join(", ")
      pt_synonyms.empty? ? biomarker.name : pt_synonyms
    end
    column :created_at
    column :updated_at
  end

  preserve_default_filters!

  filter :id, as: :select, collection: -> {
    Biomarker.order(:id).pluck(:id)
  }, label: "Biomarker ID"

end
