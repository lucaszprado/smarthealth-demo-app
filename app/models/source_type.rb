class SourceType < ApplicationRecord
  has_many :sources, dependent: :nullify

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "name", "updated_at"]
  end
  
end
