# Metadane zrodel datasetu

Ten dokument opisuje publiczny manifest zrodel tworzony przez
`DatasetExport::SourceFilesManifest`.

## Zakres manifestu

Manifest obejmuje trzy grupy plikow:

- historyczne arkusze `vendor/data/xlsx/*.xls*`,
- oryginalne PDF-y `vendor/data/files/**/**/*.pdf`,
- tabele CSV po ekstrakcji PDF `vendor/data/files/output/*.csv`.

Pomocnicze dane przestrzenne i ludnosciowe beda eksportowane w kolejnych etapach
osobnymi eksporterami.

## Pola

- `source_file_id` - stabilny publiczny identyfikator pliku.
- `reported_at` - data i czas raportu w ISO 8601, jezeli da sie odczytac z
  nazwy lub sciezki.
- `report_date` - data raportu bez czasu.
- `business_category` - `detal` albo `gastronomia`.
- `license_category` - `A`, `B` albo `C`.
- `file_format` - `xls`, `xlsx`, `pdf` albo `csv`.
- `source_origin` - opis pochodzenia pliku.
- `original_filename` - oryginalna nazwa pliku.
- `relative_path` - sciezka wzgledna w repozytorium.
- `source_url` - URL zrodlowy, jezeli jest znany.
- `retrieved_at` - data pobrania, jezeli jest znana.
- `sha256` - suma kontrolna pliku.
- `row_count_extracted` - liczba wierszy w pliku ekstraktu, jezeli dotyczy.
- `row_count_imported` - liczba wierszy zaimportowanych, jezeli da sie ja
  ustalic na tym etapie.
- `notes` - ograniczenia lub komentarze.

## Ograniczenia obecnego modelu

Obecna tabela `alcohol_licenses` nie przechowuje jawnego `source_file_id` ani
`source_row_number`. Oznacza to, ze manifest plikow zrodlowych dokumentuje
pochodzenie raportow, ale nie wystarcza jeszcze do pelnej relacji
`license -> source row` dla wszystkich rekordow. Pelne domkniecie wymaga
dodania warstwy `license_source_records` albo migracji rozszerzajacej import.

