class Label < ApplicationRecord
  belongs_to :category
  has_many :label_assignments, dependent: :destroy
  has_many :labelables, through: :label_assignments, source: :labelable

  # Child labels (Downward relationship)
  has_many :child_relationships, class_name: "LabelRelationship", foreign_key: "parent_label_id", dependent: :destroy
  has_many :children, through: :child_relationships, source: :child_label

  # Parent labels (Upward relationship)
  has_many :parent_relationships, class_name: "LabelRelationship", foreign_key: "child_label_id", dependent: :destroy
  has_many :parents, through: :parent_relationships, source: :parent_label
end
