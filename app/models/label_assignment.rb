class LabelAssignment < ApplicationRecord
  belongs_to :label
  belongs_to :labelable, polymorphic: true
end
