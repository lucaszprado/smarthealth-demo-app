class Biomarker < ApplicationRecord
  has_many :synonyms
  has_many :measures

  def self.ransackable_associations(auth_object = nil)
    ["synonyms"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "external_ref", "id", "id_value", "name", "updated_at"]
  end

end
