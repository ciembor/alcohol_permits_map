require_dependency 'sim/locator'

module Sim
  class ReviewAreaContainment
    RADIUS_BY_STATUS = {
      'exact' => 0,
      'nearest_area' => 25,
      'area' => 50,
      'far' => 100,
      'very_far' => 100
    }.freeze

    EARTH_RADIUS_M = 6_371_000.0

    def initialize(locator: Sim::Locator.new)
      @locator = locator
    end

    def within_area?(review)
      location = review.transformed_location
      return street_within_one_area?(location) if street_area_review?(review, location)

      radius = RADIUS_BY_STATUS[review.review_status]
      return nil unless radius

      center_area = locator.locate(location.latitude, location.longtitude)
      return false unless center_area
      return true if radius.zero?

      circle_points(location.latitude.to_f, location.longtitude.to_f, radius).all? do |lat, lng|
        area = locator.locate(lat, lng)
        area && area.fetch(:code) == center_area.fetch(:code)
      end
    end

    private

    attr_reader :locator

    def street_area_review?(review, location)
      return false if location.address_1.blank?
      return true if review.review_status == 'hard_to_tell'

      location.building_number.blank? &&
        location.unit_number.blank? &&
        location.parcel_number.blank?
    end

    def street_within_one_area?(location)
      area_codes = TransformedLocation
        .joins(:locations)
        .where(address_1: location.address_1)
        .where.not(latitude: nil, longtitude: nil)
        .distinct
        .filter_map do |street_location|
          locator.locate(street_location.latitude, street_location.longtitude)&.fetch(:code)
        end
        .uniq

      return nil if area_codes.empty?

      area_codes.one?
    end

    def circle_points(lat, lng, radius_m)
      lat_rad = lat * Math::PI / 180.0
      lng_rad = lng * Math::PI / 180.0
      angular = radius_m / EARTH_RADIUS_M

      (0...72).map do |index|
        bearing_rad = index * 5 * Math::PI / 180.0
        point_lat_rad = Math.asin(
          Math.sin(lat_rad) * Math.cos(angular) +
            Math.cos(lat_rad) * Math.sin(angular) * Math.cos(bearing_rad)
        )
        point_lng_rad = lng_rad + Math.atan2(
          Math.sin(bearing_rad) * Math.sin(angular) * Math.cos(lat_rad),
          Math.cos(angular) - Math.sin(lat_rad) * Math.sin(point_lat_rad)
        )

        [point_lat_rad * 180.0 / Math::PI, point_lng_rad * 180.0 / Math::PI]
      end
    end
  end
end
