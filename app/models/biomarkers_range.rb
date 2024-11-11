class BiomarkersRange < ApplicationRecord
  belongs_to :biomarker
  # Validates that the combination of biomarker, gender, age, and value is unique
  validates :biomarker, uniqueness: { scope: [:gender, :age, :possible_min_value, :possible_max_value, :optimal_min_value, :optimal_max_value], message: "combination already exists" }

  def self.ransackable_associations(auth_object = nil)
    ["biomarker"]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[create_at updated_at gender age id possible_min_value possible_max_value optimal_min_value optimal_max_value ]
  end

end
