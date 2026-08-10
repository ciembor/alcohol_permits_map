class CreateGeocodingResults < ActiveRecord::Migration[5.2]
  def change
    create_table :geocoding_results do |t|
      t.references :transformed_location, null: false, foreign_key: true
      t.string :source, null: false
      t.string :strategy, null: false
      t.string :query, null: false
      t.float :latitude
      t.float :longitude
      t.float :confidence
      t.string :precision
      t.boolean :selected, null: false, default: false
      t.text :raw_response

      t.timestamps
    end

    add_index :geocoding_results,
      [:transformed_location_id, :source, :strategy, :query],
      unique: true,
      name: :index_geocoding_results_on_source_identity
    add_index :geocoding_results,
      [:transformed_location_id, :selected],
      name: :index_geocoding_results_on_selected
  end
end
