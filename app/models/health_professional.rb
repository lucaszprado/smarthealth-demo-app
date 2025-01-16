class HealthProfessional < ApplicationRecord
  has_many :sources, dependent: :nullify
end
