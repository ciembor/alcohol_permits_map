class AddSimCircleWithinAreaToGeocodingReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :geocoding_reviews, :sim_circle_within_area, :boolean
  end
end
