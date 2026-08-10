# Plan publikacji otwartego datasetu

## Cel

Przygotowac wersjonowany pakiet danych do publikacji jako otwarty dataset wspierajacy manuskrypt pracy.

Dataset ma byc uzyteczny dla innych naukowcow bez koniecznosci uruchamiania aplikacji Rails. Ma zawierac:

- gotowe tabele analityczne,
- warstwy przestrzenne,
- dane o pochodzeniu rekordow,
- jawne korekty i audyt geokodowania,
- slownik pol,
- walidacje,
- manifest zrodel,
- metadane cytowania i licencji.

## Zasady projektowe

- [ ] Eksporty sa generowane bezposrednio z aktualnej bazy, a nie z recznie utrzymywanych CSV.
- [ ] Kazdy release datasetu ma stabilny numer wersji, np. `v1.0.0`.
- [ ] Kazdy release ma osobny katalog wynikowy, np. `tmp/dataset_release/v1.0.0`.
- [ ] Kazdy plik wynikowy ma wpis w `metadata/export_manifest.json`.
- [ ] Kazdy plik wynikowy ma checksum SHA-256 w `checksums.txt`.
- [ ] Dane przestrzenne uzywaja `EPSG:4326`.
- [ ] Publiczne nazwy kolumn uzywaja `longitude`, nie wewnetrznej literowki `longtitude`.
- [ ] Dane Google nie sa publikowane jako wynik datasetu.
- [ ] Google moze zostac opisany w metadanych jako zrodlo porownawcze kontroli jakosci, bez eksportu wspolrzednych i `raw_response`.
- [ ] Pelne surowe odpowiedzi geokoderow nie sa publikowane w pierwszym release.
- [ ] Dane pozwalaja odroznic zezwolenie od punktu sprzedazy.
- [ ] Dane pozwalaja przejsc sciezke: zezwolenie -> adres zrodlowy -> adres znormalizowany -> wynik geokodowania -> punkt sprzedazy.

## Docelowa struktura pakietu

```text
krakow-alcohol-licenses-2010-2026-v1.0.0/
  README.md
  CODEBOOK.md
  LICENSE
  NOTICE.md
  CITATION.cff
  checksums.txt

  metadata/
    datacite.json
    export_manifest.json
    package_report.json
    validation_report.json
    validation_report.md

  data/
    tables/
      reports.csv
      alcohol_licenses.csv
      license_points.csv
      point_memberships.csv
      locations_raw.csv
      locations_normalized.csv
      address_corrections.csv
      geocoding_results.csv
      geocoding_reviews.csv
      sim_populations.csv
      source_files_manifest.csv

    parquet/
      tables/
        reports.parquet
        alcohol_licenses.parquet
        license_points.parquet
        point_memberships.parquet
        locations_raw.parquet
        locations_normalized.parquet
        address_corrections.parquet
        geocoding_results.parquet
        geocoding_reviews.parquet
        sim_populations.parquet
      aggregates/
        city_summary_by_report.parquet
        district_summary_by_report.parquet
        sim_summary_by_report.parquet

    geospatial/
      license_points.gpkg
      license_points_latest.geojson
      sim_units.gpkg
      sim_units.geojson

    aggregates/
      city_summary_by_report.csv
      district_summary_by_report.csv
      sim_summary_by_report.csv
```

## Backlog wykonawczy

### 1. Ustalenie publicznego modelu danych

- [x] Spisac publiczne definicje jednostek danych:
  - [x] `license` - pojedynczy rekord administracyjny zezwolenia.
  - [x] `raw_location` - adres zrodlowy z wykazu.
  - [x] `normalized_location` - lokalizacja po normalizacji i korektach.
  - [x] `business` - nazwa podmiotu z wykazu lub jej publiczny identyfikator.
  - [x] `license_point` - analityczny punkt sprzedazy w konkretnej dacie raportu.
  - [x] `report` - jedna data raportu BIP/urzedowego.
  - [x] `sim_unit` - jednostka SIM uzyta do agregacji przestrzennej.
- [x] Spisac roznice miedzy `license_count` i `point_count`.
- [x] Spisac zasade, ze `license_point` nie jest urzedowym lokalem ani szyldem, tylko grupa analityczna.
- [x] Zdecydowac, czy w publicznym release publikujemy pelne nazwy podmiotow:
  - [ ] wariant A: pelne nazwy w `business_name`;
  - [x] wariant B: tylko `business_key` i liczebnosci;
  - [x] wariant C: pelne nazwy w osobnym, wyraznie oznaczonym pliku provenance.
- [ ] Spisac konsekwencje wyboru w `NOTICE.md`.

### 2. Stabilne identyfikatory publiczne

- [x] Dodac warstwe publicznych identyfikatorow niezalezna od Railsowych `id`.
- [x] Zaprojektowac format `report_id`:
  - [x] np. `report-2010-11-01T00-00-00Z`;
  - [x] daty raportow w UTC i dodatkowe pole `report_date`.
- [x] Zaprojektowac format `source_file_id`:
  - [x] hash/slug z `reported_at`, `business_category`, `license_category`, `format`;
  - [x] stabilny nawet po zmianie lokalnej sciezki pliku.
- [x] Zaprojektowac format `license_id`:
  - [ ] docelowo `source_file_id + source_row_number`;
  - [x] tymczasowo hash z `reported_at`, `business_category`, `license_category`, `business_name`, `source_address_1`, `source_address_2`, `expires_at`.
