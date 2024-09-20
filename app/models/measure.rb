class Measure < ApplicationRecord
  belongs_to :biomarker
  belongs_to :category
  belongs_to :unit
  belongs_to :human

  def self.ransackable_attributes(auth_object = nil)
    ["biomarker_id", "category_id", "created_at", "date", "human_id", "id", "id_value", "original_value", "unit_id", "updated_at", "value"]
  end
end
