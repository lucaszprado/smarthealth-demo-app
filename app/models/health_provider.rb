class HealthProvider < ApplicationRecord
  has_many :sources, dependent: :nullify
end
