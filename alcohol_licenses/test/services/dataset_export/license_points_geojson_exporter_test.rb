require 'test_helper'
require 'csv'
require 'json'
require 'tmpdir'

class DatasetExport::LicensePointsGeojsonExporterTest < ActiveSupport::TestCase
  test 'writes latest license points as geojson features' do
    Dir.mktmpdir do |dir|
      config = DatasetExport::Config.new(version: 'v-test', output_dir: dir, include_source_files: false, latest_only: false)
      paths = DatasetExport::Paths.new(config)
      paths.mkdirs
      write_input_csvs(paths)

      count = DatasetExport::Exporters::LicensePointsGeojsonExporter.new(paths: paths).write

      assert_equal 1, count

      payload = JSON.parse(paths.license_points_latest_geojson.read)
      assert_equal 'FeatureCollection', payload.fetch('type')
      assert_equal 'EPSG:4326', payload.fetch('crs').fetch('properties').fetch('name')
      assert_equal 1, payload.fetch('features').size

      feature = payload.fetch('features').first
      assert_equal 'Point', feature.fetch('geometry').fetch('type')
      assert_equal [19.94, 50.07], feature.fetch('geometry').fetch('coordinates')
      assert_equal 'point-latest', feature.fetch('properties').fetch('point_id')
      assert_equal '2026-02-01T00:00:00Z', feature.fetch('properties').fetch('reported_at')
      refute_includes feature.fetch('properties'), 'latitude'
      refute_includes feature.fetch('properties'), 'longitude'
    end
  end

  private

  def write_input_csvs(paths)
    CSV.open(paths.reports_csv, 'w:UTF-8', write_headers: true, headers: %w[report_id reported_at report_date point_count]) do |csv|
      csv << ['report-2026-01-01T00-00-00Z', '2026-01-01T00:00:00Z', '2026-01-01', 1]
      csv << ['report-2026-02-01T00-00-00Z', '2026-02-01T00:00:00Z', '2026-02-01', 1]
    end

    CSV.open(paths.license_points_csv, 'w:UTF-8', write_headers: true, headers: %w[point_id reported_at latitude longitude license_count]) do |csv|
      csv << ['point-old', '2026-01-01T00:00:00Z', 50.061, 19.936, 2]
      csv << ['point-latest', '2026-02-01T00:00:00Z', 50.07, 19.94, 3]
    end
  end
end
