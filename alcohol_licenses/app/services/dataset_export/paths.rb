require 'fileutils'
require 'pathname'

module DatasetExport
  class Paths
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def release_root
      config.output_dir.join(config.release_name)
    end

    def archive_zip
      config.output_dir.join("#{config.release_name}.zip")
    end

    def readme_md
      release_root.join('README.md')
    end

    def codebook_md
      release_root.join('CODEBOOK.md')
    end

    def license
      release_root.join('LICENSE')
    end

    def notice_md
      release_root.join('NOTICE.md')
    end

    def citation_cff
      release_root.join('CITATION.cff')
    end

    def metadata_dir
      release_root.join('metadata')
    end

    def tables_dir
      release_root.join('data/tables')
    end

    def aggregates_dir
      release_root.join('data/aggregates')
    end

    def geospatial_dir
      release_root.join('data/geospatial')
    end

    def parquet_dir
      release_root.join('data/parquet')
    end

    def reports_csv
      tables_dir.join('reports.csv')
    end

    def alcohol_licenses_csv
      tables_dir.join('alcohol_licenses.csv')
    end

    def license_points_csv
      tables_dir.join('license_points.csv')
    end

    def point_memberships_csv
      tables_dir.join('point_memberships.csv')
    end

    def locations_raw_csv
      tables_dir.join('locations_raw.csv')
    end

    def locations_normalized_csv
      tables_dir.join('locations_normalized.csv')
    end

    def address_corrections_csv
      tables_dir.join('address_corrections.csv')
    end

    def geocoding_results_csv
      tables_dir.join('geocoding_results.csv')
    end

    def geocoding_reviews_csv
      tables_dir.join('geocoding_reviews.csv')
    end

    def sim_populations_csv
      tables_dir.join('sim_populations.csv')
    end

    def sim_units_geojson
      geospatial_dir.join('sim_units.geojson')
    end

    def sim_units_gpkg
      geospatial_dir.join('sim_units.gpkg')
    end

    def license_points_latest_geojson
      geospatial_dir.join('license_points_latest.geojson')
    end

    def license_points_gpkg
      geospatial_dir.join('license_points.gpkg')
    end

    def city_summary_by_report_csv
      aggregates_dir.join('city_summary_by_report.csv')
    end

    def district_summary_by_report_csv
      aggregates_dir.join('district_summary_by_report.csv')
    end

    def sim_summary_by_report_csv
      aggregates_dir.join('sim_summary_by_report.csv')
    end

    def source_files_manifest_csv
      tables_dir.join('source_files_manifest.csv')
    end

    def export_manifest_json
      metadata_dir.join('export_manifest.json')
    end

    def datacite_json
      metadata_dir.join('datacite.json')
    end

    def validation_report_json
      metadata_dir.join('validation_report.json')
    end

    def validation_report_md
      metadata_dir.join('validation_report.md')
    end

    def package_report_json
      metadata_dir.join('package_report.json')
    end

    def checksums_txt
      release_root.join('checksums.txt')
    end

    def mkdirs
      [metadata_dir, tables_dir, aggregates_dir, geospatial_dir, parquet_dir].each { |path| FileUtils.mkdir_p(path) }
    end
  end
end
