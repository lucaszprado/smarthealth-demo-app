class RemoveCategoryFromLabels < ActiveRecord::Migration[7.1]
  def change
    remove_reference :labels, :category, null: false, foreign_key: true
  end
end
