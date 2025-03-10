class BiomarkersController < ApplicationController
  
  def index
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender

    if params[:include_last_measure] == "true"
      @biomarkers = Biomarker.last_measure_for_human(@human, birthdate, gender)
    else
      @biomarkers = human.biomarkers
    end
  end

  def



  end

  def search
    biomarkers = Biomarker.search_for_human

  end

  end
end
