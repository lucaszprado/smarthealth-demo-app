module MeasuresHelper
  # Transform each hash key from a hash
  # Tranform standard date format to mm/yyyy
  def format_date_measures_mm_dd(measures)
    measures.transform_keys { |date| date.strftime("%m/%Y") }
  end

  def get_only_first_hash_value(measures)
    measures = measures.map {|key, value| [key, value[0]]}.to_h
  end

  def view_type(measure)
    if measure[:last_measure_attributes][:unit_value_type] == 1
      render 'measures/numeric', locals: {measure: measure}
    else
      render 'measures/non_numeric', locals: {measure: measure}
    end
  end

  def measure_type(measure)
    if measure[:last_measure_attributes][:band_type] == 1
      render "measures/ranges", locals: measure_attributes(measure)
   else
     render 'measures/non_ranges', locals: measure_attributes(measure)
   end
  end

  def measure_attributes(measure)
    if measure[:last_measure_attributes][:unit_value_type] == 1 && !measure[:last_measure_attributes][:upper_band].nil?
      if measure[:last_measure_attributes][:value] > measure[:last_measure_attributes][:upper_band]
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "yellow",
          status_text: "Acima",
          gender: measure[:last_measure_attributes][:gender],
          human_age: measure[:last_measure_attributes][:human_age],
          lower_band: measure[:last_measure_attributes][:lower_band],
          upper_band: measure[:last_measure_attributes][:upper_band]
        }



      elsif measure[:last_measure_attributes][:value] < measure[:last_measure_attributes][:lower_band]
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "yellow",
          status_text: "Abaixo",
          gender: measure[:last_measure_attributes][:gender],
          human_age: measure[:last_measure_attributes][:human_age],
          lower_band: measure[:last_measure_attributes][:lower_band],
          upper_band: measure[:last_measure_attributes][:upper_band]
        }
      else
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "green",
          status_text: "Normal",
          gender: measure[:last_measure_attributes][:gender],
          human_age: measure[:last_measure_attributes][:human_age],
          lower_band: measure[:last_measure_attributes][:lower_band],
          upper_band: measure[:last_measure_attributes][:upper_band]
        }
      end
    elsif measure[:last_measure_attributes][:unit_value_type] == 1 && measure[:last_measure_attributes][:upper_band].nil?
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name]
        }
    else
      if measure[:last_measure_attributes][:value] == 1
        return {
          value: "Positivo"
        }
      else
        return {
          value: "Negativo"
        }
      end
    end
  end
end
