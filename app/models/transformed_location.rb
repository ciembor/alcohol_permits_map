class TransformedLocation < ApplicationRecord
  has_many :locations
  has_many :geocoding_results
  has_many :geocoding_reviews

  def store_geocoder_coordinates!(source, latitude, longitude)
    TransformedLocations::GeocoderCoordinateStore.new(self).store!(source, latitude, longitude)
  end

  def use_geocoding_result!(result)
    TransformedLocations::SelectedGeocodingResultUpdater.new(self).use!(result)
  end

  def geocodable?
    geocoding_profile.geocodable?
  end

  def geocoding_address
    geocoding_profile.address
  end

  def geocoding_payload
    geocoding_profile.payload
  end

  def geocoding_strategy
    geocoding_profile.strategy
  end

  def geocoding_queries
    geocoding_profile.queries
  end

  private

  def geocoding_profile
    TransformedLocations::GeocodingProfile.new(self)
  end
end
