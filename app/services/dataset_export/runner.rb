require 'fileutils'

require 'dataset_export/archive_packager'
require 'dataset_export/checksum_writer'
require 'dataset_export/config'
require 'dataset_export/documentation_writer'
require 'dataset_export/exporters/address_corrections_exporter'
require 'dataset_export/exporters/aggregates_exporter'
require 'dataset_export/exporters/alcohol_licenses_exporter'
require 'dataset_export/exporters/geocoding_results_exporter'
require 'dataset_export/exporters/geocoding_reviews_exporter'
require 'dataset_export/exporters/license_points_geojson_exporter'
require 'dataset_export/exporters/license_points_exporter'
require 'dataset_export/exporters/normalized_locations_exporter'
require 'dataset_export/exporters/point_memberships_exporter'
require 'dataset_export/exporters/raw_locations_exporter'
require 'dataset_export/exporters/reports_exporter'
require 'dataset_export/exporters/sim_populations_exporter'
require 'dataset_export/exporters/sim_units_exporter'
require 'dataset_export/manifest_writer'
require 'dataset_export/parquet_packager'
require 'dataset_export/paths'
require 'dataset_export/source_files_manifest'
require 'dataset_export/validator'

module DatasetExport
  class Runner
    def initialize(config = DatasetExport::Config.from_env)
      @config = config
      @paths = DatasetExport::Paths.new(config)
      @manifest = DatasetExport::ManifestWriter.new(config: config, paths: paths)
    end

    def export
      prepare_directories
      source_rows = export_source_files_manifest
      export_reports(source_rows)
      export_alcohol_licenses(source_rows)
      export_license_points
      export_point_memberships
      export_raw_locations
      export_normalized_locations
      export_address_corrections
      export_geocoding_results
      export_geocoding_reviews
      export_sim_populations
      export_sim_units
      export_aggregates
      export_license_points_geojson
      manifest.write
      checksum_count = DatasetExport::ChecksumWriter.new(root: paths.release_root, output_path: paths.checksums_txt).write

      {
        release_root: paths.release_root.to_s,
        checksum_count: checksum_count
      }
    end

    def validate
      DatasetExport::Validator.new(paths: paths).validate
    end

    def package
      report = DatasetExport::ParquetPackager.new(paths: paths).package
      DatasetExport::DocumentationWriter.new(paths: paths).write
      checksum_count = DatasetExport::ChecksumWriter.new(root: paths.release_root, output_path: paths.checksums_txt).write
      archive_report = DatasetExport::ArchivePackager.new(paths: paths).write_zip
      report.merge(checksum_count: checksum_count, archive: archive_report)
    end

    private

    attr_reader :config, :paths, :manifest

    def prepare_directories
      FileUtils.rm_rf(paths.release_root)
      paths.mkdirs
    end

    def export_source_files_manifest
      return [] unless config.include_source_files

      exporter = DatasetExport::SourceFilesManifest.new
      rows = exporter.rows
      exporter.write(paths.source_files_manifest_csv)
      manifest.add(
        path: paths.source_files_manifest_csv,
        format: 'csv',
        row_count: rows.size,
        description: 'Manifest source files used by the dataset preparation process.'
      )
      rows
    end

    def export_reports(source_rows)
      exporter = DatasetExport::Exporters::ReportsExporter.new(
        path: paths.reports_csv,
        source_file_rows: source_rows,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.reports_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Report-level summary table.'
      )
    end

    def export_alcohol_licenses(source_rows)
      exporter = DatasetExport::Exporters::AlcoholLicensesExporter.new(
        path: paths.alcohol_licenses_csv,
        source_file_rows: source_rows,
        include_business_names: config.include_business_names,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.alcohol_licenses_csv,
        format: 'csv',
        row_count: row_count,
        description: 'License-level administrative records.'
      )
    end

    def export_license_points
      exporter = DatasetExport::Exporters::LicensePointsExporter.new(
        path: paths.license_points_csv,
        include_business_names: config.include_business_names,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.license_points_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Grouped sales-point records derived from license-level records.'
      )
    end

    def export_point_memberships
      exporter = DatasetExport::Exporters::PointMembershipsExporter.new(
        path: paths.point_memberships_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.point_memberships_csv,
        format: 'csv',
        row_count: row_count,
        description: 'License-to-sales-point membership table, including not-geocoded license rows.'
      )
    end

    def export_raw_locations
      exporter = DatasetExport::Exporters::RawLocationsExporter.new(
        path: paths.locations_raw_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.locations_raw_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Raw source addresses used by license-level records.'
      )
    end

    def export_normalized_locations
      exporter = DatasetExport::Exporters::NormalizedLocationsExporter.new(
        path: paths.locations_normalized_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.locations_normalized_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Normalized locations used for geocoding and spatial joins.'
      )
    end

    def export_address_corrections
      exporter = DatasetExport::Exporters::AddressCorrectionsExporter.new(
        path: paths.address_corrections_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.address_corrections_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Address correction provenance records used during normalization.'
      )
    end

    def export_geocoding_results
      exporter = DatasetExport::Exporters::GeocodingResultsExporter.new(
        path: paths.geocoding_results_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.geocoding_results_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Non-Google geocoding candidate results without raw provider responses.'
      )
    end

    def export_geocoding_reviews
      exporter = DatasetExport::Exporters::GeocodingReviewsExporter.new(
        path: paths.geocoding_reviews_csv,
        latest_only: config.latest_only
      )
      row_count = exporter.write
      manifest.add(
        path: paths.geocoding_reviews_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Manual and semi-manual geocoding review decisions with reviewer identity redacted.'
      )
    end

    def export_sim_populations
      exporter = DatasetExport::Exporters::SimPopulationsExporter.new(
        path: paths.sim_populations_csv
      )
      row_count = exporter.write
      manifest.add(
        path: paths.sim_populations_csv,
        format: 'csv',
        row_count: row_count,
        description: 'Historical registered resident counts by SIM unit.'
      )
    end

    def export_sim_units
      exporter = DatasetExport::Exporters::SimUnitsExporter.new(
        path: paths.sim_units_geojson
      )
      row_count = exporter.write
      manifest.add(
        path: paths.sim_units_geojson,
        format: 'geojson',
        row_count: row_count,
        description: 'Official SIM unit boundaries with district attributes and computed area.'
      )
    end

    def export_aggregates
      row_counts = DatasetExport::Exporters::AggregatesExporter.new(paths: paths).write
      [
        [paths.city_summary_by_report_csv, row_counts.fetch(:city_summary_by_report_csv), 'City-level summary by report.'],
        [paths.district_summary_by_report_csv, row_counts.fetch(:district_summary_by_report_csv), 'District-level summary by report.'],
        [paths.sim_summary_by_report_csv, row_counts.fetch(:sim_summary_by_report_csv), 'SIM-unit-level summary by report.']
      ].each do |path, row_count, description|
        manifest.add(
          path: path,
          format: 'csv',
          row_count: row_count,
          description: description
        )
      end
    end

    def export_license_points_geojson
      row_count = DatasetExport::Exporters::LicensePointsGeojsonExporter.new(paths: paths).write
      manifest.add(
        path: paths.license_points_latest_geojson,
        format: 'geojson',
        row_count: row_count,
        description: 'Latest-report sales points as GeoJSON point features.'
      )
    end
  end
end
