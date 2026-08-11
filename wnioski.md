# Wnioski z testu reprodukowalności pipeline

Test wykonano na świeżym clone repozytorium w `/Users/maciej/Projects/test/alcohol_permits_map`, na commicie `00b05b6` (`Flatten alcohol permits map project`). Pipeline został uruchomiony od zera, krok po kroku, z lokalnym katalogiem publikacyjnym testowym.

## Wynik testu

Pipeline nie odtwarza obecnej bazy 1:1 i nie dochodzi do końca.

Przeszły kroki:

- `db:setup`
- `research:import_sources`
- `research:normalize_locations`
- `research:geocode_open`

Pipeline przerwał się na:

- `research:rebuild_analysis`
- wewnętrznie: `curation:import_geocoding_decisions`

Błąd:

```text
ActiveRecord::RecordNotFound: Couldn't find TransformedLocation
```

Proces główny działał około `3h 31m`, z czego samo `research:geocode_open` około `3h 01m`.

## Porównanie metryk

| Metryka | Obecna baza | Świeży clone po częściowym pipeline | Status |
| --- | ---: | ---: | --- |
| `streets` | 2971 | 2971 | OK |
| `businesses` | 9737 | 9813 | różnica |
| `locations` | 7002 | 7147 | różnica |
| `alcohol_licenses` | 458408 | 620288 | różnica |
| `license_categories` | 3 | 3 | OK |
| `business_categories` | 2 | 2 | OK |
| `transformed_locations` | 5300 | 4921 | różnica |
| `geocoding_results` | 19631 | 14566 | różnica |
| `address_corrections` | 231 | 232 | różnica |
| `geocoding_reviews` | 880 | 0 | różnica |
| `license_point_groups` | 173655 | 0 | różnica |
| `sim_populations` | 8487 | 8487 | OK |
| liczba dat raportów | 64 | 86 | różnica |
| `selected_geocoding_results` | 5265 | 4138 | różnica |
| licencje z grupą punktu | 457845 | 0 | różnica |

## Główne przyczyny różnic

### 1. Świeży import bierze inny zakres raportów

Największy rozjazd powstaje już na etapie `research:import_sources`.

Obecna baza ma `64` daty raportów, a świeży clone ma `86`. Clone zawiera dokładnie `22` dodatkowe daty raportów, których nie ma w bazie referencyjnej. Nie ma dat obecnych tylko w bazie referencyjnej.

To tłumaczy wzrost liczby licencji z `458408` do `620288`.

Dodatkowe daty w clone:

```text
2013-12-05T09:37:36Z
2014-03-07T13:54:25Z
2014-07-03T14:25:55Z
2014-09-03T09:40:25Z
2014-10-08T10:19:33Z
2015-01-05T11:05:16Z
2015-04-02T08:22:49Z
2015-07-03T15:01:47Z
2015-09-08T13:53:27Z
2016-01-18T14:57:16Z
2016-05-04T14:41:53Z
2017-01-16T09:57:39Z
2017-08-08T10:30:33Z
2017-09-26T09:56:20Z
2018-03-22T12:31:22Z
2018-05-30T12:37:29Z
2018-11-15T14:19:26Z
2018-11-15T14:22:20Z
2019-05-17T11:51:19Z
2019-05-20T12:31:58Z
2020-08-04T13:29:58Z
2021-04-16T13:25:58Z
```

### 2. Snapshot kuratorski jest sprzężony z konkretną normalizacją

Snapshot `db/curation/current.json` zawiera:

- `231` korekt adresów,
- `807` wybranych decyzji geokodowania,
- `880` review geokodowania.

Po świeżym imporcie i normalizacji `127` z `807` decyzji geokodowania nie znajduje odpowiadającego `TransformedLocation`. Typowe brakujące przypadki to warianty lokali, pawilonów i surowych adresów, np. `18 D`, `26/1`, `paw. 25 i 26`.

Importer snapshotu szuka po polach:

```text
address_1
building_number
address_kind
address_relation
unit_number
parcel_number
parcel_region
parcel_cadastral_unit
raw_address_2
same_as
```