- [x] Zaprojektowac format `raw_location_id`:
  - [x] hash z `source_address_1` i `source_address_2`.
- [x] Zaprojektowac format `normalized_location_id`:
  - [x] hash z `address_1`, `building_number`, `address_kind`, `address_relation`, `unit_number`, `parcel_number`, `parcel_region`, `parcel_cadastral_unit`.
- [x] Zaprojektowac format `point_id`:
  - [x] hash z `reported_at`, `normalized_location_id`, `unit_number`, `normalized_business_name` albo `license_point_group_id` mapowanym przez stabilne skladniki.
- [x] Dodac test, ze identyfikatory sa deterministyczne przy powtorzonym eksporcie.
- [x] Dodac test, ze identyfikatory nie zawieraja danych wrazliwych wprost, jesli wybierzemy wariant z pseudonimizacja nazw.

### 3. Domkniecie metadanych zrodel

- [x] Zbudowac `source_files_manifest.csv`.
- [x] Dla kazdego pliku zrodlowego zapisac:
  - [x] `source_file_id`;
  - [x] `reported_at`;
  - [x] `report_date`;
  - [x] `business_category`;
  - [x] `license_category`;
  - [x] `file_format`;
  - [x] `original_filename`;
  - [x] `relative_path`;
  - [x] `source_origin`;
  - [x] `source_url` jesli jest znany;
  - [x] `retrieved_at` jesli jest znany;
  - [x] `sha256`;
  - [x] `row_count_extracted`;
  - [x] `row_count_imported`;
  - [x] `notes`.
- [x] Sprawdzic, czy import CSV/PDF pozwala odtworzyc `source_row_number`.
- [x] Sprawdzic, czy import XLS/XLSX pozwala odtworzyc `source_row_number`.
- [ ] Jesli nie, dodac migracje albo pomocnicza tabele `license_source_records`.
- [ ] Dodac zadanie naprawcze przypisujace istniejacym rekordom `source_file_id` i `source_row_number`, jesli da sie to zrobic deterministycznie.
- [ ] Jesli nie da sie przypisac w 100%, opisac ograniczenie w `README.md` i `CODEBOOK.md`.

### 4. Eksporter - architektura

- [x] Utworzyc namespace `DatasetExport`.
- [x] Utworzyc katalog `app/services/dataset_export/`.
- [x] Utworzyc katalog testow `test/services/dataset_export/`.
- [x] Utworzyc rake taski:
  - [x] `dataset:export`;
  - [x] `dataset:validate`;
  - [x] `dataset:package`;
  - [x] `dataset:clean`;
  - [x] `dataset:release`.
- [x] `dataset:export` przyjmuje parametry:
  - [x] `VERSION=v1.0.0`;
  - [x] `OUTPUT_DIR=tmp/dataset_release`;
  - [x] `INCLUDE_BUSINESS_NAMES=0|1`;
  - [x] `INCLUDE_SOURCE_FILES=0|1`;
  - [x] `LATEST_ONLY=0|1` do szybkich testow.
- [x] Utworzyc klase `DatasetExport::Runner`.
- [x] Utworzyc klase `DatasetExport::Config`.
- [x] Utworzyc klase `DatasetExport::Paths`.
- [x] Utworzyc klase `DatasetExport::CsvWriter`.
- [x] Utworzyc klase `DatasetExport::JsonWriter`.
- [x] Utworzyc klase `DatasetExport::ChecksumWriter`.
- [x] Utworzyc klase `DatasetExport::ManifestWriter`.
- [x] Utworzyc klase `DatasetExport::Validator`.
- [x] Utworzyc klase `DatasetExport::StableId`.
- [x] Utworzyc klase `DatasetExport::LicenseRows`.
- [x] Utworzyc klase `DatasetExport::PointRows`.
- [x] Utworzyc klase `DatasetExport::AggregateRows`.
- [x] Utworzyc klase `DatasetExport::GeospatialWriter`.
- [x] Utworzyc klase `DatasetExport::DocumentationWriter`.

### 5. Eksport `reports.csv`

- [x] Zbudowac exporter `DatasetExport::ReportsExporter`.
- [x] Jeden wiersz = jedna data raportu.
- [x] Kolumny:
  - [x] `report_id`;
  - [x] `reported_at`;
  - [x] `report_date`;
  - [x] `license_count`;
  - [x] `geocoded_license_count`;
  - [x] `geocoded_license_percent`;
  - [x] `point_count`;
  - [x] `ungrouped_license_count`;
  - [x] `source_file_count`;
  - [x] `population_snapshot_date`;
  - [x] `notes`.
- [x] Walidacje:
  - [x] liczba raportow = 64;
  - [x] pierwszy raport = `2010-11-01`;
  - [x] ostatni raport = `2026-02-06 08:43:09`;
  - [x] suma `license_count` = 458408.

### 6. Eksport `alcohol_licenses.csv`

