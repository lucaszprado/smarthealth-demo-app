class Biomarker < ApplicationRecord
  has_many :synonyms, dependent: :destroy
end
