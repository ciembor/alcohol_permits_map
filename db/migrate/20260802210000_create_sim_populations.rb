class CreateSimPopulations < ActiveRecord::Migration[6.1]
  def change
    create_table :sim_populations do |t|
      t.date :observed_on, null: false
      t.integer :observed_on_code, null: false
      t.string :sim_unit_code, null: false
      t.string :sim_unit_name, null: false
      t.string :district_code, null: false
      t.string :district_name, null: false
      t.integer :total, null: false

      t.timestamps
    end

    add_index :sim_populations, [:observed_on, :sim_unit_code], unique: true
    add_index :sim_populations, :district_name
    add_index :sim_populations, :observed_on
  end
end
