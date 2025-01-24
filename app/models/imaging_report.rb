class ImagingReport < ApplicationRecord
  belongs_to :source
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "date", "id", "id_value", "imaging_method_id", "report_summary_id", "source_id", "updated_at"]
  end
  
end
