class ImagingReport < ApplicationRecord
  belongs_to :source
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments
end
