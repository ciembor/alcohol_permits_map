# Plan pracy naukowej

## Temat roboczy

Przestrzenna i czasowa analiza zezwoleń na sprzedaż alkoholu w Krakowie na podstawie danych publicznych BIP oraz historycznych danych urzędowych.

## Cel pracy

Celem pracy jest stworzenie odtwarzalnego procesu pozyskania, ekstrakcji, czyszczenia, normalizacji i analizy danych o zezwoleniach na sprzedaż alkoholu w Krakowie, a następnie wykorzystanie go do opisu zmian w czasie oraz rozmieszczenia punktów sprzedaży alkoholu w przestrzeni miasta.

Praca ma pokazać nie tylko finalne statystyki, ale też metodę pracy z trudnymi danymi administracyjnymi: PDF-ami, arkuszami historycznymi, niespójnymi nazwami podmiotów, adresami wymagającymi normalizacji oraz danymi przestrzennymi.

## Główne pytania badawcze

1. Jak zmieniała się liczba zezwoleń na sprzedaż alkoholu w Krakowie w czasie?
2. Jak zmieniała się liczba lokali/punktów sprzedaży, po zgrupowaniu wielu zezwoleń i wariantów nazw tego samego podmiotu?
3. Jak rozkładają się zezwolenia według typu działalności: detal i gastronomia?
4. Jak rozkładają się zezwolenia według kategorii alkoholu: A, B i C?
5. Które dzielnice oraz jednostki SIM mają największą koncentrację zezwoleń i lokali?
6. Czy dynamika zmian różni się między centrum, dzielnicami mieszkaniowymi i obszarami peryferyjnymi?
7. Jak bardzo wyniki zależą od jakości czyszczenia danych, normalizacji adresów i grupowania nazw podmiotów?

## Zakres danych

### Źródła podstawowe

1. BIP Miasta Krakowa:
   - bieżące i historyczne wykazy zezwoleń,
   - pliki PDF,
   - załączniki i wersje dokumentów publikowane w różnych formatach.

2. Historyczne arkusze z urzędu:
   - pliki Excel/CSV pozyskane wcześniej,
   - wersje archiwalne różniące się strukturą kolumn,
   - dane wymagające ręcznego lub półautomatycznego mapowania pól.

3. Dane przestrzenne:
   - adresy i lokalizacje punktów sprzedaży,
   - oficjalne jednostki SIM Krakowa,
   - dzielnice samorządowe,
   - granice obszarów potrzebne do agregacji przestrzennej.

### Zakres czasowy

Do opisania dokładnie po audycie danych:

- najstarsza dostępna wersja danych,
- wszystkie daty raportów,
- najnowszy raport,
- luki i nieciągłości w danych.

## Etapy pracy

### 1. Inwentaryzacja źródeł

Zadania:

- zebrać listę wszystkich źródeł danych,
- opisać pochodzenie każdego pliku,
- zapisać datę publikacji lub datę raportu,
- oznaczyć format: PDF, XLS, XLSX, CSV, HTML,
- wskazać, które pliki pochodzą z BIP, a które z wcześniejszych udostępnień urzędu,
- stworzyć tabelę metadanych źródeł.

Rezultat:

- katalog źródeł danych,
- tabela `source_inventory`,
- opis wiarygodności i kompletności źródeł.

### 2. Pozyskanie danych z BIP

Zadania:

- odtworzyć ścieżkę pobierania dokumentów z BIP,
- zapisać adresy URL dokumentów,
- pobrać wszystkie dostępne wersje,
- zachować oryginalne pliki bez modyfikacji,
- nadać plikom stabilne nazwy zawierające datę raportu i typ danych,
- przygotować mechanizm sprawdzania, czy pojawiły się nowe wersje.

Rezultat:

- surowe pliki w katalogu danych,
- lista URL-i i dat pobrania,
- skrypt lub rake task do ponownego pobrania danych.

### 3. Ekstrakcja danych z PDF

Zadania:

- rozpoznać typy PDF-ów:
  - tekstowe,
  - skanowane,
  - mieszane,
  - tabele o zmiennym układzie.
- dobrać metodę ekstrakcji:
  - parser tekstu,
  - ekstrakcja tabel,
  - OCR tylko tam, gdzie jest konieczny.
