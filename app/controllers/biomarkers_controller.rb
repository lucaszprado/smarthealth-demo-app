class BiomarkersController < ApplicationController
  def index
    @human = Human.find(params[:human_id])
    @last_measures = Measure
    .select('DISTINCT ON (measures.biomarker_id) measures.*')
    .joins(:source)
    .where(sources: { human_id: @human.id })
    .order('measures.biomarker_id, measures.date DESC');

    @last_measures = @last_measures.sort_by do |measure|

      if !measure.biomarker.synonyms.find_by(language: "PT").nil?
        measure.biomarker.synonyms.find_by(language: "PT").name
      else
        measure.biomarker.name
      end
    end
  end
end
