# Audyt źródeł i pipeline pozyskiwania raportów

Data audytu: 2026-08-11.

## Kontekst decyzyjny

Problem nie sprowadza się do wyboru „stara baza” kontra „świeży clone”. Te dwa stany odpowiadają różnym rzeczom:

- stara baza zawiera wykonaną już kurację: korekty, decyzje geokodowania, review i grupowania;
- świeży clone pokazuje, co obecny kod odtwarza z pełnego katalogu źródeł;
- katalog źródeł zawiera dwa kanały danych: PDF-y BIP z ekstraktami CSV oraz historyczne XLS/XLSX.

Docelowo pipeline publikacyjny powinien umieć pobrać wszystkie PDF-y crawlerem, zrobić z nich CSV, zwalidować ekstrakcję i dopiero wtedy importować dane. Obecnie ten kierunek istnieje w repo jako prototyp (`vendor/crawler/crawler.rb`, `vendor/extractor/extractor.py`), ale nie jest jeszcze produkcyjnym, deterministycznym etapem `research:*`.

## Obecny stan źródeł w repo

Policzone pliki źródłowe:

| Typ | Liczba plików | Liczba snapshotów/dat |
| --- | ---: | ---: |
| PDF BIP `vendor/data/files/**/*.pdf` | 180 | 30 snapshotów |
| CSV po ekstrakcji PDF `vendor/data/files/output/*.csv` | 180 | 30 snapshotów |
| XLS/XLSX `vendor/data/xlsx/*.xls*` | 336 | 56 dat |

Kompletność PDF/CSV:

- każdy snapshot PDF ma komplet 6 plików: `detal/gastronomia` × `A/B/C`;
- każdy PDF ma odpowiadający CSV po pełnym timestampie, typie działalności i kategorii zezwolenia;
- nie ma CSV bez odpowiadającego PDF;
- nie ma niekompletnych snapshotów PDF ani CSV.

To oznacza, że obecny katalog `vendor/data/files` jest spójny jako para: `PDF -> CSV`. Problemem nie jest brak ekstraktu dla istniejących PDF-ów, tylko jakość ekstrakcji oraz decyzja, jak traktować overlap z XLSX.

## Crawler i ekstraktor

### `vendor/crawler/crawler.rb`

Crawler pobiera stronę BIP `dok_id=30394&vReg=2`, przechodzi po wersjach dokumentu i zapisuje PDF-y do `data/files/...`.

Ryzyka techniczne:

- ścieżka zapisu jest względna wobec katalogu `vendor/crawler`, a nie zintegrowana z Rails root;
- brak manifestu pobrań: URL, retrieved_at, status HTTP, sha256, rozmiar pliku;
- brak retry/backoff i obsługi częściowo pobranych plików;
- brak trybu dry-run i raportu różnic między poprzednim a nowym crawlem;
- parser HTML jest kruchy (`p:contains`, `button:contains("zobacz")`);
- crawler nie jest taskiem rake w głównym pipeline.

### `vendor/extractor/extractor.py`

Ekstraktor przechodzi po PDF-ach i zapisuje CSV do `../data/files/output/` przy użyciu `tabula-py`.

Ryzyka techniczne:

- działa jako skrypt import-time: `convert_pdf_files()` wykonuje się przy uruchomieniu pliku;
- walidacje są tylko drukowane do stdout, nie blokują zapisu złego CSV;
- brak manifestu ekstrakcji: wersja narzędzia, Java/tabula, parametry kolumn, sha256 PDF wejściowego, sha256 CSV wyjściowego;
- brak testów regresyjnych na znanych PDF-ach;
- brak jednoznacznego statusu ekstrakcji per plik;
- ekstrakcja generuje artefakty łamania tekstu, zwłaszcza przy myślnikach i rozbitych nazwach ulic/firm.

## Relacja PDF/CSV do XLSX

