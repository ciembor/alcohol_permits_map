# Alcohol licenses in Kraków
## About


This repository processes Kraków alcohol-license reports into normalized
locations, geocoding provenance, analytical sales points, and an open dataset
release prepared for Zenodo.

## Prerequisites
* ruby (see `ruby_version`, install via rbenv, rvm or whatever you want)
* bundler
* python (for pdf importer, see `vendor/extractor/Pipfile`)

## Setup
```
rake db:create
rake db:migrate
rake db:seed
```

## Tasks
```
bin/rails source_data:import_csv_reports
bin/rails source_data:import_spreadsheet_reports
bin/rails source_data:import_license_reports
bin/rails streets:import_simc                # Import TERC/SIMC street dictionary
bin/rails sim:import_population              # Import historical SIM population totals
bin/rails locations:infer_address_corrections
bin/rails locations:normalize

bin/rails geocoding:krakow_msip_address_points
bin/rails geocoding:gus_address_points
bin/rails geocoding:uldk_parcels
bin/rails geocoding:osm_missing_locations
bin/rails geocoding:sync_osm_locations
bin/rails geocoding:google                  # Optional Google quality-control pass

bin/rails license_point_groups:rebuild ALL=1
bin/rails grouping_audit:write

bin/rails dataset:release
bin/rails dataset:prepare_publication_repo
```

## Research Pipeline
```
bin/rails research:import_sources
bin/rails research:normalize_locations
bin/rails research:geocode_open
bin/rails research:geocode_google_quality_control  # optional
bin/rails research:rebuild_analysis
bin/rails research:write_grouping_audit
bin/rails research:release_dataset
bin/rails research:prepare_zenodo_repository
```

Full open-data pipeline, without Google quality-control geocoding:

```
bin/rails research:full_open_pipeline
```

## Paths
XLSX / XLS files as well as downloaded pdfs and SIMC streets are in `vendor/data/*`

## For developers
* ERD Diagram: [docs/erd.pdf](docs/erd.pdf)
* Specs, coding style: Look ma, no hands.
