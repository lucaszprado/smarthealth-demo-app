class Source < ApplicationRecord
  belongs_to :human
  has_many :measures, dependent: :destroy
  belongs_to :source_type, optional: true

  has_many :imaging_reports, dependent: :destroy
  # Deleting a source deletes its respective imaging_reports
  # has_one :imaging_report, dependent: :destroy

  has_many_attached :files

  # Association with SourceType
  belongs_to :source_type, optional: true

  # Associations with HealthProfessional and HealthProvider
  belongs_to :health_professional, optional: true
  belongs_to :health_provider, optional: true

  # A source can be by manual, batch or api
  # Manual is the default value
  enum origin: { manual: 0, batch: 1, api: 2}

  def self.ransackable_associations(auth_object = nil)
    ["measures", "human", "source_type", "health_provider", "health_professional", "imaging_reports"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["source_type", "created_at", "id", "updated_at", "files_attachments_id", "files_blobs_id", "file_cont", "file", "origin"]
  end

  def date
    case source_type&.name
    when "Blood" then measures&.first&.date
    when "Bioimpedance" then measures&.first&.date
    when "Image" then imaging_reports&.first&.date
    else nil
    end
  end

end
