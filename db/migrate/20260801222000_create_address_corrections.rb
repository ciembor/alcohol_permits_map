class CreateAddressCorrections < ActiveRecord::Migration[5.2]
  def change
    create_table :address_corrections do |t|
      t.references :location, null: false, foreign_key: true
      t.references :source_location, foreign_key: { to_table: :locations }
      t.string :corrected_address_1, null: false
      t.string :corrected_address_2
      t.string :source, null: false
      t.string :method, null: false
      t.float :confidence, null: false
      t.boolean :selected, null: false, default: false
      t.text :evidence

      t.timestamps
    end

    add_index :address_corrections,
      [:location_id, :source, :method, :corrected_address_1, :corrected_address_2],
      unique: true,
      name: :index_address_corrections_on_identity
    add_index :address_corrections,
      [:location_id, :selected],
      name: :index_address_corrections_on_selected
  end
end
