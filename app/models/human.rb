class Human < ApplicationRecord
  has_many :sources, dependent: :destroy
  has_many :measures, through: :sources
  has_many :imaging_reports, through: :sources
  has_many :biomarkers, -> { distinct }, through: :measures

  def self.ransackable_associations(auth_object = nil)
    ["sources", "measures", "imaging_reports"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["birthdate", "created_at", "gender", "id", "id_value", "name", "updated_at"]
  end


  def age_at_measure(date)
    ((date.to_date - self.birthdate) / 365.25).floor
  end

end
