# Publication repository

The processing repository remains:

`/Users/maciej/Projects/alcohol_permits_map`

The publication staging repository is separate and lives one level higher:

`/Users/maciej/Projects/krakow-alcohol-licenses`

This separation keeps generated publication artifacts out of the working
application/code repository. The publication repository is intended to contain
only Zenodo-facing material:

- release ZIP archives,
- checksums,
- DataCite metadata,
- citation metadata,
- validation reports,
- short Zenodo upload notes.

## Target Repository

Target publication service: Zenodo.

Zenodo records consist of metadata, files and a persistent DOI. The release ZIP
should be uploaded as a dataset record. Zenodo can reserve a DOI before
publication, which is useful if the DOI must be written back into `CITATION.cff`,
`metadata/datacite.json` or article text before final upload.

## Local Staging Command

After `dataset:release` has generated and packaged a release:

```sh
DISABLE_SPRING=1 bin/rails dataset:prepare_publication_repo \
  VERSION=v1.0.0 \
  OUTPUT_DIR=tmp/dataset_release \
  PUBLISH_DIR=/Users/maciej/Projects/krakow-alcohol-licenses
```

Expected staging layout:

```text
/Users/maciej/Projects/krakow-alcohol-licenses/
  README.md
  ZENODO.md
  .gitignore
  releases/
    v1.0.0/
      krakow-alcohol-licenses-2010-2026-v1.0.0.zip
      checksums.txt
      CITATION.cff
      metadata/
        datacite.json
        export_manifest.json
        package_report.json
        validation_report.json
        validation_report.md
```

Do not stage raw source mirrors until the reuse terms for spreadsheet files
obtained on request are confirmed.
