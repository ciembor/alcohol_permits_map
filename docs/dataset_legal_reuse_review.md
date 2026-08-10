# Dataset legal and reuse review

This note records the reuse decisions for the open dataset release. It is an
engineering and publication checklist, not legal advice.

Checked on: 2026-08-10

## License Choice

Decision: publish the curated dataset under CC BY 4.0.

Reasoning:

- CC BY 4.0 permits sharing and adaptation, including commercial use, with
  attribution and indication of changes.
- CC0 is not appropriate for this release because source information from GMK,
  MSIP and OpenStreetMap/Nominatim requires attribution and processing notices.
- The license applies to the curated dataset, stable identifiers, derived
  tables, codebook, metadata and generated documentation. It does not remove
  third-party source-data duties listed in `NOTICE.md`.

## Source Terms Checked

### BIP / Gmina Miejska Krakow

Status: checked for public BIP and municipal online sources.

The BIP reuse page states that public-sector information made available in GMK
teleinformation systems, including BIP and other municipal websites, may be
reused under conditions requiring:

- source, production time and acquisition time attribution;
- information that the reused information has been processed;
- inclusion of GMK responsibility-disclaimer language.

Dataset action:

- `NOTICE.md` includes source attribution, processing statement and responsibility
  disclaimer.
- `README.md` points users to `NOTICE.md`.

### Spreadsheet files obtained on request

Status: publication blocker for source-file redistribution; not a blocker for
derived aggregate/geocoded research tables if no special terms were attached.

No local response letter or reuse offer was found in the repository. Before
publishing raw source files or exact mirrors of historical spreadsheets, confirm
whether the authority's response included specific reuse conditions, fees or
restrictions.

Dataset action:

- Keep `INCLUDE_SOURCE_FILES=0` for the public release until this is confirmed.
- Publish derived tables with source attribution and processing notices.

### MSIP Krakow

Status: checked.

The MSIP regulation says the portal data are public, generally available unless
restricted by law, and requires attribution to the portal. It also states that
maps and prints are indicative and not legally binding, and that reuse of public
sector information follows separate rules for PZGiK/MSIP data and general public
sector information where not otherwise regulated.

Dataset action:

- `NOTICE.md` attributes "Gmina Miejska Krakow, Portal MSIP Obserwatorium
  (https://msip.krakow.pl)".
- Dataset documentation treats SIM boundaries and population as processed
  analytical inputs, not official legal geometry or population registers.

### ULDK / GUGiK / GUS references

Status: checked for ULDK service identity and API documentation; final repository
attribution remains required.

ULDK is a GUGiK service for locating cadastral parcels by identifier, parcel
number/region or coordinates. It was used only as a geocoding support source for
selected parcel-based records.

Dataset action:

- `NOTICE.md` attributes ULDK/GUGiK and GUS/TERYT-derived references.
- Raw provider responses are not published.

### OpenStreetMap / Nominatim

Status: checked.

OpenStreetMap data is distributed under ODbL and requires OpenStreetMap
attribution for public use. The Nominatim public service usage policy requires
clear attribution and operational usage constraints; the published dataset should
not imply that OSMF endorses the derived dataset.

Dataset action:

- `NOTICE.md` attributes OpenStreetMap/Nominatim.
- The public export excludes raw provider responses.

### Google

Status: implemented exclusion.

Google was used as comparative quality-control material only. Public exports
exclude Google coordinates and raw Google geocoding responses.

Dataset action:

- `geocoding_results.csv` excludes `source = google`.
- `locations_normalized.csv` does not publish Google columns.
- `NOTICE.md` states that Google is not a source of published coordinates.

## Business Names

Decision: default public release does not publish full business names.

Reasoning:

- Source registers contain names of entrepreneurs and may include sole
  proprietorships or natural persons conducting business.
- Most scientific use cases need counts, categories, locations and stable
  public business keys, not full names.

Dataset action:

- `INCLUDE_BUSINESS_NAMES=0` is the default.
- Public tables use `business_key`, `business_count` and category counts.
- A business-name provenance layer may be generated only after separate review.

## Remaining Publication Blockers

- Confirm terms attached to historical spreadsheet files obtained on request.
- Add final dataset landing URL and DOI to `CITATION.cff` and
  `metadata/datacite.json`.
- Re-check source terms immediately before final public release.