- zdefiniować kolumny docelowe:
  - data raportu,
  - nazwa podmiotu,
  - adres,
  - typ działalności,
  - kategoria zezwolenia,
  - data ważności,
  - identyfikator źródła.
- zapisać każdy etap ekstrakcji do plików pośrednich,
- oznaczać rekordy niepewne.

Rezultat:

- surowe tabele wyciągnięte z PDF,
- log błędów ekstrakcji,
- porównanie liczby rekordów z oczekiwaniami.

### 4. Import historycznych Exceli i CSV

Zadania:

- rozpoznać schemat każdego arkusza,
- zmapować kolumny na wspólny model danych,
- ujednolicić format dat,
- ujednolicić nazwy kategorii zezwoleń,
- oznaczyć źródło każdego rekordu,
- wykryć duplikaty wynikające z powtórzonego importu lub różnych wersji tego samego raportu.

Rezultat:

- wspólny format tabelaryczny,
- kompletna historia raportów,
- dokumentacja różnic między plikami.

### 5. Model danych

Minimalny model logiczny:

- `reports` lub data raportu,
- `businesses` - podmioty / nazwy z rejestru,
- `locations` - adresy źródłowe,
- `transformed_locations` - adresy po normalizacji,
- `alcohol_licenses` - pojedyncze zezwolenia,
- `business_categories` - detal/gastronomia,
- `license_categories` - A/B/C,
- `license_point_groups` - utrwalone grupy lokali/punktów po normalizacji nazw i adresów.

W pracy trzeba jasno rozdzielić:

- zezwolenie - pojedynczy rekord administracyjny,
- podmiot - nazwa firmy z danych,
- lokal/punkt - miejsce na mapie po grupowaniu,
- grupa nazw - kilka wariantów nazwy tego samego lub bardzo podobnego podmiotu w tym samym miejscu.

### 6. Czyszczenie danych

Zadania:

- usunąć techniczne artefakty z ekstrakcji PDF,
- ujednolicić wielkość liter,
- usunąć nadmiarowe spacje i znaki interpunkcyjne,
- ujednolicić polskie znaki tylko na potrzeby porównań,
- zachować oryginalne nazwy do prezentacji i kontroli,
- rozpoznać błędy literowe w typowych frazach prawnych,
- oznaczyć rekordy wymagające ręcznej kontroli.

Przykładowe problemy:

- `SPÓŁKA Z O.O.`,
- `SP. Z O.O.`,
- `SPÓŁKA Z O.O.O.`,
- `SPÓLKA`,
- `ODPOWIEDZILANOŚCIĄ`,
- różne odstępy i interpunkcja,
- stare i nowe warianty tej samej nazwy.

### 7. Normalizacja nazw podmiotów

Zadania:

- przygotować listę słów pomijanych w porównaniach:
  - formy prawne,
  - słowa organizacyjne,
  - lokalizacje typu Kraków/Polska,
  - częste człony nieniosące unikalnej informacji.
- nie usuwać automatycznie imion, nazwisk i marek,
- porównywać nazwy po:
  - usunięciu polskich znaków,
  - ujednoliceniu wielkości liter,
  - usunięciu słów ogólnych,
  - tokenizacji.
- zastosować miarę podobieństwa nazw,
- przyjąć próg roboczy 90% podobieństwa,
- grupować tylko w obrębie tego samego miejsca/adresu,
- zapisać wynik grupowania w bazie, aby analiza i mapa nie liczyły tego w locie.

Rezultat:

- słownik normalizacji nazw,
- dokumentacja progu podobieństwa,
- lista przykładów poprawnych i błędnych zgrupowań,
- tabela grup punktów.

### 8. Normalizacja adresów

Zadania:

- rozdzielić adres źródłowy na:
  - ulicę,
  - numer budynku,
  - numer lokalu/pawilonu,
  - opis dodatkowy,
  - działkę lub obręb, jeśli występuje.
- ujednolicić skróty ulic i placów,
- rozwiązać błędy literowe,
- obsłużyć adresy opisowe,
- zachować oryginalny adres obok adresu przetworzonego,
- przygotować słownik korekt adresów.

Rezultat:

- tabela adresów przetworzonych,
- lista korekt,
- wskaźnik skuteczności normalizacji.

### 9. Geokodowanie

Zadania:

- przypisać współrzędne do przetworzonych adresów,
- wykorzystać dostępne źródła geokodowania,
- rozróżnić poziomy pewności:
  - punkt adresowy,
  - budynek,
  - ulica,
  - działka,
  - wynik niepewny.
- wybrać jeden najlepszy wynik dla mapy,
- zachować wyniki alternatywne do audytu,
- policzyć procent rekordów z poprawną lokalizacją.

Rezultat:

- współrzędne punktów,
- miara kompletności geokodowania,
- lista adresów nierozwiązanych.

### 10. Przypisanie do dzielnic i jednostek SIM

Zadania:

- pozyskać oficjalne poligony jednostek SIM,
- przypisać każdy punkt do jednostki SIM metodą point-in-polygon,
- przypisać jednostki SIM do dzielnic samorządowych,
- sprawdzić punkty poza granicami Krakowa,
- przygotować agregacje:
  - Kraków ogółem,
  - dzielnice,
  - jednostki SIM.

Rezultat:

- punkt z przypisaną dzielnicą i SIM,
- tabela agregacji przestrzennych,
- mapa kontrolna.

### 11. Definicje wskaźników

Podstawowe wskaźniki:

- liczba zezwoleń,
- liczba lokali/punktów po grupowaniu,
- liczba punktów detalicznych,
- liczba punktów gastronomicznych,
- liczba punktów mieszanych: gastronomia + detal,
- liczba zezwoleń kategorii A,
- liczba zezwoleń kategorii B,
- liczba zezwoleń kategorii C,
- udział zezwoleń C w ogóle,
- zmiana rok do roku,
- zmiana względem pierwszego dostępnego raportu.

Wskaźniki przestrzenne:

- liczba lokali na dzielnicę,
- liczba lokali na jednostkę SIM,
- udział gastronomii i detalu w jednostce SIM,
- koncentracja zezwoleń w centrum względem pozostałych obszarów,
- ranking obszarów.

Opcjonalnie po pozyskaniu danych demograficznych:

- lokale na 1000 mieszkańców,
- zezwolenia na 1000 mieszkańców,
- porównanie z gęstością zaludnienia.

### 12. Walidacja danych

Zadania:

- porównać liczby rekordów po imporcie z liczbami w źródłach,
- sprawdzić duplikaty,
- sprawdzić licencje bez adresu,
- sprawdzić licencje bez geokodowania,
- sprawdzić punkty poza Krakowem,
- ręcznie przejrzeć próbkę zgrupowanych nazw,
- ręcznie przejrzeć próbkę punktów o wielu licencjach,
- przygotować tabelę znanych ograniczeń.

Przykładowe kontrole:

- suma zezwoleń według kategorii = suma wszystkich zezwoleń,
- suma detal + gastronomia = suma zezwoleń według typu działalności,
- liczba punktów po grupowaniu <= liczba par adres/podmiot,
- punkty mieszane mają co najmniej jeden rekord detal i jeden gastronomia.

### 13. Analiza statystyczna

Zadania:

- policzyć statystyki opisowe dla całego Krakowa,
- policzyć szeregi czasowe liczby zezwoleń,
- policzyć szeregi czasowe liczby lokali po grupowaniu,
- porównać detal i gastronomię,
- porównać kategorie A/B/C,
- przygotować rankingi dzielnic i SIM,
- zbadać największe wzrosty i spadki,
- opisać outliery i potencjalne błędy danych.

Wykresy:

- liczba zezwoleń w czasie,
- liczba lokali w czasie,
- detal vs gastronomia w czasie,
- kategorie A/B/C w czasie,
- mapa choropletyczna po dzielnicach,
- mapa choropletyczna po SIM,
- ranking top 20 jednostek SIM,
- rozkład liczby zezwoleń na lokal.

### 14. Analiza przestrzenna

Zadania:

- opisać koncentrację punktów w centrum,
- porównać Kazimierz, Stare Miasto, Kleparz i inne jednostki SIM,
- sprawdzić obszary o dużym udziale gastronomii,
- sprawdzić obszary o dużym udziale detalu,
- pokazać punkty mieszane,
- pokazać zmiany przestrzenne w czasie.

Możliwe metody:

- agregacja do jednostek SIM,
- gęstość punktów,
- heatmapa,
- porównanie udziałów,
- ranking zmian między raportami.

