require 'test_helper'
require 'json'
require 'tmpdir'

class DatasetExport::SimUnitsExporterTest < ActiveSupport::TestCase
  test 'writes sim units geojson with public properties' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'sim_units.geojson')
      count = DatasetExport::Exporters::SimUnitsExporter.new(path: path).write

      assert_equal Sim::Units.all.size, count

      payload = JSON.parse(File.read(path))
      assert_equal 'FeatureCollection', payload.fetch('type')
      assert_equal 'EPSG:4326', payload.fetch('crs').fetch('properties').fetch('name')
      assert_equal Sim::Units.all.size, payload.fetch('features').size

      feature = payload.fetch('features').first
      assert_equal 'Feature', feature.fetch('type')
      assert_includes %w[Polygon MultiPolygon], feature.fetch('geometry').fetch('type')
      assert_equal %w[area_km2 district_code district_name sim_unit_code sim_unit_name], feature.fetch('properties').keys.sort
      assert feature.fetch('properties').fetch('area_km2').to_f.positive?
    end
  end
end
