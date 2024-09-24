class Human < ApplicationRecord
  has_many :sources

  def self.ransackable_associations(auth_object = nil)
    ["measures"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["birthdate", "created_at", "gender", "id", "id_value", "name", "updated_at"]
  end
end