- [x] Zbudowac exporter `DatasetExport::AlcoholLicensesExporter`.
- [x] Jeden wiersz = jedno zezwolenie.
- [x] Kolumny:
  - [x] `license_id`;
  - [x] `internal_license_id`;
  - [x] `report_id`;
  - [x] `reported_at`;
  - [x] `report_date`;
  - [x] `expires_at`;
  - [x] `business_category`;
  - [x] `license_category`;
  - [x] `license_category_description`;
  - [x] `business_key`;
  - [x] `business_name` jesli `INCLUDE_BUSINESS_NAMES=1`;
  - [x] `raw_location_id`;
  - [x] `normalized_location_id`;
  - [x] `point_id`;
  - [x] `source_address_1`;
  - [x] `source_address_2`;
  - [x] `source_file_id`;
  - [x] `source_row_number`;
  - [x] `geocoded`;
  - [x] `latitude`;
  - [x] `longitude`;
  - [x] `sim_unit_code`;
  - [x] `sim_unit_name`;
  - [x] `district_code`;
  - [x] `district_name`.
- [x] Nie eksportowac `created_at` i `updated_at`.
- [x] Nie eksportowac surowych odpowiedzi geokoderow.
- [x] Walidacje:
  - [x] liczba wierszy = 458408;
  - [x] brak pustego `license_id`;
  - [x] brak duplikatow `license_id`;
  - [x] kazdy `point_id` istnieje w `license_points.csv` albo jest pusty tylko dla niegeokodowanych rekordow;
  - [x] kategorie dzialalnosci tylko `detal`, `gastronomia`;
  - [x] kategorie zezwolen tylko `A`, `B`, `C`.

### 7. Eksport `license_points.csv`

- [x] Zbudowac exporter `DatasetExport::LicensePointsExporter`.
- [x] Jeden wiersz = jeden punkt sprzedazy w jednej dacie raportu.
- [x] Punkt sprzedazy liczyc zgodnie z logika `LicensePointGroupBuilder` i mapy.
- [x] Kolumny:
  - [x] `point_id`;
  - [x] `internal_license_point_group_id`;
  - [x] `report_id`;
  - [x] `reported_at`;
  - [x] `report_date`;
  - [x] `latitude`;
  - [x] `longitude`;
  - [x] `crs`;
  - [x] `normalized_location_id`;
  - [x] `raw_location_ids`;
  - [x] `display_address`;
  - [x] `address_1`;
  - [x] `building_number`;
  - [x] `unit_number`;
  - [x] `address_kind`;
  - [x] `address_relation`;
  - [x] `parcel_number`;
  - [x] `parcel_region`;
  - [x] `parcel_cadastral_unit`;
  - [x] `business_key`;
  - [x] `display_business_name` jesli `INCLUDE_BUSINESS_NAMES=1`;
  - [x] `business_keys`;
  - [x] `business_names` jesli `INCLUDE_BUSINESS_NAMES=1`;
  - [x] `business_count`;
  - [x] `business_id_count`;
  - [x] `license_count`;
  - [x] `license_categories`;
  - [x] `license_count_a`;
  - [x] `license_count_b`;
  - [x] `license_count_c`;
  - [x] `business_categories`;
  - [x] `retail_license_count`;
  - [x] `gastronomy_license_count`;
  - [x] `retail_flag`;
  - [x] `gastronomy_flag`;
  - [x] `mixed_flag`;
  - [x] `similarity_floor`;
  - [x] `geocoding_source`;
  - [x] `geocoding_strategy`;
  - [x] `geocoding_precision`;
  - [x] `geocoding_query`;
  - [x] `location_uncertain`;
  - [x] `location_uncertainty_reasons`;
  - [x] `latest_review_status`;
  - [x] `sim_unit_code`;
  - [x] `sim_unit_name`;
  - [x] `district_code`;
  - [x] `district_name`;
  - [x] `expires_at_max`.
- [x] Listy wielowartosciowe zapisac jako JSON w komorkach CSV albo jako `|` po jednoznacznej decyzji.
- [x] Walidacje:
  - [x] liczba punktow dla `2026-02-06 08:43:09` = 3019;
  - [x] liczba punktow dla `2010-11-01` = 2606;
  - [x] suma punktow po wszystkich raportach = 173821;
  - [x] brak punktow bez `latitude`/`longitude`;
  - [x] wspolrzedne mieszcza sie w oczekiwanym bounding box Krakowa;
  - [x] `license_count` zgadza sie z `point_memberships.csv`.

### 8. Eksport `point_memberships.csv`

- [x] Zbudowac exporter `DatasetExport::PointMembershipsExporter`.
- [x] Jeden wiersz = stan przypisania jednego zezwolenia do punktu sprzedazy; rekordy niegeokodowane sa zachowane z pustym `point_id`.
- [x] Kolumny:
  - [x] `point_id`;
  - [x] `license_id`;
  - [x] `report_id`;
  - [x] `internal_license_point_group_id`;
  - [x] `internal_license_id`;
  - [x] `membership_method`.
- [x] `membership_method`:
  - [x] `license_point_group`;
  - [x] `fallback_business_location`;
  - [x] `not_geocoded`.
- [x] Walidacje:
  - [x] kazde geokodowane zezwolenie ma dokladnie jedno przypisanie do punktu;
  - [x] liczba przypisan = liczba geokodowanych zezwoleń;
  - [x] kazdy niepusty `point_id` istnieje w `license_points.csv`;
  - [x] `point_memberships.csv` ma 458408 wierszy danych w pelnym eksporcie;
  - [x] `license_count` w `license_points.csv` zgadza sie z liczba przypisan w `point_memberships.csv`.