Po pełnym timestampie `reported_at` CSV/PDF i XLSX się nie nakładają, bo CSV/PDF mają timestamp wersji BIP, np. `2020-08-04 13:29:58`, a XLSX są nazwane datą dzienną lub miesięczną.

Po dacie kalendarzowej, typie działalności i kategorii zezwolenia jest jednak `36` overlapów CSV/XLSX. Obejmują one pełne zestawy 6 kategorii dla dat:

- `2014-07-03`,
- `2015-09-08`,
- `2016-01-18`,
- `2018-05-30`,
- `2019-05-17`,
- `2020-08-04`.

Dla wszystkich 36 overlapów liczba wierszy CSV i XLSX jest identyczna. To silnie sugeruje, że reprezentują ten sam stan administracyjny, zapisany w dwóch formatach.

Treść rekordów nie jest bajtowo identyczna po prostym porównaniu pól. Różnice typowe dla CSV z PDF:

- `ALEJA GEN. BORA- KOMOROWSKIEGO` vs `ALEJA GEN. BORA-KOMOROWSKIEGO`,
- `KARASZEWICZA- TOKARZEWSKIEGO` vs `KARASZEWICZA-TOKARZEWSKIEGO`,
- `KOMANDYTOWO- AKCYJNA` vs `KOMANDYTOWO-AKCYJNA`.

Wniosek: dla overlapów XLSX wygląda na czystszy format źródłowy, a CSV z PDF wymaga dodatkowego czyszczenia tekstu albo powinien być traktowany jako źródło wtórne względem XLSX.

## Duplikaty treści w CSV/PDF

W CSV jest `42` grup duplikatów treści po hashach pliku w ramach tej samej kategorii. Najważniejsze pełne duplikaty snapshotów:

- `2013-12-05 09:37:36` = `2014-03-07 13:54:25`,
- `2017-09-26 09:56:20` = `2018-03-22 12:31:22`,
- `2018-11-15 14:19:26` = `2018-11-15 14:22:20`,
- `2019-05-17 11:51:19` = `2019-05-20 12:31:58`.

To nie musi oznaczać błędu. Urząd mógł opublikować nową wersję dokumentu bez zmian w tabeli. Ale dla datasetu naukowego trzeba jawnie zdecydować, czy:

- każdy opublikowany snapshot jest osobną obserwacją czasową, nawet jeśli treść się nie zmieniła;
- czy identyczne snapshoty są deduplikowane do pierwszej/ostatniej publikacji.

Bez jawnej polityki import „wszystko z katalogu” zawyża liczbę raportów względem bazy referencyjnej i miesza decyzje kuratorskie.

## Ocena jakości: co jest lepsze

### Stara baza

Zalety:

- zawiera Twoją wykonaną kurację i review;
- ma działające grupowania i geokodowanie;
- jest bliżej stanu analizowanego w pracy.

Wady:

- nie odpowiada pełnemu obecnemu katalogowi źródeł;
- nie jest w pełni reprodukowalna od zera obecnymi taskami;
- nie ma jawnego manifestu źródeł, który mówi, dlaczego część PDF/CSV nie weszła.

### Świeży clone

Zalety:

- odtwarza to, co obecny pipeline robi z pełnym katalogiem lokalnych źródeł;
- ujawnia brak manifestu i problemy snapshotu kuratorskiego;
- pokazuje dodatkowe raporty PDF/CSV, które są realnie w repo.

Wady:

- importuje brudne artefakty ekstrakcji PDF;
- dubluje overlap CSV/XLSX jako osobne raporty, jeśli daty nie są ujednolicone;
- nie przenosi stabilnie kuracji, bo snapshot mapuje `TransformedLocation` także po `raw_address_2` i `same_as`;
- zatrzymuje się na imporcie decyzji geokodowania.


## Wynik testu konwertera PDF->CSV

