class Unit < ApplicationRecord
  has_many :unit_factor
  
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "external_ref", "id", "id_value", "name", "synomys_string", "updated_at", "value_type"]
  end
end
