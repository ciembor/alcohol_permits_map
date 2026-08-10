class GeocodingReview < ApplicationRecord
  STATUSES = %w[
    verified
    corrected
    unresolved
    exact
    nearest_area
    area
    far
    very_far
    hard_to_tell
  ].freeze

  belongs_to :transformed_location
  belongs_to :selected_geocoding_result,
             class_name: 'GeocodingResult',
             optional: true
  belongs_to :manual_geocoding_result,
             class_name: 'GeocodingResult',
             optional: true

  serialize :quality_signals, Array

  validates :signal_category, presence: true
  validates :review_status, presence: true, inclusion: { in: STATUSES }
  validates :reviewed_at, presence: true
end
