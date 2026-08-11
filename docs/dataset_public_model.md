# Publiczny model datasetu

Ten dokument opisuje publiczny model danych dla wersjonowanego datasetu
wspierajacego manuskrypt pracy. Model publiczny jest oddzielony od modelu
aplikacji Rails: moze korzystac z wewnetrznych tabel jako zrodla, ale nie
powinien ujawniac przypadkowych nazw kolumn, lokalnych sciezek ani
niestabilnych identyfikatorow bazodanowych jako podstawowych kluczy.

## Jednostki danych

### `report`

Jedna data raportu wykazu zezwoleń.

Raport jest wspolnym wymiarem czasu dla zezwoleń, punktow sprzedazy i agregatow.
W danych publicznych powinien miec:

- `report_id` - stabilny identyfikator tekstowy,
- `reported_at` - pelny znacznik czasu w ISO 8601,
- `report_date` - data kalendarzowa.

### `license`

Pojedynczy rekord administracyjny zezwolenia na sprzedaz alkoholu.

Licencja odpowiada wierszowi z wykazu dla jednej kategorii alkoholu i jednego
typu dzialalnosci. Nie jest rownoznaczna z lokalem ani punktem sprzedazy.
Jeden sklep lub lokal gastronomiczny moze miec kilka rekordow `license`.

### `raw_location`

Adres zrodlowy zapisany w wykazie.

Adres zrodlowy jest zachowywany bez zastapienia go wersja poprawiona. Dzieki
temu mozna sprawdzic, czy problem pochodzi z wykazu, ekstrakcji, normalizacji
czy pozniejszej interpretacji.

Publiczne `raw_location_id` powstaje z kanonicznej postaci adresu zrodlowego:
wartosci sa przycinane i wielokrotne spacje sa redukowane. Dlatego kilka
wewnetrznych rekordow `locations` rozniacych sie tylko spacja moze trafic do
jednego wiersza `locations_raw.csv`. Wewnetrzne identyfikatory rekordow
aplikacji nie sa publikowane.

Korekty adresow sa publikowane osobno w `address_corrections.csv`. Korekta nie
nadpisuje adresu zrodlowego; pokazuje, jaka poprawka zostala uzyta w procesie
normalizacji, z jakiego zrodla/metody pochodzi i czy zostala wybrana.

### `normalized_location`

Lokalizacja po normalizacji adresu, korektach i klasyfikacji typu miejsca.

Ta jednostka jest uzywana do geokodowania. Moze reprezentowac adres uliczny,
dzialke, pawilon, lokalizacje opisowa, obiekt nazwany lub adres zlozony.

`locations_normalized.csv` publikuje wybrany wynik geokodowania i wspolrzedne
w ukladzie `EPSG:4326`, ale nie publikuje technicznych kolumn poszczegolnych
geokoderow, np. `google_latitude` albo `google_longitude`. Dodatkowe
wspolrzedne alternatywne moga zostac dodane tylko jako jawnie opisana warstwa
provenance z kompletna licencja i atrybucja.

`geocoding_results.csv` publikuje kandydatow geokodowania spoza Google i nie
zawiera `raw_response`. Rekordy `source = google` sa wykluczone z publicznego
eksportu; w obecnym stanie danych zaden wybrany wynik (`selected = true`) nie
pochodzi z Google.

`geocoding_reviews.csv` publikuje decyzje audytowe lokalizacji bez
identyfikatorow recenzentow i bez wolnotekstowych notatek. Referencje do
wynikow geokodowania sa publikowane tylko wtedy, gdy wskazywany wynik istnieje
w publicznym `geocoding_results.csv`; referencje do wykluczonych wynikow Google
pozostaja puste.

### `business`

Podmiot z wykazu albo jego publiczny identyfikator.

Wykazy zawieraja nazwy podmiotow gospodarczych, nie nazwy szyldow. Ze wzgledu
na mozliwa obecnosc jednoosobowych dzialalnosci gospodarczych glowny eksport
powinien domyslnie uzywac `business_key`, `business_count` i liczebnosci.
Pelne nazwy podmiotow moga byc wlaczane tylko jawnie jako warstwa provenance.

### `license_point`

Analityczny punkt sprzedazy w konkretnej dacie raportu.

`license_point` powstaje przez grupowanie zezwoleń przypisanych do tej samej
znormalizowanej lokalizacji, lokalu formalnego, jezeli jest dostepny, oraz tego
samego albo bardzo podobnego podmiotu. Jest to jednostka analityczna, nie
urzedowy lokal, nie szyld i nie terenowo potwierdzony lokal uzytkowy.

Pierwszy release zawiera takze punkty fallback dla geokodowanych zezwoleń,
ktore nie maja jeszcze utrwalonego rekordu `LicensePointGroup`. Dzieki temu
kazde geokodowane zezwolenie z `alcohol_licenses.csv` wskazuje na istniejacy
`point_id` w `license_points.csv`.

`data/geospatial/license_points_latest.geojson` jest warstwa punktowa dla
ostatniego raportu. Zawiera te same publiczne atrybuty co `license_points.csv`,
ale wspolrzedne sa przeniesione do geometrii GeoJSON w kolejnosci
`[longitude, latitude]` i w ukladzie `EPSG:4326`. Warstwa jest przeznaczona do
szybkiego uzycia w QGIS, GeoPandas i narzedziach web map; pelny panel czasowy
pozostaje zrodlem prawdy w `license_points.csv` i `point_memberships.csv`.