Jeżeli normalizacja da minimalnie inny wynik, decyzja kuratorska nie może zostać odtworzona i pipeline przerywa się na `curation:import_geocoding_decisions`.

### 3. Geokodowanie nie jest deterministycznie offline

`research:geocode_open` uruchamia zewnętrzne źródła:

- MSIP Kraków,
- GUS address points,
- ULDK parcels,
- OSM/Nominatim.

Ten krok trwał ponad 3 godziny i zależy od usług live. W trakcie testu pojawiały się timeouty MSIP, chociaż task kontynuował pracę. To znaczy, że pełne odtworzenie może dawać różne wyniki w zależności od dostępności i aktualnego stanu usług zewnętrznych.

## Wniosek końcowy

Repozytorium ma dane, taski i snapshot kuratorski, ale nie ma jeszcze deterministycznego trybu odtworzenia publikowanej bazy danych 1:1.

Osoba, która sklonuje repo i odpali obecny pipeline od zera, nie dostanie tych samych danych, które są w aktualnej bazie lokalnej.

## Co trzeba poprawić przed publikacją

- Dodać przypięty manifest źródeł/licencjonowanych raportów używany dla publikowanego datasetu.
- Pipeline reprodukcyjny powinien importować dokładnie ten manifest, a nie wszystko, co znajduje się w `vendor/data`.
- Snapshot kuratorski powinien być importowany po stabilnych identyfikatorach albo po osobnym snapshotcie tabel po normalizacji.
- Geokodowanie live powinno być oddzielone od deterministycznego odtworzenia datasetu.
- Dla publikacji na Zenodo powinien istnieć task typu `research:restore_publication_snapshot` albo równoważny, który odtwarza stan publikowanej bazy bez wywołań live do geocoderów.
- Należy dodać test/metryki reprodukowalności, które porównują liczbę raportów, licencji, lokalizacji, decyzji geokodowania i grup punktów z wartościami oczekiwanymi.
## Dodatkowe ustalenia po analizie rozjazdów

### 1. Więcej raportów nie wynika z duplikacji XLSX względem CSV

W obu katalogach projektu źródła raportów mają ten sam zakres plików importowanych przez pipeline: `180` plików CSV w `vendor/data/files/output` oraz `336` plików XLS/XLSX w `vendor/data/xlsx`. Różnica między bazą referencyjną i świeżym klonem nie wynika więc z tego, że clone ma inne pliki niż bieżący projekt.

Świeży pipeline importuje pełny obecny manifest lokalnych źródeł, a baza referencyjna była zbudowana z mniejszego zakresu dat. Wszystkie `22` dodatkowe daty w clone pochodzą z CSV wyekstrahowanych z PDF, nie z CSV generowanych z XLSX. Po pełnym `reported_at` nie ma nakładania, bo CSV zachowują timestamp publikacji z PDF, a XLSX mają zwykle datę dzienną lub miesięczną. Po samej dacie kalendarzowej i kategoriach jest jednak `36` overlapów CSV/XLSX, więc część raportów może reprezentować ten sam dzień administracyjny w dwóch formatach źródłowych.

Część dodatkowych dat CSV jest jednak bajtowo identyczna z inną dodatkową datą:

- `2013-12-05 09:37:36` = `2014-03-07 13:54:25`,
- `2017-09-26 09:56:20` = `2018-03-22 12:31:22`,
- `2018-11-15 14:19:26` = `2018-11-15 14:22:20`,
- `2019-05-17 11:51:19` = `2019-05-20 12:31:58`.

Importer traktuje takie publikacje jako osobne snapshoty, bo mają inny `reported_at`. To może być poprawne naukowo, jeżeli publikacja urzędu faktycznie była osobnym stanem w czasie, ale do publikacji datasetu musimy świadomie opisać politykę: importujemy każdy opublikowany snapshot albo deduplikujemy identyczną treść po hashach.

### 2. Więcej lokalizacji jest spójne z większą liczbą raportów

Clone ma `7147` surowych `locations`, a baza referencyjna `7002`. To jest logiczny skutek importu dodatkowych `22` dat CSV i nie wygląda jak niezależny błąd relacyjny.

