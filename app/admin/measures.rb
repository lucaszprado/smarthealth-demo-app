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
    permitted << :other if params[:action] == 'create' # && current_user.admin? -> LP: Removed authorization
    permitted
  end

  # Measures index
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

  # Show page for a measure
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

  # Customize the form (Create) to use a dropdown for `source_id`
  form do |f|
    f.inputs do
      f.input :value
      f.input :original_value
      f.input :date, as: :datepicker
      f.input :biomarker, as: :select, collection: Biomarker.order(:name).pluck(:name, :id)
      f.input :category, as: :select, collection: Category.order(:name).pluck(:name, :id)
      f.input :unit, as: :select, collection: Unit.order(:name).pluck(:name, :id)
      f.input :source, as: :select, collection: Source.includes(:human).map { |source| ["#{source.id} - #{source.human.name}", source.id] }, label: "Source (ID - Human Name)"
    end
    f.actions
  end

  preserve_default_filters!

  filter :source, as: :select, collection: -> {
    # Fetches the Source records and maps them to show `source_id - Human Name`
    Source.includes(:human).map do |source|
      human_name = source.human.name
      ["#{source.id} - #{human_name}", source.id]
    end
  }, label: "Source (ID - Human Name)"

  filter :source_human_name_cont, as: :string, label: "Human Name"
  filter :biomarker, as: :select, collection: -> { Biomarker.order(:name).map {|b| ["#{b.id} | #{b.name}", b.id]}}


  # Define custom csv export
  # By default ActiveAdmin only exports model attributes
  # If we want associantions os calculated fields we must
  # customize the csv DSL method provided by Active Admin
  # For each measure we bring the attribute or run the block
  # Measure is the argument for each block statement
  csv do
    column :id
    column :value
    column :original_value

    column(:date) do |measure|
      measure.date.strftime("%Y-%m-%d") if measure.date
    end

    column("Unit ID") { |measure| measure.unit.id if measure.unit }
    column(:unit) { |measure| measure.unit.name if measure.unit }
    column("Biomarker ID") {|measure| measure.biomarker.id if measure.biomarker}
    column(:biomarker_EN) {|measure| measure.biomarker.name if measure.biomarker}

    column(:biomarker_PT) do |measure|
      if measure.biomarker
        pt_synonyms = measure.biomarker.synonyms.select { |s| s.language == "PT" }
        pt_synonyms.map(&:name).join(", ") || measure.biomarker.name
      end
    end

    column("Category ID") { |measure| measure.category.id if measure.category }
    column(:category) { |measure| measure.category.name if measure.category }
    column("Human") { |measure| measure.source.human.name if measure.source&.human }
    column(:source_id) { |measure| measure.source.id if measure.source }
    column :created_at
    column :updated_at
  end


  # We're overriding ActiveAdmin standard controller behaviour
  # Super returns Measure.all
  # with_biomarker_and_synoyms is defined on the model
  # Measure.all.includes(biomarker: :synonyms)
  controller do
    def scoped_collection
      super.with_biomarker_and_synonyms
    end
  end
end
