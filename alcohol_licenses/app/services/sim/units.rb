require 'json'

module Sim
  class Units
    DEFAULT_PATH = Rails.root.join('vendor/data/sim/jednostki_sim.geojson')
    EARTH_RADIUS_METERS = 6_371_008.8

    def self.all(path: DEFAULT_PATH)
      @all ||= {}
      @all[path.to_s] ||= JSON.parse(File.read(path, encoding: 'UTF-8')).fetch('features').map do |feature|
        properties = feature.fetch('properties')
        geometry = feature.fetch('geometry')

        {
          code: properties.fetch('Nr_jed_SIM').to_s.strip,
          district_code: properties.fetch('Nr_dziel').to_s.strip,
          name: properties.fetch('Nazwa_SIM').to_s.strip,
          district: properties.fetch('Dziel').to_s.strip,
          geometry: geometry,
          area_km2: area_km2(geometry).round(4)
        }
      end
    end

    def self.by_code(path: DEFAULT_PATH)
      @by_code ||= {}
      @by_code[path.to_s] ||= all(path: path).index_by { |unit| unit.fetch(:code) }
    end

    def self.area_km2(geometry)
      area_m2 = case geometry.fetch('type')
                when 'Polygon'
                  polygon_area_m2(geometry.fetch('coordinates'))
                when 'MultiPolygon'
                  geometry.fetch('coordinates').sum { |polygon| polygon_area_m2(polygon) }
                else
                  0.0
                end

      area_m2 / 1_000_000.0
    end

    def self.polygon_area_m2(rings)
      return 0.0 if rings.empty?

      outer_area = ring_area_m2(rings.first).abs
      holes_area = rings.drop(1).sum { |ring| ring_area_m2(ring).abs }
      [outer_area - holes_area, 0.0].max
    end

    def self.ring_area_m2(ring)
      return 0.0 if ring.size < 3

      area = 0.0
      previous = ring.last

      ring.each do |current|
        previous_lng = degrees_to_radians(previous.first)
        previous_lat = degrees_to_radians(previous.last)
        current_lng = degrees_to_radians(current.first)
        current_lat = degrees_to_radians(current.last)
        area += (current_lng - previous_lng) * (2 + Math.sin(previous_lat) + Math.sin(current_lat))
        previous = current
      end

      area * EARTH_RADIUS_METERS * EARTH_RADIUS_METERS / 2.0
    end

    def self.degrees_to_radians(value)
      value.to_f * Math::PI / 180.0
    end
  end
end