W dodatkowych CSV są też brudne historyczne rekordy, np. artefakty ekstrakcji takie jak `OSIEDLE BOHATERÓW OWSRIZEEDŚLNE IBAOHATERÓW`, `WRZEŚNIA 26A`, `ALEJA MARSZAŁKA FERDYNANDA 1FOCHA`. Przykłady te pochodzą z dodatkowych dat CSV, m.in. `2015-01-05`, `2015-04-02`, `2015-07-03`, oraz z duplikowanych dat `2018/2019`.

### 3. Mniej `transformed_locations` nie jest skutkiem braku Google

`TransformedLocation` powstaje w `research:normalize_locations`, przed jakimkolwiek geokodowaniem. Google jest opcjonalnym krokiem `research:geocode_google_quality_control` i nie jest częścią `research:full_open_pipeline`. Brak Google może obniżyć liczbę `geocoding_results` albo decyzji selected, ale nie może bezpośrednio zmniejszyć liczby `transformed_locations`.

Porównanie po pełnej tożsamości snapshotu daje:

- `5300` transformed locations w bazie referencyjnej,
- `4921` w clone,
- `4397` wspólnych,
- `903` obecne tylko w referencyjnej,
- `524` obecne tylko w clone.

Po odrzuceniu pól opisowych `raw_address_2` i `same_as`, czyli po samej geokodowalnej tożsamości, wynik jest bardziej diagnostyczny:

- `4902` wspólne geokodowalne tożsamości,
- `398` geokodowalnych tożsamości tylko w referencyjnej,
- `19` geokodowalnych tożsamości tylko w clone,
- `505` rekordów ma tę samą geokodowalną tożsamość, ale inny `raw_address_2` albo `same_as`.

Przykłady tej samej geokodowalnej tożsamości z innym surowym zapisem:

- `Balicka 18D`: referencyjnie `18 D`, clone `18D`,
- `Bieńczycki Plac Targowy 26`: referencyjnie `26/1`, clone `26`,
- `Pawia 5`: referencyjnie `5/p-1`, clone `5 poziom 1`,
- `Henryka Kamieńskiego 11`: referencyjnie `11/FC3`, clone `11`,
- `Rynek Główny 6`: referencyjnie `6.0`, clone `6`.

To tłumaczy, dlaczego import snapshotu kuratorskiego pęka: `CurationSnapshot` szuka `TransformedLocation` także po `raw_address_2` i `same_as`, chociaż unikalny indeks modelu opiera się na geokodowalnej tożsamości bez tych pól. Po pełniejszym imporcie ten sam adres może dostać inny reprezentatywny `raw_address_2`, więc decyzja kuratorska przestaje się mapować.

W samym `db/curation/current.json` jest `807` wybranych decyzji geokodowania. W clone `127` z nich nie znajduje pełnej tożsamości `TransformedLocation`; z tego `79` ma nadal tę samą geokodowalną tożsamość, a problemem jest tylko `raw_address_2`/`same_as`. Pozostałe `48` faktycznie nie ma odpowiednika po geokodowalnej tożsamości.

### 4. Timeouty w geokodowaniu nie mają retry i taski idą dalej

Taski geokodowania (`MSIP`, `GUS`, `ULDK`, `Nominatim/OSM`, `Google`) łapią `StandardError` per kandydat, zwiększają licznik `failed`, logują `ERROR` i kontynuują. Nie ma mechanizmu retry/backoff na poziomie rake tasków.

W testowym przebiegu `research:geocode_open` były timeouty MSIP. To może wpływać na liczbę i jakość `geocoding_results`, ale nie tłumaczy mniejszej liczby `transformed_locations`, bo te są tworzone wcześniej.

### 5. Korekty adresów prawie się zgadzają

Referencyjna baza ma `231` `address_corrections`, a clone `232`. Różnica to jedna automatycznie wywnioskowana korekta:

- źródło: `MOGILSKA` bez numeru,
- korekta: `MOGILSKA 13B`,
- metoda: `same_business_same_normalized_street`,
- źródło korekty: `internal_history`.