Konwerter został uruchomiony kontrolnie na reprezentatywnych PDF-ach bez nadpisywania repo. Wyniki:

- `2014-07-03 detal A`: ekstrakcja zwróciła `1345` wierszy, indeksy poprawne, bez duplikatów LP; wynik nie jest bajtowo identyczny z obecnym CSV, a `42` rekordy różnią się głównie usunięciem podwójnych spacji w nazwach firm.
- `2018-11-15 14:19:26 gastronomia B`: ekstrakcja zwróciła `1237` wierszy, indeksy poprawne, bez duplikatów LP; `14` rekordów różni się głównie whitespace.
- `2026-02-06 detal C`: ekstrakcja zwróciła `1284` wiersze i jest bajtowo identyczna z obecnym CSV.

Wniosek techniczny: obecny konwerter działa w tym sensie, że potrafi wyciągnąć komplet wierszy z testowanych PDF-ów i zachować poprawne LP. Nie jest jednak wystarczający jako automatyczny, bezwarunkowo zaufany etap publikacyjny, bo wynik zależy od wersji narzędzi i niektóre stare CSV nie są reprodukowane bajtowo.

Audyt wszystkich istniejących CSV po ekstrakcji PDF:

| Kontrola | Wynik |
| --- | ---: |
| Pliki CSV | 180 |
| Wiersze CSV | 226531 |
| Pliki z nieciągłym indeksem LP | 0 |
| Pliki z duplikatami LP | 0 |
| Wartości z podwójnymi spacjami | 2574 |
| Wartości z artefaktem `litera- spacja litera` | 1679 |
| Numery adresowe typu `91.0` | 1800 |
| Znaki zastępcze kodowania | 0 |

Po porównaniu 36 overlapów CSV/XLSX:

- liczba wierszy jest zgodna w 36/36 przypadków;
- po prostym czyszczeniu spacji po myślniku zgodne staje się tylko 17/36 przypadków;
- pozostałe różnice obejmują poważniejsze artefakty, np. rozbite lub sklejone nazwy firm i fragmenty adresów.

Przykłady problemów z PDF/CSV względem XLSX:

- `BORA- KOMOROWSKIEGO` zamiast `BORA-KOMOROWSKIEGO`,
- `L U2` zamiast `LU2`,
- `SPÓŁKAZ O.O.` zamiast `SPÓŁKA Z O.O.`,
- rozbite nazwy firm na sąsiednie wiersze w trudniejszych ekstrakcjach.

Konkluzja: CSV z PDF mogą być źródłem dla dat bez XLSX, ale przed publikacją wymagają walidacji i warstwy czyszczenia artefaktów ekstrakcji. Dla overlapów XLSX powinien pozostać preferowanym źródłem danych.

## Rekomendowana polityka publikacyjna

Najbardziej obronna naukowo polityka to nie wybierać mechanicznie ani starej bazy, ani świeżego clone. Należy zbudować jawny `publication_source_manifest`.

Proponowana hierarchia źródeł:

1. Dla okresów, gdzie istnieje tylko XLS/XLSX: używać XLS/XLSX jako źródła pierwotnego.
2. Dla okresów, gdzie istnieje tylko PDF/CSV: używać PDF pobranego crawlerem i CSV wygenerowanego ekstraktorem, po walidacji jakości.
3. Dla overlapów XLSX i PDF/CSV: preferować XLSX jako czystszy kanał danych, a PDF/CSV zachować w manifeście jako źródło równoległe/dowód publikacji BIP, nie importować obu jako osobnych raportów.
4. Dla identycznych PDF/CSV o różnych timestampach: zachować oba w źródłach, ale w tabeli raportów oznaczyć relację `content_duplicate_of` albo zdecydować, czy obserwacją jest publikacja, czy zmiana treści.
5. Dla pracy naukowej jasno opisać wybór: „jednostką czasu jest opublikowany snapshot” albo „jednostką czasu jest unikalny stan tabeli”.

