require 'csv'
require 'date'
require 'fileutils'
require 'json'
require 'time'

require 'dataset_export/json_writer'

module DatasetExport
  class DocumentationWriter
    TITLE = 'Krakow alcohol licenses and sales points, 2010-2026'.freeze
    CREATOR = 'Maciej Ciemborowicz'.freeze
    CREATOR_ORCID = 'https://orcid.org/0009-0009-6877-9931'.freeze
    DATASET_DOI = '10.5281/zenodo.21895077'.freeze
    DATASET_DOI_URL = 'https://doi.org/10.5281/zenodo.21895077'.freeze
    DESCRIPTION = 'A curated, geocoded dataset of alcohol-sale license records and derived sales points in Krakow, Poland, 2010-2026.'.freeze
    KEYWORDS = ['alcohol licenses', 'Krakow', 'geocoding', 'administrative data', 'open data', 'urban studies', 'spatial data'].freeze

    FILE_DESCRIPTIONS = {
      'data/tables/reports.csv' => 'Report-level time dimension and summary counts.',
      'data/tables/alcohol_licenses.csv' => 'Administrative license records; one row is one license category and activity type in one report.',
      'data/tables/license_points.csv' => 'Analytical sales points derived from grouped geocoded licenses.',
      'data/tables/point_memberships.csv' => 'License-to-sales-point membership table, including non-geocoded licenses.',
      'data/tables/locations_raw.csv' => 'Canonical raw source addresses preserved from administrative registers.',
      'data/tables/locations_normalized.csv' => 'Normalized locations used for geocoding and spatial joins.',
      'data/tables/address_corrections.csv' => 'Address-correction provenance used during normalization.',
      'data/tables/geocoding_results.csv' => 'Public non-Google geocoding candidate results without raw provider responses.',
      'data/tables/geocoding_reviews.csv' => 'Manual and semi-manual geocoding review decisions without reviewer identity or free-text notes.',
      'data/tables/sim_populations.csv' => 'Registered resident counts by SIM unit and snapshot date.',
      'data/geospatial/sim_units.geojson' => 'SIM unit boundaries in EPSG:4326 with district attributes and area.',
      'data/aggregates/city_summary_by_report.csv' => 'City-level summary by report.',
      'data/aggregates/district_summary_by_report.csv' => 'District-level summary by report.',
      'data/aggregates/sim_summary_by_report.csv' => 'SIM-unit-level summary by report.',
      'data/geospatial/license_points_latest.geojson' => 'Latest-report sales points as GeoJSON point features.'
    }.freeze

    ENUM_COLUMNS = {
      'license_category' => 'A, B, C.',
      'business_category' => 'Retail and gastronomy categories from source registers.',
      'membership_method' => 'license_point_group, fallback_business_location, not_geocoded.',
      'crs' => 'EPSG:4326.',
      'area_type' => 'city, district, sim_unit.'
    }.freeze

    COLUMN_DESCRIPTIONS = {
      'address_1' => 'Normalized street name or non-street location name used for matching and geocoding.',
      'address_2' => 'Address complement from the source record, usually building, unit, parcel, or descriptive information.',
      'address_kind' => 'Normalized address class, for example building, parcel, or descriptive location.',
      'address_relation' => 'Relationship between the source address and normalized location, where recorded.',
      'area_code' => 'Stable public code of the aggregation area: city, district, or SIM unit.',
      'area_km2' => 'Area size in square kilometres used for density calculations.',
      'area_name' => 'Human-readable name of the aggregation area.',
      'area_type' => 'Aggregation level of the row.',
      'building_number' => 'Building number parsed from the source or normalized address.',
      'business_category' => 'Activity type from the source register.',
      'business_categories' => 'Business categories represented by licenses grouped into the sales point.',
      'business_count' => 'Number of distinct pseudonymized business keys represented in the sales point.',
      'business_key' => 'Stable pseudonymized business identifier; full source business names are not included by default.',
      'business_keys' => 'Distinct pseudonymized business identifiers represented in the sales point.',
      'category_a_license_count' => 'Number of category A licenses in the aggregation area and report.',
      'category_b_license_count' => 'Number of category B licenses in the aggregation area and report.',
      'category_c_license_count' => 'Number of category C licenses in the aggregation area and report.',
      'confidence' => 'Internal confidence score or label assigned by the correction or geocoding workflow.',
      'correction_id' => 'Stable public identifier of an address-correction provenance row.',
      'corrected_address_1' => 'Corrected primary address text used during normalization.',
      'corrected_address_2' => 'Corrected secondary address text used during normalization.',
      'crs' => 'Coordinate reference system used by latitude and longitude.',
      'display_address' => 'Display-ready address assembled from normalized address fields.',
      'evidence' => 'Short provenance evidence for an address correction.',
      'expires_at' => 'License expiry date from the source register, when available.',
      'expires_at_max' => 'Latest expiry date among licenses grouped into the sales point.',
      'file_format' => 'Source file format in the processing archive.',
      'first_reported_at' => 'First report timestamp in which this entity appears.',
      'gastronomy_flag' => 'True when the sales point has at least one gastronomy license in the report.',
      'gastronomy_license_count' => 'Number of gastronomy licenses in the sales point or aggregation area.',
      'geocoded' => 'True when the license has coordinates through its normalized location or grouped sales point.',
      'geocoded_license_count' => 'Number of license records with an assigned public coordinate.',
      'geocoded_license_percent' => 'Percent of license records in the report with an assigned public coordinate.',
      'geocoding_result_id' => 'Stable public identifier of a non-Google geocoding candidate.',
      'geocoding_source' => 'Selected public geocoding source used for the sales point location.',
      'geocoding_strategy' => 'Strategy used to obtain or select the coordinate.',
      'geocoding_precision' => 'Precision class of the selected coordinate.',
      'last_reported_at' => 'Last report timestamp in which this entity appears.',
      'license_categories' => 'Alcohol license categories represented in the sales point.',
      'license_category' => 'Alcohol license category from the source register.',
      'license_category_description' => 'Source description of the alcohol license category.',
      'license_count_a' => 'Number of category A licenses grouped into the sales point.',
      'license_count_b' => 'Number of category B licenses grouped into the sales point.',
      'license_count_c' => 'Number of category C licenses grouped into the sales point.',
      'licenses_per_1000_registered_residents' => 'License records per 1000 registered residents in the aggregation area.',
      'licenses_per_km2' => 'License records per square kilometre in the aggregation area.',
      'location_uncertain' => 'True when the selected location remains uncertain after automated and manual review.',
      'location_uncertainty_reasons' => 'Machine-readable reasons for location uncertainty.',
      'manual_geocoding_result_id' => 'Identifier of a manually created geocoding result, when used.',
      'manual_latitude' => 'Latitude manually assigned during review, if present.',
      'manual_longitude' => 'Longitude manually assigned during review, if present.',
      'membership_method' => 'Method used to link the license record to a sales point.',
      'method' => 'Correction or matching method used to produce the row.',
      'mixed_flag' => 'True when both retail and gastronomy categories are represented in the sales point.',
      'normalization_input_address_2' => 'Secondary address text used as input to the normalization step.',
      'notes' => 'Free-text release note or provenance note for the row.',
      'observed_on' => 'Date of the population snapshot.',
      'observed_on_code' => 'Compact date code for the population snapshot.',
      'original_filename' => 'Filename preserved from the source or intermediate extraction file.',
      'original_latitude' => 'Latitude before manual review, when recorded.',
      'original_longitude' => 'Longitude before manual review, when recorded.',
      'parcel_cadastral_unit' => 'Cadastral unit name or code for parcel-based addresses.',
      'parcel_number' => 'Parcel number for parcel-based source or normalized addresses.',
      'parcel_region' => 'Cadastral precinct or region for parcel-based addresses.',
      'point_id' => 'Stable identifier of an analytical sales point in one report.',
      'points_per_1000_registered_residents' => 'Sales points per 1000 registered residents in the aggregation area.',
      'points_per_km2' => 'Sales points per square kilometre in the aggregation area.',
      'population_snapshot_date' => 'Population snapshot date used for per-resident rates.',
      'population_total' => 'Registered resident count used for rate calculations.',
      'precision' => 'Geocoding precision class returned or assigned for the candidate result.',
      'query' => 'Query string sent to the public geocoder or constructed for the geocoding attempt.',
      'quality_signals' => 'JSON quality-control signals used during review.',
      'raw_location_count' => 'Number of raw source addresses linked to the normalized location.',
      'raw_location_ids' => 'Raw source location identifiers grouped into the sales point.',
      'relative_path' => 'Path of the source or intermediate file relative to the processing repository root.',
      'retrieved_at' => 'Timestamp when the local source-file copy was acquired or last preserved in the processing snapshot.',
      'row_count_extracted' => 'Number of data rows extracted from the intermediate source file, when applicable.',
      'row_count_imported' => 'Number of data rows imported from the intermediate source file, when applicable.',
      'retail_flag' => 'True when the sales point has at least one retail license in the report.',
      'retail_license_count' => 'Number of retail licenses in the sales point or aggregation area.',
      'retail_point_count' => 'Number of sales points with at least one retail license.',
      'review_id' => 'Stable public identifier of a geocoding review decision.',
      'review_status' => 'Outcome of the manual or semi-manual geocoding review.',
      'reviewed_at' => 'Timestamp when the geocoding review decision was recorded, when available.',
      'same_as' => 'Canonical normalized location identifier when this row is known to duplicate another location.',
      'selected' => 'True when the correction or geocoding result was selected for downstream processing.',
      'selected_geocoding_result_id' => 'Selected public geocoding candidate used for the normalized location.',
      'selected_geocoding_source' => 'Source of the selected public geocoding candidate.',
      'selected_geocoding_strategy' => 'Strategy used by the selected geocoding candidate.',
      'selected_geocoding_precision' => 'Precision class of the selected geocoding candidate.',
      'sha256' => 'SHA-256 checksum of the source or generated file.',
      'signal_category' => 'Review signal category that caused the location to be inspected.',
      'sim_circle_within_area' => 'True when a small circle around the reviewed point stays within the expected SIM unit.',
      'source' => 'Source system or processing step that produced the row.',
      'source_address_1' => 'Primary address text as preserved from the administrative source record.',
      'source_address_2' => 'Secondary address text as preserved from the administrative source record.',
      'source_file_id' => 'Stable identifier of the source or intermediate file listed in source_files_manifest.csv.',
      'source_origin' => 'Source-file origin class, such as BIP PDF, spreadsheet from public-information request, or extracted CSV.',
      'source_raw_location_id' => 'Raw location used as source evidence for an address correction.',
      'source_url' => 'Source landing page or file URL when known; blank means the original delivery URL was not preserved.',
      'strategy' => 'Geocoding strategy used for the candidate result.',
      'unit' => 'Measurement unit for the value in this row.',
      'unit_number' => 'Apartment, premises, or unit number when available.',
      'ungrouped_license_count' => 'Number of licenses not assigned to an analytical sales point in the report.'
    }.freeze

    def initialize(paths:)
      @paths = paths
    end

    def write
      write_readme
      write_codebook
      write_license
      write_notice
      write_citation
      write_datacite
      write_validation_report_md

      {
        readme: paths.readme_md.to_s,
        codebook: paths.codebook_md.to_s,
        license: paths.license.to_s,
        notice: paths.notice_md.to_s,
        citation: paths.citation_cff.to_s,
        datacite: paths.datacite_json.to_s,
        validation_report: paths.validation_report_md.to_s
      }
    end

    private

    attr_reader :paths

    def manifest
      @manifest ||= JSON.parse(paths.export_manifest_json.read)
    end

    def validation_report
      return nil unless paths.validation_report_json.exist?

      @validation_report ||= JSON.parse(paths.validation_report_json.read)
    end

    def package_report
      return nil unless paths.package_report_json.exist?

      @package_report ||= JSON.parse(paths.package_report_json.read)
    end

    def dataset
      manifest.fetch('dataset')
    end

    def files
      manifest.fetch('files')
    end

    def csv_files
      files.select { |file| file.fetch('format') == 'csv' }
    end

    def file_by_path(path)
      files.find { |file| file.fetch('path') == path }
    end

    def row_count(path)
      file_by_path(path)&.fetch('row_count')
    end

    def latest_report
      @latest_report ||= begin
        report_path = paths.release_root.join('data/tables/reports.csv')
        CSV.read(report_path, headers: true, encoding: 'UTF-8')[-1]
      end
    end

    def write_readme
      write_text(paths.readme_md, <<~MARKDOWN)
        # #{TITLE}

        This release contains a curated, geocoded dataset of alcohol-sale licenses and derived analytical sales points in Krakow, Poland. It supports reproducible spatial and longitudinal analysis for the accompanying manuscript.

        ## Scope

        - Dataset version: `#{dataset.fetch('version')}`
        - Generated at: `#{dataset.fetch('generated_at')}`
        - Time range: 2010-11-01 to 2026-02-06
        - Reports: #{row_count('data/tables/reports.csv')}
        - License records: #{row_count('data/tables/alcohol_licenses.csv')}
        - Sales-point rows across reports: #{row_count('data/tables/license_points.csv')}
        - Latest report sales points: #{latest_report&.fetch('point_count')}
        - Coordinate reference system: EPSG:4326

        ## Core Data Units

        - `license`: one administrative license record for one alcohol category and one activity type.
        - `license_point`: an analytical sales point derived by grouping geocoded licenses that refer to the same public sales location.
        - `point_membership`: a link between a license record and an analytical sales point.
        - `raw_location`: the canonical source address preserved from the register.
        - `normalized_location`: the corrected and normalized location used for geocoding.
        - `sim_unit`: a municipal spatial information unit used for spatial aggregation.

        ## Files

        See `CODEBOOK.md` for column-level documentation. CSV files are the canonical tabular release. Parquet files in `data/parquet/`, when present, are derived from CSV by `dataset:package`.

        Core analysis files are `reports.csv`, `alcohol_licenses.csv`, `license_points.csv`, `point_memberships.csv`, `locations_raw.csv`, `locations_normalized.csv`, `sim_populations.csv`, the aggregate CSV files, and the GeoJSON layers. Provenance/audit files are `source_files_manifest.csv`, `address_corrections.csv`, `geocoding_results.csv`, and `geocoding_reviews.csv`.

        ## Quick Start: Python

        ```python
        import pandas as pd
        import geopandas as gpd

        licenses = pd.read_csv("data/tables/alcohol_licenses.csv")
        points = gpd.read_file("data/geospatial/license_points_latest.geojson")

        latest_report = pd.read_csv("data/tables/reports.csv").sort_values("report_date").iloc[-1]
        print(latest_report[["report_date", "license_count", "point_count"]])
        ```

        ## Analysis Examples

        Count sales points in the latest report:

        ```python
        import pandas as pd

        reports = pd.read_csv("data/tables/reports.csv").sort_values("report_date")
        latest = reports.iloc[-1]
        print(latest["report_date"], latest["point_count"])
        ```

        Join license records to their analytical sales points:

        ```python
        import pandas as pd

        licenses = pd.read_csv("data/tables/alcohol_licenses.csv")
        memberships = pd.read_csv("data/tables/point_memberships.csv")
        points = pd.read_csv("data/tables/license_points.csv")

        license_points = (
            licenses.drop(columns=["point_id"], errors="ignore")
                    .merge(memberships[["license_id", "point_id"]], on="license_id")
                    .merge(points[["point_id", "display_address", "latitude", "longitude"]], on="point_id", how="left")
        )
        ```

        Reproduce the Kazimierz sales-point change quoted in the manuscript:

        ```python
        import pandas as pd

        sim = pd.read_csv("data/aggregates/sim_summary_by_report.csv")
        kazimierz = sim[sim["area_name"].eq("Kazimierz")].sort_values("report_date")
        first, latest = kazimierz.iloc[0], kazimierz.iloc[-1]
        change = (latest["point_count"] - first["point_count"]) / first["point_count"] * 100
        print(first["point_count"], latest["point_count"], round(change, 1))
        ```

        ## Quick Start: R

        ```r
        library(readr)
        library(sf)

        licenses <- read_csv("data/tables/alcohol_licenses.csv")
        points <- st_read("data/geospatial/license_points_latest.geojson")
        ```

        ## Quick Start: QGIS

        Open `data/geospatial/license_points_latest.geojson` and `data/geospatial/sim_units.geojson`. Join tabular CSV files by stable identifiers such as `point_id`, `report_id`, `sim_unit_code`, and `district_code`.

        ## Citation

        Use `CITATION.cff` or `metadata/datacite.json`. Dataset DOI: `#{DATASET_DOI}` (`#{DATASET_DOI_URL}`).

        ## License And Attribution

        Dataset license: CC BY 4.0 for the curated dataset, codebook, and generated documentation, subject to rights in third-party source data. See `LICENSE` and `NOTICE.md`.

        ## Known Limitations

        - A license record is not the same thing as a sales point; one location may have several licenses.
        - Sales points are analytical groupings, not official venue records or confirmed shop signs.
        - Some source addresses are ambiguous, historical, parcel-based, or descriptive.
        - Google-derived coordinates and raw Google responses are excluded from the public dataset.
        - Business names are not included by default because source registers may contain personal names of sole proprietorships.
      MARKDOWN
    end

    def write_license
      write_text(paths.license, <<~TEXT)
        Creative Commons Attribution 4.0 International (CC BY 4.0)

        Copyright (c) #{Date.today.year} #{CREATOR}

        The curated dataset, metadata, codebook, and generated documentation in this
        release are licensed under the Creative Commons Attribution 4.0 International
        License.

        You are free to share and adapt the licensed material for any purpose,
        including commercial use, under the attribution terms of CC BY 4.0:

        https://creativecommons.org/licenses/by/4.0/

        Attribution should include the dataset title, creator, version, release year,
        a link to the dataset landing page or repository, and an indication that the
        material has been processed from public administrative and spatial sources.

        This license applies to the curator's selection, normalization, identifiers,
        derived tables, documentation, and metadata. It does not override rights,
        statutory restrictions, or attribution duties attached to third-party source
        data described in NOTICE.md.

        No warranties are given. The dataset is provided as a processed research
        dataset and is not an official register of the Municipality of Krakow.
      TEXT
    end

    def write_codebook
      sections = files.map do |file|
        path = file.fetch('path')
        body = [
          "## `#{path}`",
          '',
          FILE_DESCRIPTIONS.fetch(path, file.fetch('description')),
          '',
          "- Format: `#{file.fetch('format')}`",
          "- Row count: #{file.fetch('row_count')}",
          "- SHA-256: `#{file.fetch('sha256')}`"
        ]

        if file.fetch('format') == 'csv'
          body << ''
          body << '| Column | Type | Nullable | Description | Values / Units |'
          body << '|---|---:|---:|---|---|'
          column_profiles(path).each do |profile|
            body << "| `#{profile.fetch(:name)}` | #{profile.fetch(:type)} | #{profile.fetch(:nullable) ? 'yes' : 'no'} | #{column_description(profile.fetch(:name))} | #{column_values(profile)} |"
          end
        elsif path.end_with?('.geojson')
          body << ''
          body << 'GeoJSON uses EPSG:4326. Point coordinates are `[longitude, latitude]`; polygon coordinates follow standard GeoJSON ring order.'
        end

        body.join("\n")
      end

      write_text(paths.codebook_md, <<~MARKDOWN)
        # Codebook

        This codebook was generated from `metadata/export_manifest.json` and release files. CSV type information is inferred from exported values; Parquet schemas, when present, are recorded in `metadata/package_report.json`.

        #{sections.join("\n\n")}
      MARKDOWN
    end

    def write_notice
      write_text(paths.notice_md, <<~MARKDOWN)
        # Notice

        This dataset is a processed, curated research dataset derived from public administrative records and municipal spatial data. It is not an official publication of the Municipality of Krakow.

        ## Reuse Review

        Recommended release license: CC BY 4.0 for the curated dataset. CC BY 4.0 was selected instead of CC0 because the source-data chain requires attribution, processing notices, and responsibility disclaimers.

        Public-sector information from the Municipality of Krakow may be reused when source, production/acquisition time, processing information, and the municipality's responsibility disclaimer are provided, unless a specific dataset has separate terms. Data obtained on request may have separate conditions in the authority's response; those conditions must be checked before publishing source files or exact full source-file mirrors.

        MSIP data use is governed by the MSIP regulation. The portal requires attribution to "Gmina Miejska Kraków, Portal MSIP Obserwatorium (https://msip.krakow.pl)" and notes that maps/prints are indicative rather than legally binding. MSIP catalog entries for population data state that use is subject to the MSIP regulation.

        ULDK/GUGiK and related geodetic services were used as geocoding support for parcel-based locations. Published fields should cite GUGiK/ULDK when the selected geocoding source is `uldk` or related GUS/GUGiK reference data.

        OpenStreetMap/Nominatim-derived records require OpenStreetMap attribution. The public geocoding-results table excludes raw provider responses and should be read as provenance, not as a full redistributed OSM database.

        ## Sources

        - Alcohol-license registers: public registers of establishments holding alcohol-sale licenses in the Municipality of Krakow, including files published in the Public Information Bulletin and spreadsheet files obtained through access to public information.
        - Municipal spatial information: SIM unit boundaries and registered-resident counts used for spatial aggregation and rate calculations.
        - Address and parcel support data: municipal address evidence, ULDK/GUS/TERYT-derived references where used during normalization and geocoding.
        - OpenStreetMap/Nominatim: used for selected non-Google geocoding and quality-control workflows. OpenStreetMap data is available under the Open Database License.

        ## Processing

        The source records were extracted, normalized, corrected where necessary, geocoded, manually reviewed in selected cases, grouped into analytical sales points, and aggregated by city, district, and SIM unit.

        ## Responsibility

        The Municipality of Krakow and other source-data providers are not responsible for the processing, grouping, geocoding, interpretation, or errors introduced in this derived dataset.

        ## Google Data Exclusion

        Google coordinates and raw Google geocoding responses are not published in this release. Google may be mentioned only as a comparative quality-control source in processing documentation.

        ## Business Names

        The default release does not publish full business names because source registers can include names of sole proprietorships or natural persons conducting business. Public identifiers such as `business_key` and aggregate counts are used instead. If a separate provenance layer with business names is generated, it must be documented and reviewed before publication.

        ## Release Review

        The release archive excludes full Google geocoding output, local SQLite databases, cache files, and processing-repository metadata. Spreadsheet files obtained through access to public information are represented in `source_files_manifest.csv`; exact source-file mirrors are not included in the default Zenodo archive.

        ## Prepared

        Release generated at `#{dataset.fetch('generated_at')}`.
      MARKDOWN
    end

    def write_citation
      write_text(paths.citation_cff, <<~YAML)
        cff-version: 1.2.0
        message: "If you use this dataset, please cite it using these metadata."
        title: "#{TITLE}"
        type: dataset
        authors:
          - family-names: "Ciemborowicz"
            given-names: "Maciej"
            orcid: "#{CREATOR_ORCID}"
        version: "#{dataset.fetch('version')}"
        doi: "#{DATASET_DOI}"
        url: "#{DATASET_DOI_URL}"
        date-released: "#{Date.today.iso8601}"
        abstract: "#{DESCRIPTION}"
        keywords:
        #{KEYWORDS.map { |keyword| "  - \"#{keyword}\"" }.join("\n")}
        license: "CC-BY-4.0"
      YAML
    end

    def write_datacite
      DatasetExport::JsonWriter.write(paths.datacite_json, {
        types: {
          resourceTypeGeneral: 'Dataset',
          resourceType: 'Dataset'
        },
        creators: [
          {
            name: CREATOR,
            nameType: 'Personal',
            familyName: 'Ciemborowicz',
            givenName: 'Maciej',
            nameIdentifiers: [
              {
                nameIdentifier: CREATOR_ORCID,
                nameIdentifierScheme: 'ORCID',
                schemeUri: 'https://orcid.org/'
              }
            ]
          }
        ],
        identifiers: [
          {
            identifier: DATASET_DOI,
            identifierType: 'DOI'
          }
        ],
        titles: [{ title: TITLE }],
        publisher: CREATOR,
        publicationYear: Date.today.year,
        version: dataset.fetch('version'),
        descriptions: [
          {
            description: DESCRIPTION,
            descriptionType: 'Abstract'
          }
        ],
        subjects: KEYWORDS.map { |keyword| { subject: keyword } },
        rightsList: [
          {
            rights: 'Creative Commons Attribution 4.0 International',
            rightsUri: 'https://creativecommons.org/licenses/by/4.0/',
            schemeUri: 'https://spdx.org/licenses/',
            rightsIdentifierScheme: 'SPDX',
            rightsIdentifier: 'CC-BY-4.0'
          }
        ]
      })
    end

    def write_validation_report_md
      report = validation_report
      unless report
        write_text(paths.validation_report_md, "# Validation Report\n\nValidation has not been run for this release.\n")
        return
      end

      checks = report.fetch('checks')
      failed = checks.reject { |check| check.fetch('passed') }
      lines = [
        '# Validation Report',
        '',
        "- Generated at: `#{report.fetch('generated_at')}`",
        "- Passed: #{report.fetch('passed')}",
        "- Checks: #{checks.size}",
        "- Failed checks: #{failed.size}",
        ''
      ]

      if failed.any?
        lines << '## Failed Checks'
        lines << ''
        failed.each do |check|
          lines << "- `#{check.fetch('name')}` expected `#{check.fetch('expected')}`, actual `#{check.fetch('actual')}`"
        end
      else
        lines << 'All validation checks passed.'
      end

      write_text(paths.validation_report_md, "#{lines.join("\n")}\n")
    end

    def column_profiles(relative_path)
      path = paths.release_root.join(relative_path)
      headers = CSV.open(path, 'r:UTF-8', &:readline)
      profiles = headers.map do |header|
        { name: header, nullable: false, values_seen: 0, type: 'integer', enum_values: {} }
      end

      CSV.foreach(path, headers: true, encoding: 'UTF-8') do |row|
        profiles.each do |profile|
          value = row[profile.fetch(:name)]
          if value.nil? || value == ''
            profile[:nullable] = true
            next
          end

          profile[:values_seen] += 1
          profile[:type] = widen_type(profile.fetch(:type), inferred_type(value))
          profile[:enum_values][value] = true if profile[:enum_values].size < 20 && value.length <= 40
        end
      end

      profiles
    end

    def inferred_type(value)
      return 'boolean' if %w[true false].include?(value.downcase)
      return 'integer' if value.match?(/\A-?\d+\z/)
      return 'number' if value.match?(/\A-?\d+(\.\d+)?\z/)
      return 'date' if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      return 'datetime' if value.match?(/\A\d{4}-\d{2}-\d{2}T/)
      return 'json' if json_value?(value)

      'string'
    end

    def widen_type(current, incoming)
      return current if current == incoming
      return 'number' if [current, incoming].sort == %w[integer number]
      return incoming if current == 'integer'

      'string'
    end

    def json_value?(value)
      return false unless value.start_with?('[', '{')

      JSON.parse(value)
      true
    rescue JSON::ParserError
      false
    end

    def column_description(column)
      return COLUMN_DESCRIPTIONS.fetch(column) if COLUMN_DESCRIPTIONS.key?(column)

      case column
      when /_id\z/
        'Stable public identifier generated from dataset content. Database primary keys are not exported in the public release.'
      when /reported_at/
        'Report timestamp in ISO 8601.'
      when /report_date/
        'Report date.'
      when /latitude/
        'Latitude in EPSG:4326.'
      when /longitude/
        'Longitude in EPSG:4326.'
      when /count\z/
        'Count of records or entities described by the column name.'
      when /percent\z/
        'Percentage value.'
      when /flag\z/
        'Boolean flag encoded as true/false.'
      when /sim_unit/
        'SIM unit code or name used for spatial aggregation.'
      when /district/
        'Krakow district code or name.'
      else
        'See README and public model documentation for semantic context.'
      end
    end

    def column_values(profile)
      name = profile.fetch(:name)
      return ENUM_COLUMNS.fetch(name) if ENUM_COLUMNS.key?(name)
      return 'EPSG:4326 degrees.' if %w[latitude longitude].include?(name)
      return 'ISO 8601.' if profile.fetch(:type).match?(/\Adate/)
      return 'JSON array/object.' if profile.fetch(:type) == 'json'

      values = profile.fetch(:enum_values).keys
      values.size.between?(1, 8) ? values.join(', ') : ''
    end

    def write_text(path, text)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, text, encoding: 'UTF-8')
    end
  end
end