To nie tłumaczy głównego rozjazdu setek `transformed_locations`; główna przyczyna leży w pełniejszym imporcie CSV i niestabilnym mapowaniu snapshotu przez `raw_address_2`/`same_as`.

## Rekomendacje po tej analizie

- Dodać jawny manifest raportów publikacyjnych z hashami plików i polityką dla identycznych snapshotów.
- Zdecydować, czy identyczne CSV z różnymi datami są osobnymi obserwacjami czasowymi, czy duplikatami do pominięcia.
- Nie mapować decyzji kuratorskich po `raw_address_2` i `same_as`; używać stabilnej geokodowalnej tożsamości albo osobnych stabilnych identyfikatorów.
- Rozdzielić deterministyczne odtworzenie bazy publikacyjnej od geokodowania live.
- Dodać retry/backoff i raport błędów dla geocoderów, jeśli geokodowanie live ma pozostać częścią pipeline.
- Dodać walidację reprodukowalności po każdym głównym kroku: liczba raportów, hash manifestu źródeł, liczba surowych lokalizacji, liczba geokodowalnych tożsamości, liczba decyzji kuratorskich możliwych do zmapowania.

## Aktualizacja po ograniczeniu źródeł i poprawkach transformacji

Po zastosowaniu selektora źródeł `XLSX + PDF po ostatnim XLSX z buforem 7 dni` świeży klon ma ten sam zakres danych wejściowych co baza referencyjna:

- `7002` surowe lokalizacje,
- `0` lokalizacji bez przypisanej transformacji po `locations:normalize`,
- `232` korekty adresów w klonie.

Poprawione błędy transformacji:

- `KAWIORY`, `8 / 1 I 2` nie jest już błędnie rozbijane na ulicę `8 Pułku Ułanów`; zostaje `Kawiory 8`, `compound_address`, lokal `1`.
- `JÓZEFA`, `6 / 2U, 3U` nie jest już podatne na tę samą klasę błędu z ulicą `6 Sierpnia`.
- `UL. DIETLA 44 LOK. 50/ UL. STRADOMSKA 18` daje teraz `Józefa Dietla 44 lok. 50`; część `Stradomska 18` traktujemy jako drugi adres narożny i pomijamy w normalizacji głównej lokalizacji.
- `PLAC INWALIDÓW`, `dz.652/3 obr.4` zachowuje jednostkę ewidencyjną `krowodrza` już na etapie normalizacji, a nie dopiero jako hint geokodera ULDK.

Aktualny wynik porównania świeżo przeliczonego klonu z bazą referencyjną:

- clone: `4903` referencjonowane `transformed_locations`, `0` osieroconych `transformed_locations`, `0` lokalizacji bez transformacji,
- różnice przypisań `Location -> TransformedLocation`: `8`.

Pozostałe `8` różnic wygląda na poprawę w klonie względem starej bazy referencyjnej, a nie regresję:

- `HETMANA ŻÓŁKIEWSKIEGO`: clone dodaje lokal `3`.
- `KAWIORY 8 / 1 I 2`: clone wybiera właściwą ulicę `Kawiory`, referencja błędnie `8 Pułku Ułanów`.
- `KRAKOWSKA`: clone odtwarza `Krakowska 5 lok. 25`, referencja ma tylko landmark.
- `MEISELSA`: clone odtwarza `Meiselsa 20 lok. 1`, referencja ma tylko landmark.
- `MIODOWA`: clone odtwarza `Miodowa 32 lok. 3`, referencja ma tylko landmark.
- `MOGILSKA`: clone odtwarza `Mogilska 13B`, referencja ma tylko landmark.
- `MOGILSKA 21 l`: clone rozdziela `21` i lokal `L`, referencja traktuje `21L` jako numer budynku.
- `UL. DIETLA 44 LOK. 50/ UL. STRADOMSKA 18`: clone odtwarza `Józefa Dietla 44 lok. 50`, referencja ma tylko landmark.

