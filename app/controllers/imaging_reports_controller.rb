class ImagingReportsController < ApplicationController
  def index
    @human = Human.find(params[:human_id])

    # 1. Build ActiveRecord collection of imaging_reports -> Simillar an array
    imaging_reports_collection = ImagingReport
      .joins(source: :human)
      .joins(:imaging_method)
      .where(sources: {human_id: @human.id})
      .includes(:labels)
      .order(date: :desc)

    # 2. Transform ActiveRecord collection in a structured hash + Needed View parameters: label_system, title
    @imaging_reports = imaging_reports_collection.map do |report|
      {
        id: report.id,
        content: report.content,
        date: report.date,
        imaging_method: report.imaging_method.name,
        labels: report.labels.map { |label| { id: label.id, name: label.name } }, # An Array oh hashes
        label_system: [], # To be populated on step 3
        title: [], # [Method, Body Part or Organ, Position]
      }
    end

    # 3. Add System Label to the structured Hash
    @imaging_reports.each do |report|
      # puts "Stop here"
      # debugger
      report[:labels].each do |label|#  report[:labels] = [{:id=>242, :name=>"Muscoesquelético"}, {:id=>154, :name=>"Cotovelo"}, {:id=>253, :name=>"Plano sagittal"}, {:id=>257, :name=>"Direito"}]
        Label.find(label[:id]).parents.each do |parent| # => Label.find(label[:id]).parents = #<ActiveRecord::Associations::CollectionProxy [#<Label id: 242, name: "Muscoesquelético", created_at: "2025-02-03 18:41:36.126727000 +0000", updated_at: "2025-02-03 18:41:36.126727000 +0000">, #<Label id: 253, name: "Plano sagittal", created_at: "2025-02-03 18:41:36.144389000 +0000", updated_at: "2025-02-03 18:41:36.144389000 +0000">, #<Label id: 262, name: "Parte", created_at: "2025-02-03 18:41:36.159247000 +0000", updated_at: "2025-02-03 18:41:36.159247000 +0000">]>
          if parent[:name] == "Sistema"
            report[:label_system] << label[:name]
          end

          if parent[:name] == "Parte" || parent[:name] == "Órgão"
            report[:title][0] = label[:name]
          end

          if parent[:name] == "Plano sagittal"
            report[:title][1] = label[:name]
          end
        end
      end
    end
  end



end
