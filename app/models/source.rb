class Source < ApplicationRecord
  belongs_to :human
  has_many :measures
  has_one_attached :file
end