Wniosek: po tych zmianach deterministyczne odtworzenie normalizacji z repo jest lepsze jakościowo niż aktualny stan starej bazy referencyjnej w zakresie wykrytych różnic. Dalsza zgodność 1:1 nie powinna być celem dla tych 8 przypadków; raczej trzeba uznać świeżo liczony wynik za nowy stan publikacyjny i dopiero do niego dopiąć/geokodować snapshot kuratorski.

## Aktualizacja po usunięciu osieroconych `transformed_locations`

Usunięto z lokalnej bazy rekordy `transformed_locations`, które nie były wskazywane przez żadną surową `locations`:

- usunięte osierocone `transformed_locations`: `391`,
- usunięte zależne `geocoding_results`: `1506`,
- usunięte zależne `geocoding_reviews`: `49`,
- pozostałe osierocone `transformed_locations`: `0`,
- lokalizacje bez transformacji: `0`.

Przed operacją wykonano kopię bazy: `db/development.before_prune_orphaned_transformed_locations.20260811.sqlite3`.

Po czyszczeniu baza ma:

- `4909` `transformed_locations`, wszystkie referencjonowane przez `locations`,
- `831` `geocoding_reviews` w odświeżonym `db/curation/current.json`,
- `762` wybrane wyniki geokodowania w odświeżonym `db/curation/current.json`.

Wpływ na próbę jakości:

- aktualna deterministyczna `random_sample` nadal ma `357` kandydatów,
- `346` kandydatów jest rozstrzygniętych,
- `11` kandydatów pozostaje do domknięcia w kolejce review.

Pozostałe nierozstrzygnięte rekordy aktualnej próby `random_sample`:

- `Osiedle Oświecenia` (`landmark`),
- `Saska 27`,
- `Aleja Adama Mickiewicza`, działka `65/3`, raw `dz. 65/3/Piłsudkiego`,
- `Meiselsa` (`landmark`),
- `Aleja 29 Listopada`, działki `199|200`, raw `dz. nr 199 i 200`,
- `Grzegórzecka 63`,
- `Jana Surzyckiego 2`,
- `Józefa Mackiewicza` (`landmark`),
- `Architektów` (`landmark`),
- `Miodowa` (`landmark`),
- `Blokowa 1`.

Wniosek dla paperu: po usunięciu osieroconych rekordów nie trzeba zmieniać wyników liczonych na aktualnych lokalizacjach/licencjach, ale trzeba podawać liczby walidacji po czyszczeniu. Jeżeli paper deklaruje pełne ręczne rozstrzygnięcie próby 357, to przed finalną publikacją trzeba ręcznie domknąć te `11` rekordów albo zmienić sformułowanie na `346/357` rozstrzygniętych w aktualnej próbie.

## Aktualizacja po zmianie ocen `Meiselsa` i `Miodowa`

Dwa rekordy z aktualnej próby `random_sample`, których normalizacja zmieniła się po poprawkach pipeline, zostały przepięte ze starych ogólnych `landmark` na dokładne istniejące `TransformedLocation`:

- `MEISELSA` -> `Meiselsa 20 lok. 1`, `random_sample: exact`, wybrane geokodowanie `krakow_msip`, `address_point/msip_emuia`, SIM `I.8 Kazimierz`, `sim_circle_within_area=true`.
- `MIODOWA` -> `Miodowa 32 lok. 3`, `random_sample: exact`, wybrane geokodowanie `krakow_msip`, `address_point/msip_emuia`, SIM `I.8 Kazimierz`, `sim_circle_within_area=true`.

Ważna zmiana jakościowa: stare `random_sample` dla `Miodowa` miało `sim_circle_within_area=false`, a po przepięciu na dokładny adres i ocenę `exact` jest `true`. Wcześniejszy osobny review `sim_area_ambiguous` dla `Miodowa` był już rozstrzygnięty jako `verified`.

Po tej aktualizacji aktualna próba jakości ma:

- `random_sample`: `357` rekordów,
- rozstrzygnięte: `351`,
- nierozstrzygnięte: `6`.

Ponieważ zmienił się `unit_number` z pustego na lokal (`1`/`3`), przebudowano grupy punktów dla raportów zawierających te lokalizacje:

- `2019-05-17T00:00:00Z`: `2810` grup,
- `2023-03-09T15:48:49Z`: `2991` grup,
- `2024-02-20T09:25:21Z`: `2991` grup.

Wniosek dla paperu: jeśli tekst podaje liczby walidacji geokodowania/SIM, powinien używać aktualnego stanu `351/357` rozstrzygniętych w próbie losowej i `6` pozostałych nierozstrzygniętych. Jeżeli tekst wspomina przypadki poza okręgiem/SIM dla próby, `Miodowa` nie powinna już być liczona jako problem po aktualizacji.

## Co przerobić przed publikacją w Scientific Data / Zenodo

### Paper

Obecny tekst ma dobry materiał merytoryczny, ale przed zgłoszeniem do `Scientific Data` powinien zostać przebudowany z artykułu opisującego proces i wyniki na klasyczny `Data Descriptor`.

Zostawić:

- opis zakresu danych: Kraków, zezwolenia alkoholowe, lata `2010-2026`,
- opis źródeł miejskich i reguły `XLSX-first, PDF-only-after-last-XLSX`,
- opis ekstrakcji PDF/XLSX, normalizacji adresów, korekt ręcznych, geokodowania i przypisania do SIM,
- opis walidacji próby losowej `357`,
- opis ograniczeń wynikających z jakości PDF, niejednoznacznych adresów i punktów na granicach SIM,
- podstawowe statystyki datasetu, ale jako charakterystykę opublikowanego zbioru danych, nie jako główną analizę badawczą.

Koniecznie przerobić:

- sekcję `Dostępność danych i kodu`, bo obecnie mówi, że dataset i kod są materiałami wewnętrznymi; po decyzji o Zenodo musi wskazywać DOI datasetu, repozytorium kodu i wersję/release,
- strukturę tekstu pod Scientific Data: `Background & Summary`, `Methods`, `Data Records`, `Technical Validation`, `Usage Notes`, `Data availability`, `Code availability`,
- sekcje metodologiczne połączyć logicznie w `Methods`: pobieranie źródeł, ekstrakcja, import, normalizacja, korekty, geokodowanie, grupowanie punktów,
- walidację przenieść i scalić w `Technical Validation`: próba losowa, statusy jakości, kontrola SIM, wpływ nierozstrzygniętych przypadków,
- `Wyniki podstawowe` ograniczyć do opisu zawartości datasetu i potencjalnych zastosowań; nie robić z tego głównej sekcji wynikowej,
- `Reprodukowalność` zamienić na konkretne instrukcje i referencje do tasków/pipeline/release/checksumów,
- usunąć albo mocno skrócić anegdotyczne przykłady pojedynczych lokali/adresów; jeżeli zostają, powinny służyć wyłącznie wyjaśnieniu ograniczeń lub walidacji.

Dodać:

- osobną sekcję `Data Records` z listą plików w paczce Zenodo, liczbą wierszy, kluczami głównymi i relacjami między tabelami,
- jasne rozróżnienie warstw danych: `raw`, `extracted`, `normalized`, `geocoded`, `curated`, `derived`,
- tabelę typu: `plik -> poziom danych -> do czego używać -> główne klucze`,
- sekcję `Usage Notes` z typowymi scenariuszami: praca na poziomie pojedynczych zezwoleń, punktów sprzedaży, agregacji po dzielnicach/SIM i GeoJSON w GIS,
- finalne liczby po zamrożeniu datasetu: liczba raportów, licencji, surowych lokalizacji, znormalizowanych lokalizacji, punktów, korekt, wybranych geokodowań i wyników walidacji,
- osobne informacje o licencji danych i licencji kodu,
- DataCite/Zenodo DOI oraz GitHub release/tag użyty do wygenerowania datasetu.

### Eksport datasetu

Eksport powinien być podzielony na dwie warstwy:

- `core dataset`: tabele, z których większość badaczy ma bezpośrednio korzystać,
- `provenance/audit`: tabele dokumentujące, jak dane powstały i jak były kontrolowane.

Core dataset powinien zawierać:

