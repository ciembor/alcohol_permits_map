require_dependency 'sim/units'

module Sim
  class Locator
    DEFAULT_PATH = Rails.root.join('vendor/data/sim/jednostki_sim.geojson')

    def initialize(path: DEFAULT_PATH)
      @features = Sim::Units.all(path: path).map do |unit|
        unit.merge(bbox: bbox(unit.fetch(:geometry)))
      end
      @cache = {}
    end

    def locate(latitude, longitude)
      return if latitude.blank? || longitude.blank?

      lat = latitude.to_f
      lng = longitude.to_f
      @cache[[lat, lng]] ||= features.find do |feature|
        in_bbox?(feature.fetch(:bbox), lng, lat) && contains?(feature.fetch(:geometry), lng, lat)
      end
    end

    private

    attr_reader :features

    def bbox(geometry)
      coordinates = geometry_coordinates(geometry)
      lngs = coordinates.map(&:first)
      lats = coordinates.map(&:last)
      [lngs.min, lats.min, lngs.max, lats.max]
    end

    def geometry_coordinates(geometry)
      case geometry.fetch('type')
      when 'Polygon'
        geometry.fetch('coordinates').flatten(1)
      when 'MultiPolygon'
        geometry.fetch('coordinates').flatten(2)
      else
        []
      end
    end

    def in_bbox?(bbox, lng, lat)
      min_lng, min_lat, max_lng, max_lat = bbox
      lng >= min_lng && lng <= max_lng && lat >= min_lat && lat <= max_lat
    end

    def contains?(geometry, lng, lat)
      case geometry.fetch('type')
      when 'Polygon'
        polygon_contains?(geometry.fetch('coordinates'), lng, lat)
      when 'MultiPolygon'
        geometry.fetch('coordinates').any? { |polygon| polygon_contains?(polygon, lng, lat) }
      else
        false
      end
    end

    def polygon_contains?(rings, lng, lat)
      return false unless point_in_ring?(rings.first, lng, lat)

      rings.drop(1).none? { |ring| point_in_ring?(ring, lng, lat) }
    end

    def point_in_ring?(ring, lng, lat)
      inside = false
      previous = ring.last

      ring.each do |current|
        current_lng, current_lat = current
        previous_lng, previous_lat = previous
        intersects = (current_lat > lat) != (previous_lat > lat)
        if intersects
          crossing_lng = (previous_lng - current_lng) * (lat - current_lat) / (previous_lat - current_lat) + current_lng
          inside = !inside if lng < crossing_lng
        end
        previous = current
      end

      inside
    end
  end
end
