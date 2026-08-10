class CreateStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :streets do |t|
      t.string :trait
      t.string :name_1
      t.string :name_2

      t.timestamps
    end
  end
end