### 9. Eksport `locations_raw.csv`

- [x] Zbudowac exporter `DatasetExport::RawLocationsExporter`.
- [x] Jeden wiersz = unikalny kanoniczny adres zrodlowy identyfikowany przez `raw_location_id`.
- [x] Kolumny:
  - [x] `raw_location_id`;
  - [x] `internal_location_ids`;
  - [x] `source_address_1`;
  - [x] `source_address_2`;
  - [x] `normalized_location_id`;
  - [x] `license_count`;
  - [x] `first_reported_at`;
  - [x] `last_reported_at`.
- [x] Walidacje:
  - [x] liczba wierszy = 6993 po kanonizacji adresow zrodlowych;
  - [x] brak duplikatow `raw_location_id`;
  - [x] kazdy `raw_location_id` z `alcohol_licenses.csv` istnieje w `locations_raw.csv`;
  - [x] `license_count` zgadza sie z `alcohol_licenses.csv`.

### 10. Eksport `locations_normalized.csv`

- [x] Zbudowac exporter `DatasetExport::NormalizedLocationsExporter`.
- [x] Jeden wiersz = unikalna lokalizacja po normalizacji.
- [x] Kolumny:
  - [x] `normalized_location_id`;
  - [x] `internal_transformed_location_id`;
  - [x] `address_1`;
  - [x] `building_number`;
  - [x] `unit_number`;
  - [x] `address_kind`;
  - [x] `address_relation`;
  - [x] `raw_address_2`;
  - [x] `parcel_number`;
  - [x] `parcel_region`;
  - [x] `parcel_cadastral_unit`;
  - [x] `same_as`;
  - [x] `latitude`;
  - [x] `longitude`;
  - [x] `crs`;
  - [x] `selected_geocoding_result_id`;
  - [x] `selected_geocoding_source`;
  - [x] `selected_geocoding_strategy`;
  - [x] `selected_geocoding_precision`;
  - [x] `selected_geocoding_query`;
  - [x] `location_uncertain`;
  - [x] `location_uncertainty_reasons`;
  - [x] `raw_location_count`;
  - [x] `license_count`;
  - [x] `first_reported_at`;
  - [x] `last_reported_at`.
- [x] Nie eksportowac kolumn Google.
- [x] Wariant opcjonalny OSM/Nominatim jako osobne pola pominiety w tym etapie release do czasu pelnej decyzji o licencji i atrybucji.
- [x] Walidacje:
  - [x] liczba wierszy = 5300;
  - [x] typy `address_kind` zgodne ze slownikiem;
  - [x] brak `longitude` poza zakresem Krakowa dla geokodowanych lokalizacji;
  - [x] brak `latitude` poza zakresem Krakowa dla geokodowanych lokalizacji;
  - [x] brak kolumn zawierajacych `google` w nazwie;
  - [x] brak duplikatow `normalized_location_id`.

### 11. Eksport `address_corrections.csv`

- [x] Zbudowac exporter `DatasetExport::AddressCorrectionsExporter`.
- [x] Jeden wiersz = jawna korekta adresu.
- [x] Kolumny:
  - [x] `correction_id`;
  - [x] `raw_location_id`;
  - [x] `source_raw_location_id`;
  - [x] `corrected_address_1`;
  - [x] `corrected_address_2`;
  - [x] `source`;
  - [x] `method`;
  - [x] `confidence`;
  - [x] `selected`;
  - [x] `evidence`;
  - [x] `created_at`.
- [x] Walidacje:
  - [x] liczba wierszy = 231;
  - [x] liczba wybranych korekt = 230;
  - [x] brak korekt wskazujacych na nieistniejacy `raw_location_id`;
  - [x] brak korekt wskazujacych na nieistniejacy `source_raw_location_id`;
  - [x] brak duplikatow `correction_id`.

### 12. Eksport `geocoding_results.csv`

- [x] Zbudowac exporter `DatasetExport::GeocodingResultsExporter`.
- [x] Jeden wiersz = jeden zapisany wynik geokodowania.
- [x] Kolumny:
  - [x] `geocoding_result_id`;
  - [x] `normalized_location_id`;
  - [x] `source`;
  - [x] `strategy`;
  - [x] `query`;
  - [x] `latitude`;
  - [x] `longitude`;
  - [x] `crs`;
  - [x] `confidence`;
  - [x] `precision`;
  - [x] `selected`;
  - [x] `created_at`.
- [x] Wykluczyc rekordy `source = google` z publicznego eksportu.
- [x] Nie eksportowac `raw_response`.
- [x] Walidacje:
  - [x] liczba wierszy = 15605 po wykluczeniu Google;
  - [x] kazdy `selected = true` ma `latitude` i `longitude`;
  - [x] kazdy `normalized_location_id` istnieje w `locations_normalized.csv`;
  - [x] brak `raw_response` w pliku;
  - [x] brak rekordow `source = google`;
  - [x] brak duplikatow `geocoding_result_id`.

### 13. Eksport `geocoding_reviews.csv`

