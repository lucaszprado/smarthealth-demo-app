class ImagingReport < ApplicationRecord
  belongs_to :source
  belongs_to :imaging_method
  belongs_to :report_summary, optional: true
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments
  has_one :health_professional, through: :source
  has_one :health_provider, through: :source

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "date", "id", "id_value", "imaging_method_id", "report_summary_id", "source_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["imaging_method", "label_assignments", "labels", "report_summary", "source"]
  end


  # This method transforms each ActiveRecord ImagingReport collection into a structured hash.
  # Output example:
  #   {
  #     id: 1,
  #     content: "MRI scan result...",
  #     date: "2025-02-15",
  #     imaging_method: "MRI",
  #     labels: [{ id: 10, name: "Musculoskeletal" }, { id: 20, name: "Elbow" }],
  #     label_system: ["Musculoskeletal"],
  #     title: ["Elbow", "Sagittal Plane"]
  #   }
  def structured_data
    label_system = []
    title = []
    # Label is an ActiveRecord Label::ActiveRecord_Associations_CollectionProxy.
    # This is a proxy object that represents a collection of associated records.
    # It behaves like an array but also provides ActiveRecord querying methods.
    # It behaves like an array but is optimized for database interactions
    labels.each do |label|
      label.parents.each do |parent|
        case parent.name
        when "Sistema"
          label_system << label.name
        when "Parte", "Órgão"
          title[0] = label.name
        when "Plano sagittal"
          title[1] = label.name
        end
      end
    end
    title[1] = adjust_gender(title[0], title[1]) if title[0] && title[1]

    {
      id: id,
      content: content,
      date: date,
      imaging_method: imaging_method.name,
      labels: labels.map { |label| { id: label.id, name: label.name } }, # [:labels] will be an Array of hashs
      label_system: label_system,
      title: title,
      health_professional: health_professional,
      health_provider: health_provider,
      report_urls: image_urls("report"),
      image_urls: image_urls("image")
    }
  end

  private

  def image_urls(metadata)
    # Ensure you retrieve the files attached to the source
    # rails_blob_path generates a URL for the file, which can be used in the frontend.
    # only_path: true gives the relative URL (without the domain name), which is useful for rendering in your views
    report_image_urls = source.files
      .select { |file| file.blob.metadata["file_type"] == metadata }
      .map { |file| Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) }
  end

  # Transforms Label "Direito" in "Direita" if Label title [0] is feminine.
  def adjust_gender (reference_word, target_word)
    exceptions = {
      "mão" => :feminine,
      "pé" => :masculine,
    }

    # The || operator returns the first truthy value it encounters.
    gender = exceptions[reference_word.downcase] || (reference_word.end_with?("o") ? :masculine : :feminine)

    if gender == :masculine
      return target_word
    elsif gender == :feminine
      target_word = target_word.gsub(/o$/, "a")
    end
  end
end
