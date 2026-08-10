require 'csv'
require 'fileutils'
require 'json'

module DatasetExport
  class GeospatialWriter
    def self.write_point_geojson(path:, rows:)
      new.write_point_geojson(path: path, rows: rows)
    end

    def write_point_geojson(path:, rows:)
      FileUtils.mkdir_p(File.dirname(path))
      count = 0

      File.open(path, 'w:UTF-8') do |file|
        file.write("{\n")
        file.write(%Q(  "type": "FeatureCollection",\n))
        file.write(%Q(  "crs": {"type": "name", "properties": {"name": "EPSG:4326"}},\n))
        file.write(%Q(  "features": [\n))

        rows.each do |row|
          file.write(",\n") if count.positive?
          file.write(JSON.pretty_generate(feature_for(row)).lines.map { |line| "    #{line}" }.join)
          count += 1
        end

        file.write("\n  ]\n")
        file.write("}\n")
      end

      count
    end

    private

    def feature_for(row)
      {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [numeric(row.fetch('longitude')), numeric(row.fetch('latitude'))]
        },
        properties: properties_for(row)
      }
    end

    def properties_for(row)
      row.to_h.reject { |key, _value| key == 'latitude' || key == 'longitude' }
    end

    def numeric(value)
      Float(value)
    end
  end
end