- `reports.csv`,
- `alcohol_licenses.csv`,
- `license_points.csv`,
- `point_memberships.csv`,
- `locations_raw.csv`,
- `locations_normalized.csv`,
- `sim_populations.csv`,
- `license_points_latest.geojson`,
- `sim_units.geojson`,
- `city_summary_by_report.csv`,
- `district_summary_by_report.csv`,
- `sim_summary_by_report.csv`.

Provenance/audit powinien zawierać:

- `source_files_manifest.csv`,
- `address_corrections.csv`,
- `geocoding_results.csv`,
- `geocoding_reviews.csv`.

Koniecznie usunąć z publicznych tabel albo przenieść wyłącznie do niepublikowanego/debugowego crosswalka:

- `internal_license_id`,
- `internal_license_point_group_id`,
- `internal_location_ids`,
- `internal_transformed_location_id`,
- wszystkie inne identyfikatory wynikające bezpośrednio z Rails/SQLite/Postgres ID.

Krytyczny problem do poprawy przed Zenodo:

- publiczne `point_id` nie może zależeć od `internal_group_id`; musi być deterministyczne z danych wejściowych i stabilne po odtworzeniu pipeline w klonie,
- `selected_geocoding_result_id` w `locations_normalized.csv` powinno wskazywać publiczne stabilne ID geokodowania, a nie wewnętrzne ID rekordu bazy.

Kolumny do usunięcia, przeniesienia do provenance albo ponownego nazwania:

- `source_row_number` w `alcohol_licenses.csv` - usunąć, jeżeli nadal jest puste/nieużywane,
- `created_at` w `geocoding_results.csv` i `address_corrections.csv` - raczej usunąć z publikacji, bo to timestamp procesu, nie cecha danych,
- `reviewed_by` w `geocoding_reviews.csv` - usunąć, jeśli nie jest potrzebne do walidacji między annotatorami,
- `note` w `geocoding_reviews.csv` - usunąć albo ręcznie przeaudytować przed publikacją,
- `evidence` w `address_corrections.csv` - przeaudytować, bo to wolny tekst,
- `geocoding_query` w tabelach głównych przenieść do provenance,
- `latest_review_status` w `license_points.csv` uprościć albo przenieść do tabeli audit, bo statusy z wielu lokalizacji w jednym punkcie są niejednoznaczne,
- `business_id_count` usunąć albo bardzo dokładnie opisać, bo brzmi jak wewnętrzna metryka aplikacji.

Nazewnictwo do ujednolicenia:

- konsekwentnie używać `sim_unit`, a nie mieszać `sim`, `sim_area`, `sim_unit`,
- rozważyć zmianę `business_key` na `business_pseudonym` albo jasno opisać, że to deterministyczny hash/pseudonim, nie anonimizacja,
- `raw_address_2` w `locations_normalized.csv` zmienić na nazwę wyjaśniającą, że to pole wejściowe normalizacji, np. `normalization_input_address_2`, albo usunąć,
- współrzędne w `alcohol_licenses.csv` nazwać jednoznacznie jako współrzędne znormalizowanej lokalizacji albo usunąć i zostawić geometrię w `license_points.csv`.

Dokumentacja eksportu do poprawy:

- `README` i `CODEBOOK` powinny jasno wskazywać, które pliki są podstawowe, a które są audit/provenance,
- `CODEBOOK` powinien mieć ręcznie napisane definicje najważniejszych kolumn, a nie tylko automatyczne ogólne opisy,
- `source_files_manifest.csv` powinien mieć kompletne źródła: URL, typ pliku, data raportu, data pobrania albo informacja, że plik pochodzi z repozytorium/paczki źródłowej,
- jeżeli raw PDF/XLSX nie są publikowane w Zenodo, paper i README muszą wyraźnie wskazać, skąd je odtworzyć i dlaczego nie są częścią paczki.

Wniosek ogólny: nie należy usuwać provenance, bo dla `Scientific Data` jest bardzo wartościowe, ale trzeba oddzielić je od tabel użytkowych i usunąć z publicznego eksportu wewnętrzne ID oraz pola techniczne, które nie są stabilną częścią modelu danych.
