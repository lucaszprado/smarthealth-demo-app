class CreateImagingDiagnostics < ActiveRecord::Migration[7.1]
  def change
    create_table :imaging_diagnostics do |t|
      t.string :name
      t.string :method
      t.text :summary_report
      t.text :full_report
      t.references :source, null: false, foreign_key: true
      t.datetime :date

      t.timestamps
    end
  end
end
