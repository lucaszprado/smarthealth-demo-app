class Label < ApplicationRecord
  has_many :label_assignments, dependent: :destroy
  has_many :imaging_reports, through: :label_assignments, source: :labelable, source_type: "ImagingReport"

  # Child labels (Downward relationship)
  has_many :child_relationships, class_name: "LabelRelationship", foreign_key: "parent_label_id", dependent: :destroy
  has_many :children, through: :child_relationships, source: :child_label

  # Parent labels (Upward relationship)
  has_many :parent_relationships, class_name: "LabelRelationship", foreign_key: "child_label_id", dependent: :destroy
  has_many :parents, through: :parent_relationships, source: :parent_label

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["label_assignments"]
  end

end