Moja rekomendacja dla jakości danych: jednostką analityczną powinien być **unikalny stan tabeli raportu**, a nie każda publikacja BIP z identyczną treścią. W źródłowym manifeście należy jednak zachować wszystkie publikacje BIP i ich hashe.


Aktualna reguła zaimplementowana w importerze: ostatnia data arkusza to `2021-04-15`; CSV z PDF są importowane dopiero od 7 dni po tej dacie, czyli od `2021-04-22`. Na obecnym katalogu źródeł daje to `336` plików XLS/XLSX, `48` importowanych CSV po PDF oraz `132` pominięte CSV z wcześniejszego lub zbyt bliskiego okresu. Pierwsza importowana data PDF/CSV to `2021-12-30`, a łączna liczba dat raportów wynosi `64`.

## Wymagane zmiany w pipeline

### 1. Produkcyjny crawler

Dodać task np. `source_data:crawl_bip_pdfs`, który:

- pobiera wszystkie wersje PDF z BIP;
- zapisuje PDF-y w stabilnych ścieżkach;
- tworzy manifest pobrań z URL, timestampem, sha256, rozmiarem i statusem;
- ma retry/backoff;
- nie nadpisuje istniejących plików bez porównania hasha;
- raportuje nowe, zmienione i brakujące pliki.

### 2. Produkcyjny ekstraktor PDF->CSV

Dodać task np. `source_data:extract_pdf_tables`, który:

- bierze PDF-y z manifestu crawla;
- generuje CSV deterministycznie;
- zapisuje manifest ekstrakcji z wersją narzędzi i parametrami;
- waliduje indeksy, liczbę wierszy, duplikaty LP i schemat kolumn;
- kończy się błędem, jeśli ekstrakcja nie przejdzie walidacji;
- ma testy regresyjne na wybranych PDF-ach z trudnymi przypadkami.

### 3. Manifest publikacyjny

Dodać plik np. `db/publication/source_manifest.yml` albo `data/source_manifest.csv`, który dla każdego logicznego raportu zawiera:

- `report_id`,
- `report_date`,
- `reported_at`,
- `business_category`,
- `license_category`,
- `preferred_source` (`xlsx`, `pdf_csv`),
- `source_file_id`,
- `content_sha256`,
- `content_duplicate_of`,
- `quality_status`,
- `quality_notes`.

Importer publikacyjny powinien importować tylko manifest, nie glob `vendor/data/**/*`.

### 4. Import bez utraty kuracji

Decyzje kuratorskie nie powinny mapować `TransformedLocation` po `raw_address_2` i `same_as`. Te pola są opisowe i zależą od tego, który surowy wariant adresu akurat został reprezentatywny po pełniejszym imporcie.

Snapshot kuracji powinien mapować po:

- stabilnym identyfikatorze z manifestu/normalizacji,
- albo geokodowalnej tożsamości bez `raw_address_2` i `same_as`,
- plus ręczny fallback dla faktycznych konfliktów.

## Decyzja praktyczna na teraz

Na ten moment nie należy traktować świeżego clone jako lepszego datasetu. Clone jest dobrym testem ujawniającym problemy pipeline, ale nie jakość końcową.

Kolejny techniczny krok powinien być taki:

1. Wygenerować kandydacki manifest publikacyjny.
2. Dla overlapów CSV/XLSX oznaczyć XLSX jako preferowane źródło.
3. Dla PDF/CSV bez XLSX przeprowadzić walidację ekstrakcji i czyszczenie artefaktów.
4. Dla duplikatów treści zdecydować, czy trzymamy unikalny stan czy każdą publikację.
5. Odtworzyć bazę z manifestu i dopiero wtedy przenieść kurację.

Taki proces zachowuje wykonaną pracę jakościową, a jednocześnie daje wyższy standard reprodukowalności i obrony metodologicznej dla publikacji datasetu.
