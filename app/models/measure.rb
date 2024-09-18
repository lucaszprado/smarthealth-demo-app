class Measure < ApplicationRecord
  belongs_to :biomarker
  belongs_to :category
  belongs_to :unit
  belongs_to :human
end
