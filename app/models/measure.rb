class Measure < ApplicationRecord
  belongs_to :biomarker, optional: true
  belongs_to :category, optional: true
  belongs_to :unit, optional: true
  belongs_to :source, optional: true
  has_many :label_assignments, as: :labelable, dependent: :destroy
  has_many :labels, through: :label_assignments

  def self.ransackable_associations(auth_object = nil)
    %w[source unit category biomarker label_assignments labels]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["biomarker_id", "category_id", "created_at", "date", "human_id", "id", "id_value", "original_value", "unit_id", "updated_at", "value", "source"]
  end

  # Fetch measures for a given human and biomarker
  # Returns an AR collection of Measure Objects
  def self.for_human_biomarker(human, biomarker)
    human.sources.flat_map {|source| source.measures.where(biomarker: biomarker)}
  end

  # Fetch human biomarker measures, adjusted by the unit factor
  # Transforms the ActiveRecrod collection into a Hash where
  # Keys are measure.date
  # Values are an array with two elements: biomarker_value and measure_source
  #
  # Ruby Best Practices
  # Once we're going to iterate over a collection, it's better to use a class method
  # Instead of an instance method, otherwise we would need to call the instance method
  # on each instance (object) of the measure collection.
  def self.human_biomarker_converted(measures, unit_factor)
    measures.each_with_object({}) do |measure, hash| # .each_with_object({}) initializes an empty hash ({}) and passes it into the block.
      biomarker_value = (measure.value / unit_factor).round(2)
      measure_date = measure.date
      measure_source = measure.source
      hash[measure_date] = [biomarker_value, measure_source]
    end
  end

  # Returns the most recent date ActiveRecord object
  def self.most_recent(human, biomarker)
    joins(:source)
    .where(sources: { human_id: human.id }, biomarker: biomarker)
    .order(date: :desc)
    .limit(1)
    .first
  end

  # Review this method
  def self.last_age(measures, birthdate)
    last_measure = measures.last
    ((last_measure.date.to_date - birthdate) / 365.25).floor
  end

  # Decide where to put this formatting method
  def formatted_biomarker_measures(data)
    data.map { |key, value| [key.strftime("%m/%Y"), value] }.to_h
  end

end
