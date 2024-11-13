class Source < ApplicationRecord
  belongs_to :human
  has_many :measures, dependent: :destroy
  has_one_attached :file

  def self.ransackable_associations(auth_object = nil)
    ["measures", "human"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["source_type", "created_at", "id", "updated_at", "file_attachment_id", "file_blob_id", "file_cont", "file"]
  end
end
