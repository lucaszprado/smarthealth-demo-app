class CreateHumen < ActiveRecord::Migration[7.1]
  def change
    create_table :humen do |t|
      t.string :name
      t.string :gender
      t.date :birthdate

      t.timestamps
    end
  end
end
