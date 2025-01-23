class Measure < ApplicationRecord
  belongs_to :biomarker, optional: true
  belongs_to :category, optional: true
  belongs_to :unit, optional: true
  belongs_to :source, optional: true
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments

  def self.ransackable_associations(auth_object = nil)
    %w[source unit category biomarker]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["biomarker_id", "category_id", "created_at", "date", "human_id", "id", "id_value", "original_value", "unit_id", "updated_at", "value", "source"]
  end
end