- [x] Zbudowac exporter `DatasetExport::GeocodingReviewsExporter`.
- [x] Jeden wiersz = ocena/audyt lokalizacji.
- [x] Kolumny:
  - [x] `review_id`;
  - [x] `normalized_location_id`;
  - [x] `signal_category`;
  - [x] `review_status`;
  - [x] `reviewed_by`;
  - [x] `original_latitude`;
  - [x] `original_longitude`;
  - [x] `manual_latitude`;
  - [x] `manual_longitude`;
  - [x] `selected_geocoding_result_id`;
  - [x] `manual_geocoding_result_id`;
  - [x] `quality_signals`;
  - [x] `note`;
  - [x] `sim_circle_within_area`;
  - [x] `reviewed_at`.
- [x] `reviewed_by` zanonimizowane: puste jesli brak wartosci, `redacted` jesli wartosc istnieje.
- [x] Walidacje:
  - [x] liczba wierszy = 880;
  - [x] `review_status` zgodny ze slownikiem;
  - [x] kazdy `normalized_location_id` istnieje w `locations_normalized.csv`;
  - [x] niepuste publiczne ID wynikow geokodowania istnieja w `geocoding_results.csv`;
  - [x] brak duplikatow `review_id`.

### 14. Eksport populacji i granic SIM

- [x] Zbudowac exporter `DatasetExport::SimPopulationsExporter`.
- [x] Eksportowac `sim_populations.csv`.
- [x] Kolumny:
  - [x] `observed_on`;
  - [x] `observed_on_code`;
  - [x] `sim_unit_code`;
  - [x] `sim_unit_name`;
  - [x] `district_code`;
  - [x] `district_name`;
  - [x] `population_total`;
  - [x] `unit`;
  - [x] `source`;
  - [x] `source_url`.
- [x] Walidacje:
  - [x] liczba wierszy = 8487;
  - [x] kazdy snapshot ma 123 jednostki SIM;
  - [x] najnowszy snapshot dla ostatniego raportu = `2025-12-31`.
- [x] Zbudowac exporter `DatasetExport::SimUnitsExporter`.
- [x] Eksportowac `sim_units.geojson`.
- [ ] Eksportowac `sim_units.gpkg`.
  - [ ] Wymaga narzedzia `ogr2ogr` albo innej biblioteki GPKG; lokalnie `ogr2ogr` nie jest dostepne.
- [x] Pola:
  - [x] `sim_unit_code`;
  - [x] `sim_unit_name`;
  - [x] `district_code`;
  - [x] `district_name`;
  - [x] `area_km2`;
  - [x] `geometry`.
- [x] Walidacje:
  - [x] liczba jednostek SIM = 123;
  - [x] geometrie sa poprawne;
  - [x] suma powierzchni = 325.736 km2, zgodna z przeliczeniem `Sim::Units`.

### 15. Eksport agregatow

- [x] Zbudowac exporter `DatasetExport::AggregatesExporter`.
- [x] Eksportowac `city_summary_by_report.csv`.
- [x] Eksportowac `district_summary_by_report.csv`.
- [x] Eksportowac `sim_summary_by_report.csv`.
- [x] Dla kazdego poziomu zapisac:
  - [x] `report_id`;
  - [x] `reported_at`;
  - [x] `report_date`;
  - [x] `area_type`;
  - [x] `area_code`;
  - [x] `area_name`;
  - [x] `district_code`;
  - [x] `district_name`;
  - [x] `area_km2`;
  - [x] `population_snapshot_date`;
  - [x] `population_total`;
  - [x] `license_count`;
  - [x] `geocoded_license_count`;
  - [x] `point_count`;
  - [x] `retail_point_count`;
  - [x] `gastronomy_point_count`;
  - [x] `mixed_point_count`;
  - [x] `retail_license_count`;
  - [x] `gastronomy_license_count`;
  - [x] `category_a_license_count`;
  - [x] `category_b_license_count`;
  - [x] `category_c_license_count`;
  - [x] `points_per_1000_registered_residents`;
  - [x] `licenses_per_1000_registered_residents`;
  - [x] `points_per_km2`;
  - [x] `licenses_per_km2`.
- [x] Walidacje:
  - [x] Krakow w ostatnim raporcie: `point_count = 3019`;
  - [x] Krakow w ostatnim raporcie: `license_count = 8142`;
  - [x] Krakow w ostatnim raporcie: `population_total = 703707`;
  - [x] Dzielnica I w ostatnim raporcie: `point_count = 1068`;
  - [x] Dzielnica I w ostatnim raporcie: `license_count = 2969`;
  - [x] Kazimierz w ostatnim raporcie: `point_count = 302`;
  - [x] liczba wierszy: miasto 64, dzielnice 1152, SIM 7872.

### 16. Eksport przestrzenny punktow

- [x] Zbudowac `DatasetExport::GeospatialWriter`.
- [x] W pierwszej wersji uzyc prostego GeoJSON bez dodatkowych zaleznosci.
- [x] Dla GeoPackage sprawdzic dostepnosc narzedzi:
  - [x] `ogr2ogr` - niedostepny w obecnym srodowisku;
  - [ ] albo gem/biblioteka do zapisu GPKG;
  - [x] albo etap opcjonalny opisany w modelu datasetu i do przeniesienia do README.
- [x] Eksportowac `license_points_latest.geojson` dla ostatniego raportu.
- [ ] Eksportowac `license_points.gpkg` dla wszystkich raportow, jezeli technicznie gotowe.
- [x] Wlasciwosci GeoJSON zgodne z `license_points.csv` bez dublowania `latitude` i `longitude` w `properties`.
- [x] Walidacje:
  - [x] liczba cech w `license_points_latest.geojson` = 3019;
  - [x] geometrie typu `Point`;
  - [x] kolejnosc wspolrzednych GeoJSON = `[longitude, latitude]`;
  - [x] brak punktow bez geometrii.

