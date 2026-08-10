require 'fileutils'
require 'json'

require_dependency 'sim/units'

module DatasetExport
  module Exporters
    class SimUnitsExporter
      def initialize(path:)
        @path = path
      end

      def write
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "#{JSON.pretty_generate(feature_collection)}\n", encoding: 'UTF-8')
        units.size
      end

      private

      attr_reader :path

      def feature_collection
        {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'EPSG:4326'
            }
          },
          features: units.map { |unit| feature(unit) }
        }
      end

      def feature(unit)
        {
          type: 'Feature',
          geometry: unit.fetch(:geometry),
          properties: {
            sim_unit_code: unit.fetch(:code),
            sim_unit_name: unit.fetch(:name),
            district_code: unit.fetch(:district_code),
            district_name: unit.fetch(:district),
            area_km2: unit.fetch(:area_km2)
          }
        }
      end

      def units
        @units ||= Sim::Units.all
      end
    end
  end
end
