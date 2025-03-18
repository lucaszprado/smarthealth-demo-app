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

  def last_measure_type(measure)
    if measure[:last_measure_attributes][:band_type] == 1
      render "measures/ranges", locals: last_measure_attributes(measure)
   else
     render 'measures/non_ranges', locals: last_measure_attributes(measure)
   end
  end

  def last_measure_attributes(measure)
    if measure[:last_measure_attributes][:unit_value_type] == 1 && !measure[:last_measure_attributes][:upper_band].nil?
      if measure[:last_measure_attributes][:value] > measure[:last_measure_attributes][:upper_band]
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "yellow",
          status_text: "Acima"
        }

      elsif measure[:last_measure_attributes][:value] < measure[:last_measure_attributes][:lower_band]
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "yellow",
          status_text: "Abaixo"
        }
      else
        return {
          value: measure[:last_measure_attributes][:value],
          unit_name: measure[:last_measure_attributes][:unit_name],
          status_color_code: "green",
          status_text: "Normal"
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