### `point_membership`

Relacja miedzy zezwoleniem a analitycznym punktem sprzedazy.

Tabela `point_memberships.csv` ma jeden wiersz dla kazdego zezwolenia. Dla
zezwoleń geokodowanych `point_id` jest niepusty i wskazuje na
`license_points.csv`. Dla zezwoleń niegeokodowanych `point_id` pozostaje pusty,
a `membership_method = not_geocoded`, zeby zachowac pelna rozliczalnosc
rekordow bez sztucznego tworzenia punktu.

`membership_method` rozroznia:

- `license_point_group` - przypisanie pochodzi z utrwalonego grupowania punktow,
- `fallback_business_location` - przypisanie zbudowano deterministycznie z
  geokodowanej lokalizacji i podmiotu, bo brak utrwalonej grupy,
- `not_geocoded` - zezwolenie nie ma wspolrzednych i nie moze wskazac punktu.

### `sim_unit`

Jednostka SIM uzyta do agregacji przestrzennej.

Punkty sa przypisywane do jednostek SIM metoda point-in-polygon na podstawie
opublikowanej geometrii jednostek. Dane ludnosciowe sa dobierane jako najnowszy
snapshot nie pozniejszy niz data raportu.

`sim_populations.csv` zawiera historyczne liczby osob zameldowanych wedlug
jednostek SIM. `sim_units.geojson` zawiera granice SIM w `EPSG:4326`, kody
jednostek i dzielnic oraz `area_km2` liczone z geometrii. GeoPackage jest
traktowany jako krok pakowania zalezy od dostepnosci `ogr2ogr` albo rownowaznej
biblioteki.

## Rozroznienie licznikow

- `license_count` oznacza liczbe rekordow administracyjnych zezwoleń.
- `point_count` oznacza liczbe analitycznych punktow sprzedazy po grupowaniu.
- `business_count` oznacza liczbe roznych publicznych identyfikatorow podmiotow
  w punkcie.
- `point_memberships.csv` jest tabela kontrolna: suma niepustych przypisan do
  danego `point_id` musi byc rowna `license_points.license_count`.

Tych miar nie nalezy uzywac zamiennie. W szczegolnosci suma zezwoleń zawyza
liczbe miejsc widocznych w przestrzeni miasta, poniewaz jeden punkt moze miec
zezwolenia dla kategorii A, B i C oraz dla detalu i gastronomii.

## Agregaty obszarowe

Agregaty w `data/aggregates/` sa liczone z publicznych tabel release. Poziom
miasta uzywa pelnej administracyjnej liczby zezwoleń z `alcohol_licenses.csv`.
Poziomy dzielnic i jednostek SIM uzywaja `license_points.license_count`, czyli
liczby zezwoleń przypisanych do publicznych punktow sprzedazy w danym obszarze.
To zachowuje zgodnosc z analityczna jednostka przestrzenna i unika rozjazdow
wynikajacych z pojedynczych rekordow licencji, ktorych wspolrzedne moga roznic
sie od reprezentatywnego punktu grupy.

## Format Parquet

CSV pozostaje kanonicznym formatem tabelarycznym release. Pliki Parquet w
`data/parquet/` sa generowane po eksporcie przez `dataset:package` z publicznych
CSV i sluza wygodnemu uzyciu w narzedziach analitycznych takich jak DuckDB,
Polars, Pandas, Spark albo R Arrow. Raport `metadata/package_report.json`
zawiera uzyty backend, liczby wierszy i schematy wykryte w plikach Parquet.

Jesli `pyarrow` nie jest dostepny, `dataset:package` nie modyfikuje podstawowego
release i zapisuje status `skipped`; `dataset:export` i `dataset:validate` nie
maja twardej zaleznosci od Parquet.

## Polityka nazw podmiotow

Domyslny release:

- publikuje `business_key`,
- publikuje `business_count`,
- publikuje liczebnosci zezwoleń wedlug kategorii i typu dzialalnosci,
- nie publikuje pelnej nazwy podmiotu w glownych tabelach.

Opcjonalna warstwa provenance:

- moze publikowac `business_name`,
- musi byc wlaczana jawnie parametrem eksportu,
- musi byc opisana w `NOTICE.md`,
- musi zachowac informację, ze sa to nazwy podmiotow z wykazow, a nie szyldy
  lokali.

## Sciezka pochodzenia rekordu

Docelowy dataset powinien pozwalac odtworzyc sciezke:

```text
license
  -> source_file
  -> raw_location
  -> normalized_location
  -> geocoding_result
  -> license_point
  -> sim_unit / district
```

`alcohol_licenses.csv` zawiera publiczne `source_file_id`, ktore laczy rekord
z manifestem zrodel na poziomie raportu, kategorii dzialalnosci i kategorii
zezwolenia. Publiczny release nie publikuje numerow wierszy zrodlowych, dopoki
nie sa utrwalone jako stabilna czesc modelu importu. `license_id` jest liczony
deterministycznie z dostepnych pol rekordu, a manifest zrodel dokumentuje pliki,
z ktorych rekordy powstaly.
