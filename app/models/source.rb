class Source < ApplicationRecord
  belongs_to :human
  has_many :measures, dependent: :destroy
  has_many :imaging_reports, dependent: :destroy
  has_many_attached :files

  # Association with SourceType
  belongs_to :source_type optional: true

  # Associations with HealthProfessional and HealthProvider
  belongs_to :health_professional
  belongs_to :health_provider

  def self.ransackable_associations(auth_object = nil)
    ["measures", "human", "source_type", "health_provider", "health_professional", "imaging_reports"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["source_type", "created_at", "id", "updated_at", "files_attachments_id", "files_blobs_id", "file_cont", "file"]
  end
end
