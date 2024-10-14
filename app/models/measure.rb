class Measure < ApplicationRecord
  belongs_to :biomarker, optional: true
  belongs_to :category, optional: true
  belongs_to :unit, optional: true
  belongs_to :source, optional: true

  def self.ransackable_associations(auth_object = nil)
    %w[source unit category biomarker]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["biomarker_id", "category_id", "created_at", "date", "human_id", "id", "id_value", "original_value", "unit_id", "updated_at", "value", "source"]
  end
end
