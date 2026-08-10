class CreateGeocodingReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :geocoding_reviews do |t|
      t.references :transformed_location, null: false, foreign_key: true
      t.string :signal_category, null: false
      t.string :review_status, null: false
      t.string :reviewed_by
      t.float :original_latitude
      t.float :original_longitude
      t.float :manual_latitude
      t.float :manual_longitude
      t.integer :selected_geocoding_result_id
      t.integer :manual_geocoding_result_id
      t.text :quality_signals
      t.text :note
      t.datetime :reviewed_at, null: false

      t.timestamps
    end

    add_index :geocoding_reviews,
              [:transformed_location_id, :signal_category, :review_status],
              name: :index_geocoding_reviews_on_location_category_status
  end
end
