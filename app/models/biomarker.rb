class Biomarker < ApplicationRecord
  has_many :synonyms
  has_many :measures
  has_many :biomarkers_range
  has_many :unit_factor

  def self.ransackable_associations(auth_object = nil)
    ["synonyms", "measures", "biomarkers_range", "unit_factor"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "external_ref", "id", "id_value", "name", "updated_at"]
  end

end