### 17. Parquet

- [x] Zdecydowac, czy Parquet generujemy w Ruby, Pythonie, czy opcjonalnym krokiem.
  - [x] Wybor: Python `pyarrow` jako opcjonalny backend `dataset:package`.
- [x] Preferencja: CSV jako zrodlo prawdy eksportu, Parquet generowany z CSV w kroku `dataset:package`.
- [x] Sprawdzic dostepnosc narzedzi:
  - [x] Python `pyarrow` - dostepny lokalnie, zweryfikowany w wersji `23.0.1`;
  - [x] DuckDB CLI - niedostepny lokalnie;
  - [x] Ruby gem - niedostepny lokalnie.
- [x] Jesli brak zaleznosci, `dataset:export` nie powinien padac, tylko `dataset:package` zapisuje status `skipped` w `metadata/package_report.json`.
- [x] Walidacje:
  - [x] liczba wierszy Parquet = liczba wierszy CSV;
  - [x] typy dat i liczb zachowane poprawnie dla kluczowych kolumn w raporcie pakowania.

### 18. Dokumentacja datasetu

- [x] Utworzyc `README.md` dla release.
- [x] README zawiera:
  - [x] streszczenie datasetu;
  - [x] zakres czasowy;
  - [x] liczbe raportow;
  - [x] liczbe rekordow zezwolen;
  - [x] liczbe punktow sprzedazy;
  - [x] definicje jednostek danych;
  - [x] szybki start w R;
  - [x] szybki start w Pythonie;
  - [x] szybki start w QGIS;
  - [x] jak cytowac;
  - [x] licencje i atrybucje;
  - [x] ograniczenia.
- [x] Utworzyc `CODEBOOK.md`.
- [x] CODEBOOK zawiera:
  - [x] opis kazdego pliku;
  - [x] opis kazdej kolumny;
  - [x] typ danych;
  - [x] czy pole moze byc puste;
  - [x] slowniki wartosci;
  - [x] jednostki miary;
  - [x] przyklady interpretacji.
- [x] Utworzyc `NOTICE.md`.
- [x] NOTICE zawiera:
  - [x] pochodzenie danych z BIP/GMK;
  - [x] informacje, ze dane zostaly przetworzone;
  - [x] date przygotowania release;
  - [x] zastrzezenie, ze GMK nie odpowiada za przetworzenie;
  - [x] atrybucje OSM/Nominatim;
  - [x] informacje o MSIP, ULDK, GUS;
  - [x] informacje, ze Google nie jest zrodlem publikowanych wspolrzednych.
- [x] Utworzyc `CITATION.cff`.
- [x] Utworzyc `metadata/datacite.json`.
- [x] Utworzyc `metadata/export_manifest.json`.
- [x] Utworzyc `metadata/validation_report.md`.

### 19. Licencja i kwestie prawno-etyczne

- [x] Wybrac licencje dla kuratorskiego datasetu.
- [x] Rekomendacja robocza: `CC BY 4.0`, nie `CC0`, ze wzgledu na wymogi atrybucji zrodel publicznych.
- [x] Sprawdzic warunki ponownego wykorzystania BIP Krakow.
- [ ] Sprawdzic, czy dane z arkuszy pozyskanych na wniosek mozna redystrybuowac w calosci.
  - [x] Brak lokalnej odpowiedzi urzedu/oferty reuse w repo; ustawic `INCLUDE_SOURCE_FILES=0` do czasu potwierdzenia.
  - [ ] Przed publikacja raw/source mirror sprawdzic pismo z urzedu albo uzyskac potwierdzenie warunkow.
- [x] Sprawdzic warunki MSIP dla populacji i granic SIM.
- [x] Sprawdzic warunki ULDK/GUS.
- [x] Dodac atrybucje OpenStreetMap/Nominatim.
- [x] Wykluczyc z eksportu:
  - [x] wspolrzedne Google;
  - [x] surowe odpowiedzi Google;
  - [x] pola techniczne bez wartosci naukowej;
  - [x] lokalne sciezki zawierajace informacje prywatne.
- [x] Podjac decyzje o nazwach jednoosobowych dzialalnosci gospodarczych.
- [x] Udokumentowac decyzje o nazwach podmiotow w `NOTICE.md`.

### 20. Walidator release

- [x] Zbudowac `DatasetExport::Validator`.
- [x] Walidator zapisuje `metadata/validation_report.json`.
- [x] Walidator zapisuje czytelny `metadata/validation_report.md`.
- [x] Walidacje globalne:
  - [x] `alcohol_licenses.csv` ma 458408 wierszy;
  - [x] `reports.csv` ma 64 wiersze;
  - [x] `locations_raw.csv` ma 6993 wiersze po kanonizacji spacji w adresach zrodlowych;
  - [x] `locations_normalized.csv` ma 5300 wierszy;
  - [x] `license_points.csv` ma 173821 wierszy;
  - [x] `geocoding_results.csv` ma 15605 wierszy po wykluczeniach licencyjnych;
  - [x] `geocoding_reviews.csv` ma 880 wierszy;
  - [x] `address_corrections.csv` ma 231 wierszy;
  - [x] `sim_populations.csv` ma 8487 wierszy.
