module TransformedLocations
  class GeocoderCoordinateStore
    COLUMNS_BY_SOURCE = {
      'krakow_msip' => [:krakow_msip_latitude, :krakow_msip_longitude],
      'gus' => [:gus_latitude, :gus_longitude],
      'nominatim' => [:nominatim_latitude, :nominatim_longitude],
      'google' => [:google_latitude, :google_longitude],
      'uldk' => [:uldk_latitude, :uldk_longitude]
    }.freeze

    def initialize(location)
      @location = location
    end

    def store!(source, latitude, longitude)
      return if latitude.blank? || longitude.blank?

      latitude_column, longitude_column = COLUMNS_BY_SOURCE.fetch(source)
      location.update!(
        latitude_column => latitude,
        longitude_column => longitude
      )
    end

    private

    attr_reader :location
  end
end
