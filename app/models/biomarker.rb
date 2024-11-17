class Biomarker < ApplicationRecord
  has_many :synonyms
  has_many :measures
  has_many :biomarkers_ranges
  has_many :unit_factors

  # This class method. It's applied on the class all the time.
  def self.ransackable_associations(auth_object = nil)
    ["synonyms", "measures", "biomarkers_ranges", "unit_factors"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "external_ref", "id", "id_value", "name", "updated_at"]
  end

end