- [x] Walidacje referencyjne:
  - [x] kazdy `license_id` w `point_memberships.csv` istnieje w `alcohol_licenses.csv`;
  - [x] kazdy niepusty `point_id` w `point_memberships.csv` istnieje w `license_points.csv`;
  - [x] kazdy `normalized_location_id` w `alcohol_licenses.csv` istnieje w `locations_normalized.csv`;
  - [x] kazdy `raw_location_id` w `alcohol_licenses.csv` istnieje w `locations_raw.csv`;
  - [x] kazdy `sim_unit_code` istnieje w `sim_units`.
- [x] Walidacje merytoryczne:
  - [x] ostatni raport ma 8142 zezwolenia;
  - [x] ostatni raport ma 3019 punktow sprzedazy;
  - [x] ostatni raport ma 8139 geokodowanych zezwoleń;
  - [x] pierwszy raport ma 6706 zezwolen;
  - [x] pierwszy raport ma 2606 punktow sprzedazy;
  - [x] Dzielnica I w ostatnim raporcie ma 2969 zezwoleń;
  - [x] Dzielnica I w ostatnim raporcie ma 1068 punktow;
  - [x] Kazimierz w ostatnim raporcie ma 302 punkty;
  - [x] populacja Krakowa dla ostatniego raportu = 703707.
- [x] Walidacje techniczne:
  - [x] CSV sa UTF-8;
  - [x] naglowki sa unikalne;
  - [x] brak nieoczekiwanych kolumn;
  - [x] daty sa ISO 8601;
  - [x] wspolrzedne sa liczbami;
  - [x] pola listowe maja poprawny JSON albo ustalony separator;
  - [x] brak lokalnych absolutnych sciezek.

### 21. Testy automatyczne

- [x] Test `DatasetExport::StableIdTest`.
- [x] Test `DatasetExport::ReportsExporterTest`.
- [x] Test `DatasetExport::AlcoholLicensesExporterTest`.
- [x] Test `DatasetExport::LicensePointsExporterTest`.
- [x] Test `DatasetExport::PointMembershipsExporterTest`.
- [x] Test `DatasetExport::LocationsExporterTest` jako `RawLocationsExporterTest` i `NormalizedLocationsExporterTest`.
- [x] Test `DatasetExport::AggregatesExporterTest`.
- [x] Test `DatasetExport::ValidatorTest`.
- [x] Test smoke dla `rake dataset:export LATEST_ONLY=1`.
- [x] Test smoke dla pelnego eksportu na bazie testowej z malym fixture.
- [x] Test, ze eksport nie zawiera kolumn Google.
- [x] Test, ze `longitude` jest zapisane poprawnie mimo wewnetrznej nazwy `longtitude`.

### 22. Pakowanie release

- [x] `dataset:package` tworzy archiwum:
  - [x] `.zip`;
  - [ ] opcjonalnie `.tar.gz`.
- [x] Nazwa archiwum:
  - [x] `krakow-alcohol-licenses-2010-2026-v1.0.0.zip`.
- [x] Archiwum zawiera tylko pliki release, bez `tmp`, `.git`, lokalnej bazy i cache.
- [x] `checksums.txt` zawiera checksumy plikow wewnatrz paczki.
- [x] `export_manifest.json` zawiera:
  - [x] nazwe pliku;
  - [x] format;
  - [x] liczbe wierszy;
  - [x] checksum;
  - [x] czas wygenerowania;
  - [x] wersje kodu;
  - [x] commit SHA jesli repo jest w Git.
- [x] `dataset:release` wykonuje:
  - [x] eksport;
  - [x] walidacje;
  - [x] generowanie dokumentacji;
  - [x] checksums;
  - [x] pakowanie;
  - [x] finalny raport.

### 23. Repozytorium publikacyjne

- [x] Wybrac repozytorium:
  - [x] Zenodo;
  - [ ] OSF;
  - [ ] Harvard Dataverse;
  - [ ] repozytorium instytucjonalne.
- [x] Ustalic, ze repozytorium publikacyjne nie jest tym katalogiem roboczym.
  - [x] Repo robocze/kod: `/Users/maciej/Projects/krakow/alcohol_licenses`.
  - [x] Repo publikacyjne/staging Zenodo: `/Users/maciej/Projects/krakow-alcohol-licenses`.
- [x] Dodac task `dataset:prepare_publication_repo` kopiujacy release do zewnetrznego repo publikacyjnego.
- [x] Rekomendacja robocza: GitHub dla kodu + Zenodo dla danych i DOI.
- [x] Przygotowac opis datasetu po angielsku.
- [x] Przygotowac slowa kluczowe:
  - [x] alcohol licenses;
  - [x] Krakow;
  - [x] geocoding;
  - [x] administrative data;
  - [x] open data;
  - [x] urban studies;
  - [x] spatial data.
- [ ] Przygotowac `Data availability statement` do artykulu.
- [ ] Przygotowac `Software availability statement` do artykulu.
- [ ] Przygotowac cytowanie datasetu.
- [ ] Przygotowac cytowanie kodu.

## Proponowane pliki implementacyjne

