class Source < ApplicationRecord
  has_many :measures
  has_one_attached :file
end
