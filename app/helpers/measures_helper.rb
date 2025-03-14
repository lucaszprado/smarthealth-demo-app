module MeasuresHelper
  # Transform each hash key from a hash
  # Tranform standard date format to mm/yyyy
  def format_date_measures_mm_dd(measures)
    measures.transform_keys { |date| date.strftime("%m/%Y") }
  end

  def get_only_hash_values(measures)
    measures = measures.map {|key, value| [key, value[0]]}.to_h

  end
end