```text
lib/tasks/dataset.rake

app/services/dataset_export/config.rb
app/services/dataset_export/paths.rb
app/services/dataset_export/runner.rb
app/services/dataset_export/stable_id.rb
app/services/dataset_export/csv_writer.rb
app/services/dataset_export/json_writer.rb
app/services/dataset_export/checksum_writer.rb
app/services/dataset_export/manifest_writer.rb
app/services/dataset_export/validator.rb
app/services/dataset_export/documentation_writer.rb
app/services/dataset_export/geospatial_writer.rb

app/services/dataset_export/exporters/reports_exporter.rb
app/services/dataset_export/exporters/alcohol_licenses_exporter.rb
app/services/dataset_export/exporters/license_points_exporter.rb
app/services/dataset_export/exporters/point_memberships_exporter.rb
app/services/dataset_export/exporters/raw_locations_exporter.rb
app/services/dataset_export/exporters/normalized_locations_exporter.rb
app/services/dataset_export/exporters/address_corrections_exporter.rb
app/services/dataset_export/exporters/geocoding_results_exporter.rb
app/services/dataset_export/exporters/geocoding_reviews_exporter.rb
app/services/dataset_export/exporters/sim_populations_exporter.rb
app/services/dataset_export/exporters/sim_units_exporter.rb
app/services/dataset_export/exporters/aggregates_exporter.rb
```

## Kolejnosc realizacji

### Faza 1 - fundament eksportu

- [ ] Utworzyc namespace i rake task `dataset:export`.
- [ ] Dodac `DatasetExport::Config`, `Paths`, `CsvWriter`, `StableId`.
- [ ] Wyeksportowac `reports.csv`.
- [ ] Wyeksportowac `locations_raw.csv`.
- [ ] Wyeksportowac `locations_normalized.csv`.
- [ ] Dodac podstawowy `checksums.txt`.
- [ ] Dodac test deterministycznosci identyfikatorow.

### Faza 2 - glowne dane analityczne

- [ ] Wyeksportowac `alcohol_licenses.csv`.
- [ ] Wyeksportowac `license_points.csv`.
- [ ] Wyeksportowac `point_memberships.csv`.
- [ ] Dodac walidacje liczebnosci i relacji.
- [ ] Uzgodnic finalna decyzje o nazwach podmiotow.

### Faza 3 - jakosc i provenance

- [ ] Wyeksportowac `address_corrections.csv`.
- [ ] Wyeksportowac `geocoding_results.csv` bez Google/raw response.
- [ ] Wyeksportowac `geocoding_reviews.csv`.
- [ ] Wyeksportowac `source_files_manifest.csv`.
- [ ] Uzupelnic `NOTICE.md`.

### Faza 4 - przestrzen i agregaty

- [ ] Wyeksportowac `sim_populations.csv`.
- [ ] Wyeksportowac `sim_units.geojson`.
- [ ] Wyeksportowac `license_points_latest.geojson`.
- [ ] Wyeksportowac agregaty miejskie, dzielnicowe i SIM.
- [ ] Dodac opcjonalny GeoPackage.
- [ ] Dodac opcjonalny Parquet.

### Faza 5 - release naukowy

- [ ] Wygenerowac `README.md`.
- [ ] Wygenerowac lub recznie przygotowac `CODEBOOK.md`.
- [ ] Wygenerowac `CITATION.cff`.
- [ ] Wygenerowac `datacite.json`.
- [ ] Wygenerowac `export_manifest.json`.
- [ ] Wygenerowac `validation_report.md`.
- [ ] Spakowac release.
- [ ] Przetestowac import w R.
- [ ] Przetestowac import w Pythonie.
- [ ] Przetestowac otwarcie warstwy w QGIS.
- [ ] Opublikowac release w repozytorium z DOI.

## Kryteria gotowosci pierwszego release

- [ ] Pakiet danych generuje sie jedna komenda.
- [ ] Pakiet przechodzi `dataset:validate`.
- [ ] Pakiet zawiera dokumentacje i codebook.
- [ ] Pakiet zawiera checksums.
- [ ] Pakiet nie zawiera danych Google.
- [ ] Pakiet nie zawiera lokalnych absolutnych sciezek.
- [ ] Pakiet rozroznia zezwolenia i punkty sprzedazy.
- [ ] Pakiet pozwala odtworzyc glowne liczby z manuskryptu pracy.
- [ ] Pakiet ma jasna licencje i NOTICE.
- [ ] Pakiet ma gotowa cytacje.
- [ ] Dataset da sie wczytac w Pythonie, R i QGIS bez uruchamiania aplikacji Rails.

## Ryzyka do rozstrzygniecia

- [ ] Brak jawnego `source_file_id` i `source_row_number` w obecnym modelu `alcohol_licenses`.
- [ ] Decyzja, czy publikowac pelne nazwy podmiotow gospodarczych.
- [ ] Licencyjne warunki redystrybucji arkuszy pozyskanych poza BIP.
- [ ] Atrybucje i warunki danych MSIP/SIM.
- [ ] Zakres wykorzystania Nominatim/OSM w opublikowanych wspolrzednych.
- [ ] Czy GeoPackage ma byc wymaganym artefaktem, czy opcjonalnym formatem pochodnym.
- [ ] Czy Parquet ma byc wymaganym artefaktem, czy opcjonalnym formatem pochodnym.
- [ ] Czy stare `transformed_locations.csv` usunac, czy zastapic eksportem generowanym przez `dataset:export`.
