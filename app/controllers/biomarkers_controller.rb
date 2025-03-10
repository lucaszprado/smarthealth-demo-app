class BiomarkersController < ApplicationController

  def index
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender

    if params[:include_last_measure] == "true"
      @biomarkers = Biomarker.last_measure_for_human(@human.id, birthdate, gender)
    else
      @biomarkers = @human.biomarkers # TBV
    end
  end


  def search
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    query = params[:query]
    search_query = query.split.map {|term| "#{term}:*"}.join(" | ") # :* Postgress Operator for pre-fixing match
    if query.present?
      @biomarkers = Biomarker.search_for_human(@human.id, birthdate, gender, search_query)
    else
      @biomarkers = Biomarker.last_measure_for_human(@human.id, birthdate, gender)
    end
  end
end
