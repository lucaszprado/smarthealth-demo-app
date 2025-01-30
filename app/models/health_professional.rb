class HealthProfessional < ApplicationRecord
  has_many :sources, dependent: :nullify

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "name", "updated_at",]
  end

  def self.ransackable_associations(auth_object = nil)
    ["sources"]
  end

end
