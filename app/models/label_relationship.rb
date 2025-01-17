class LabelRelationship < ApplicationRecord
  belongs_to :parent_label, class_name:"Label"
  belongs_to :child_label, class_name:"Label"
end