### 15. Ograniczenia badania

Do opisania w pracy:

- jakość danych źródłowych,
- zmienność formatów publikacji,
- błędy OCR i ekstrakcji PDF,
- niespójności nazw podmiotów,
- możliwość błędnego grupowania podobnych nazw,
- możliwość niepołączenia tego samego lokalu przy zbyt różnych nazwach,
- niepewność geokodowania,
- adres formalny nie zawsze musi oznaczać dokładne miejsce faktycznej sprzedaży,
- zmiany administracyjne i publikacyjne w czasie.

### 16. Reprodukowalność

Zadania:

- opisać środowisko techniczne,
- opisać wersje bibliotek,
- zapisać wszystkie skrypty importu i transformacji,
- nie modyfikować surowych danych,
- używać katalogów:
  - `raw`,
  - `extracted`,
  - `processed`,
  - `exports`,
  - `reports`.
- przygotować komendy:
  - pobranie danych,
  - ekstrakcja,
  - import,
  - geokodowanie,
  - grupowanie punktów,
  - eksport statystyk.

Minimalna ścieżka odtworzenia:

```bash
bin/rails research:import_sources
bin/rails research:normalize_locations
bin/rails research:geocode_open
bin/rails license_point_groups:rebuild ALL=1
bin/rails dataset:release
```

### 17. Struktura pracy

Proponowane rozdziały:

1. Wstęp
   - motywacja,
   - znaczenie danych publicznych,
   - pytania badawcze.

2. Źródła danych
   - BIP,
   - dane historyczne z urzędu,
   - formaty plików,
   - zakres czasowy.

3. Metody pozyskania i ekstrakcji
   - pobieranie danych,
   - ekstrakcja z PDF,
   - import Exceli,
   - problemy techniczne.

4. Czyszczenie i normalizacja
   - normalizacja nazw,
   - normalizacja adresów,
   - geokodowanie,
   - grupowanie lokali.

5. Model przestrzenny
   - jednostki SIM,
   - dzielnice,
   - przypisanie punktów do obszarów.

6. Wyniki
   - statystyki ogólne,
   - trendy w czasie,
   - różnice detal/gastronomia,
   - kategorie A/B/C,
   - analiza dzielnic i SIM.

7. Dyskusja
   - interpretacja wyników,
   - ograniczenia danych,
   - wpływ metod czyszczenia na wyniki.

8. Podsumowanie
   - najważniejsze wnioski,
   - możliwe rozwinięcia,
   - rekomendacje dla publikacji danych publicznych.

### 18. Produkty końcowe

1. Oczyszczona baza danych.
2. Dokumentacja pipeline'u.
3. Słownik normalizacji nazw.
4. Słownik korekt adresów.
5. Eksport statystyk.
6. Mapy i wykresy.
7. Interaktywna mapa.
8. Tekst pracy naukowej.
9. Repozytorium z kodem i instrukcją odtworzenia.

### 19. Najbliższe zadania

1. Spisać pełną listę źródeł danych i dat raportów.
2. Opisać aktualny pipeline importu z repozytorium.
3. Oddzielić surowe dane od danych przetworzonych.
4. Udokumentować ekstrakcję PDF.
5. Udokumentować normalizację adresów.
6. Udokumentować normalizację nazw i próg 90%.
7. Wyeksportować pierwsze statystyki ogólne dla całego Krakowa.
8. Wyeksportować statystyki dla dzielnic i jednostek SIM.
9. Przygotować listę przykładów błędów danych oraz ręcznych korekt.
10. Zacząć rozdział metodologiczny.

## Notatki metodologiczne

W pracy trzeba konsekwentnie odróżniać dane administracyjne od interpretacji przestrzennej. Zezwolenie jest rekordem urzędowym, a lokal na mapie jest konstrukcją analityczną powstałą po normalizacji adresu, geokodowaniu i grupowaniu podobnych nazw w tym samym miejscu.

Każda decyzja transformacyjna powinna być opisana jako reguła, a nie jako ręczna poprawka bez uzasadnienia. Szczególnie ważne są:

- reguły łączenia nazw,
- próg podobieństwa,
- lista słów pomijanych,
- sposób traktowania błędów literowych,
- sposób wybierania współrzędnych,
- obsługa punktów mieszanych detal/gastronomia.
