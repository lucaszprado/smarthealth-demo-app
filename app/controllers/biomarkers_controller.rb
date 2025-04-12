class BiomarkersController < ApplicationController

  # Index brings all the biomarkers with their last measure
  def blood
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Blood'])
    @search_url = blood_search_human_biomarkers_path(@human)
    # Instance variable that defines the search_url for the search form -> Point to the blood_search action
    render :index
    # Render the same view as the index action
  end

  def bioimpedance
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Bioimpedance'])
    @search_url = bioimpedance_search_human_biomarkers_path(@human)
    render :index
  end

  def blood_search
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    query = params[:query]
    puts "Query: #{query}" # Debugging line
    puts "Human ID: #{params[:human_id]}" # Debugging line
    search_query = query.split.map {|term| "#{term}:*"}.join(" | ") # :* Postgress Operator for pre-fixing match
    if query.present?
      @biomarkers = Biomarker.search_last_measure_by_source(@human.id, birthdate, gender, search_query, ['Blood'])
    else
      @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Blood'])
    end

     # Define controller response (normal render vs AJAX response)
     respond_to do |format|
      format.html { render :index }
      format.text { render partial: "list", locals: {human: @human, biomarkers: @biomarkers}, formats: [:html]}
    end
  end

  def bioimpedance_search
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    query = params[:query]
    search_query = query.split.map {|term| "#{term}:*"}.join(" | ") # :* Postgress Operator for pre-fixing match
    if query.present?
      @biomarkers = Biomarker.search_last_measure_by_source(@human.id, birthdate, gender, search_query, ['Bioimpedance'])
    else
      @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Bioimpedance'])
    end

     # Define controller response (normal render vs AJAX response)
     respond_to do |format|
      format.html { render :index }
      format.text { render partial: "list", locals: {human: @human, biomarkers: @biomarkers}, formats: [:html]}
    end
  end

  def index
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Blood', 'Bioimpedance'])
    @search_url = search_human_biomarkers_path(@human)
  end

  def search
    @human = Human.find(params[:human_id])
    birthdate = @human.birthdate.strftime('%Y-%m-%d')
    gender = @human.gender
    query = params[:query]
    search_query = query.split.map {|term| "#{term}:*"}.join(" | ") # :* Postgress Operator for pre-fixing match
    if query.present?
      @biomarkers = Biomarker.search_last_measure_by_source(@human.id, birthdate, gender, search_query, ['Blood', 'Bioimpedance'])
    else
      @biomarkers = Biomarker.last_measure_by_source(@human.id, birthdate, gender, ['Blood', 'Bioimpedance'])
    end

     # Define controller response (normal render vs AJAX response)
     respond_to do |format|
      format.html { render :index }
      format.text { render partial: "list", locals: {human: @human, biomarkers: @biomarkers}, formats: [:html]}
    end
  end
end
