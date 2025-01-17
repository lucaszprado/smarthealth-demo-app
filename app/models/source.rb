class Source < ApplicationRecord
  belongs_to :human
  has_many :measures, dependent: :destroy
  has_many :imaging_diagnostics, dependent: :destroy

  has_one_attached :file

  # Self-referential associations
  belongs_to :parent, class_name: "Source", optional: true
  has_many :children, class_name: "Source", foreign_key: "parent_id", dependent: :destroy

  # Association with SourceType
  belongs_to :source_type

  # Associations with HealthProfessional and HealthProvider
  belongs_to :health_professional
  belongs_to :health_provider

  def self.ransackable_associations(auth_object = nil)
    ["measures", "human"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["source_type", "created_at", "id", "updated_at", "file_attachment_id", "file_blob_id", "file_cont", "file"]
  end
end
