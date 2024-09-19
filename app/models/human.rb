class Human < ApplicationRecord
  has_many :measures, dependent: :destroy
end
