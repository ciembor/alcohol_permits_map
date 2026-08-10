# Plan ręcznej kontroli geokodowania

## Cel

Celem narzędzia jest ręczna kontrola lokalizacji według przełączanych kategorii sygnałów jakości. Użytkownik powinien móc wybrać kategorię problemu, np. dużą rozbieżność Google-OSM, słabą precyzję Google, działki ewidencyjne albo pawilony, a następnie przeglądać tylko lokalizacje spełniające ten warunek. Narzędzie ma pokazywać lokalizację na mapie, umożliwiać przesunięcie pineski albo wybór jednego z kandydatów oraz zapisywać decyzję w bazie tak, aby przyszłe eksporty używały zweryfikowanych współrzędnych.

Jednostką kontroli powinna być `transformed_location`, a nie `license_point_group`. Współrzędne są zapisane na poziomie lokalizacji przekształconej i mogą być współdzielone przez wiele zezwoleń oraz wiele punktów sprzedaży. Interfejs może pokazywać punkty sprzedaży i licencje jako kontekst, ale decyzja o poprawieniu współrzędnych powinna dotyczyć lokalizacji. Jednocześnie zapis audytu powinien zachowywać informację, w ramach której kategorii sygnału jakości dana lokalizacja była sprawdzana.

## Stan dla najnowszego raportu

Dane policzone dla lokalnej bazy, raport `2026-02-06T08:43:09Z`:

- 8142 zezwoleń,
- 3000 lokalnych grup punktów sprzedaży,
- 2616 lokalizacji przekształconych,
- 2616 lokalizacji z wybranym wynikiem geokodowania,
- 27 lokalizacji oznaczonych jako niepewne przez obecny mechanizm `LocationUncertainty`,
- 2615 lokalizacji z możliwym porównaniem Google/OSM,
- 104 lokalizacje z odległością Google-OSM powyżej 100 m,
- 58 lokalizacji z odległością Google-OSM powyżej 250 m,
- 36 lokalizacji z odległością Google-OSM powyżej 500 m,
- 17 lokalizacji z odległością Google-OSM powyżej 1000 m,
- 1 lokalizacja bez referencyjnych współrzędnych OSM.

Wybrane źródła geokodowania w najnowszym raporcie:

- Google: 2498 lokalizacji,
- Nominatim: 104 lokalizacje,
- ULDK: 7 lokalizacji,
- manual_street_audit: 5 lokalizacji,
- manual_geo_completion: 2 lokalizacje.

Strategie geokodowania:

- `address_point`: 2585 lokalizacji,
- `cadastral_parcel`: 15 lokalizacji,
- `described_place`: 11 lokalizacji,
- `street_fallback`: 4 lokalizacje,
- `teryt_named_object`: 1 lokalizacja.

Typy adresów inne niż standardowy adres uliczny:

- `compound_address`: 21 lokalizacji,
- `parcel`: 19 lokalizacji,
- `pavilion`: 14 lokalizacji,
- `near_building`: 9 lokalizacji,
- `landmark`: 3 lokalizacje.

## Kategorie sygnałów jakości

Narzędzie nie powinno opierać się na jednej globalnej kolejce. Lepszy model to przełączanie między kategoriami sygnałów jakości. Każda kategoria ma własny filtr, licznik rekordów, sortowanie wewnętrzne i statystykę skuteczności po ręcznej kontroli. Dzięki temu można osobno powiedzieć, jaka część błędów wynikała np. z dużej rozbieżności Google-OSM, jaka z działek, a jaka ze słabej precyzji geokodowania.

### A. Braki krytyczne

Cel: znaleźć lokalizacje, których nie da się wiarygodnie użyć na mapie bez decyzji ręcznej.

Filtry:

- brak wybranego wyniku geokodowania,
- brak współrzędnych w `transformed_locations`,
- współrzędne poza granicami Krakowa,
- brak przypisania do jednostki SIM.

Sortowanie wewnątrz kategorii:

1. brak współrzędnych,
2. brak wybranego wyniku,
3. poza Krakowem,
4. brak SIM,
5. rosnąco po `transformed_location.id`.

### B. Rozbieżność Google-OSM

Cel: wykryć przypadki, w których dwa niezależne źródła wskazują różne miejsca.

Filtry:

- odległość Google-OSM powyżej 1000 m,
- odległość Google-OSM powyżej 500 m,
- odległość Google-OSM powyżej 250 m,
- odległość Google-OSM powyżej 100 m,
- odległość Google-OSM powyżej 50 m.

Sortowanie wewnątrz kategorii:

1. malejąco po odległości Google-OSM,
2. najpierw lokalizacje z `location_uncertain`,
3. najpierw adresy inne niż `street_address`,
4. najpierw obszary kluczowe dla pracy,
5. rosnąco po `transformed_location.id`.

Ten sygnał nie oznacza automatycznie błędu. Duża odległość może wynikać z błędu Google, błędu OSM, punktu opisowego, działki albo różnej interpretacji adresu. Jest jednak jednym z najlepszych sygnałów do ręcznego sprawdzenia.

### C. Niska precyzja wybranego wyniku

Cel: kontrolować lokalizacje, w których wybrane źródło nie wskazuje precyzyjnego punktu adresowego.

Filtry:

- Google `APPROXIMATE`,
- Google `GEOMETRIC_CENTER`,
- Google `RANGE_INTERPOLATED`,
- OSM kończący się na `road`,
- OSM kończący się na `neighbourhood`,
- OSM kończący się na `quarter`,
- OSM kończący się na `junction`,
- wynik `derived/*`,
- precyzja pusta albo nierozpoznana.

Sortowanie wewnątrz kategorii:

1. `APPROXIMATE`,
2. OSM `neighbourhood` / `quarter`,
3. OSM `road` / `junction`,
4. Google `GEOMETRIC_CENTER`,
5. Google `RANGE_INTERPOLATED`,
6. `derived/*`,
7. malejąco po odległości Google-OSM, jeżeli dostępna.

### D. Słaba lub przybliżona strategia geokodowania

Cel: sprawdzić przypadki, w których już sama strategia zapytania wskazuje, że nie mamy klasycznego punktu adresowego.

Filtry:

- `street_fallback`,
- `teryt_named_object`,
- `described_place`,
- `cadastral_parcel` bez potwierdzonej precyzji `parcel/*`,
- źródło inne niż Google dla zwykłego adresu budynkowego.

Sortowanie wewnątrz kategorii:

1. `street_fallback`,
2. `teryt_named_object`,
3. `cadastral_parcel` bez `parcel/*`,
4. `described_place`,
5. źródło inne niż Google dla `street_address`,
6. malejąco po odległości Google-OSM.

### E. Nietypowy typ adresu

Cel: kontrolować adresy, które z natury są trudniejsze niż zwykła ulica i numer budynku.

Filtry:

- `address_kind = parcel`,
- `address_kind = pavilion`,
- `address_kind = landmark`,
- `address_kind = near_building`,
- `address_kind = compound_address`.

Sortowanie wewnątrz kategorii:

1. `parcel`,
2. `landmark`,
3. `pavilion`,
4. `near_building`,
5. `compound_address`,
6. najpierw lokalizacje z niską precyzją wyniku,
7. malejąco po odległości Google-OSM.

### F. Korekty i transformacja adresu

Cel: sprawdzić miejsca, gdzie poprawność zależy od wcześniejszej decyzji interpretacyjnej albo agresywniejszej normalizacji.

Filtry:

- lokalizacja ma wybraną korektę w `address_corrections`,
- korekta pochodzi z inferencji historycznej,
- korekta pochodzi z ręcznego audytu ulic,
- wiele źródłowych wariantów adresu prowadzi do jednej `transformed_location`,
- adres źródłowy miał pusty lub bardzo krótki `address_2`,
- numer budynku został wydobyty z `address_1`, a nie z `address_2`.

Sortowanie wewnątrz kategorii:

1. korekty z inferencji historycznej,
2. korekty ręczne,
3. najwięcej wariantów adresu źródłowego,
4. adresy bez pierwotnego numeru budynku,
5. malejąco po liczbie powiązanych zezwoleń.

### G. Sygnały grupowania punktów sprzedaży

Cel: sprawdzić nie tyle położenie adresu, ile wpływ geokodowania i normalizacji nazw na liczbę punktów sprzedaży.

Filtry:

- wiele grup punktów sprzedaży pod tymi samymi współrzędnymi,
- punkt obejmuje więcej niż jeden `business_id`,
- `business_similarity_floor < 1`,
- bardzo duża liczba zezwoleń w jednym punkcie,
- punkt mieszany, czyli detal i gastronomia w tej samej grupie,
- ten sam adres i bardzo podobne firmy tworzą kilka punktów,
- ten sam podmiot ma kilka punktów w tym samym budynku.

Sortowanie wewnątrz kategorii:

1. `business_similarity_floor < 1`,
2. wiele `business_id` w punkcie,
3. wiele punktów pod jednymi współrzędnymi,
4. największa liczba zezwoleń,
5. punkty mieszane detal/gastronomia,
6. obszary kluczowe dla pracy.

Ta kategoria powinna mieć osobny tryb widoku: zamiast jednej pineski trzeba pokazać wszystkie punkty/grupy pod tym samym adresem lub współrzędnymi oraz ich nazwy przedsiębiorców.

### H. Obszary kluczowe dla pracy

Cel: umożliwić kontrolę lokalizacji w miejscach, które mają największe znaczenie dla argumentu pracy, nawet jeżeli ich sygnały techniczne nie są najgorsze.

Filtry:

- Kazimierz,
- Stare Miasto,
- Stare Podgórze,
- Piasek,
- Kleparz,
- granice jednostek SIM,
- punkty w pobliżu granic parku kulturowego albo innych obszarów analitycznych, jeżeli zostaną dodane.

Sortowanie wewnątrz kategorii:

1. najpierw lokalizacje mające także inne sygnały jakości,
2. malejąco po liczbie zezwoleń,
3. punkty mieszane detal/gastronomia,
4. rosnąco po odległości od granicy wybranego obszaru, jeżeli celem jest kontrola przypisania do obszaru.

### I. Próba losowa

Cel: oszacować jakość całego zbioru, a nie tylko miejsc podejrzanych.

Filtry:

- losowa próba ze wszystkich lokalizacji,
- losowa próba z lokalizacji bez żadnego sygnału jakości,
- losowa próba warstwowa według typu adresu,
- losowa próba warstwowa według dzielnicy lub jednostki SIM,
- losowa próba warstwowa według roku raportu.

Sortowanie:

- losowe, z zapisanym ziarnem losowania albo identyfikatorem partii audytu.

Ta kategoria jest konieczna metodologicznie. Bez niej będziemy wiedzieć, ile błędów znaleźliśmy w przypadkach podejrzanych, ale nie będziemy umieli oszacować jakości całego datasetu.

## Widok kategorii w interfejsie

Interfejs powinien mieć przełącznik kategorii sygnałów jakości, a nie jedną listę globalną. Dla każdej kategorii powinien pokazywać:

- liczbę wszystkich lokalizacji spełniających warunek,
- liczbę zweryfikowanych,
- liczbę poprawionych,
- liczbę nierozstrzygniętych,
- procent błędów wśród sprawdzonych,
- medianę i percentyle odległości Google-OSM, jeżeli kategoria tego dotyczy,
- możliwość ukrycia lokalizacji już zweryfikowanych,
- możliwość ograniczenia do najnowszego raportu albo pokazania wszystkich raportów,
- możliwość filtrowania po SIM/dzielnicy.

Dobrze jest dodatkowo pokazywać etykiety wszystkich kategorii, do których należy dana lokalizacja. Przykładowo jedna lokalizacja może jednocześnie należeć do kategorii `Rozbieżność Google-OSM > 500 m`, `parcel`, `derived/*` i `Kazimierz`.

## Sortowanie wewnątrz kategorii

Każda kategoria ma własne sortowanie, bo inny jest sens danego sygnału. Narzędzie może nadal liczyć pomocniczy `risk_score`, ale nie powinien on zastępować kategorii. `risk_score` może służyć tylko jako drugorzędny porządek wewnątrz aktywnego widoku albo jako etykieta pomocnicza, gdy lokalizacja należy do wielu kategorii naraz.

Domyślne tie-breakery:

1. najpierw lokalizacje niezweryfikowane,
2. najpierw lokalizacje z większą liczbą powiązanych zezwoleń,
3. najpierw lokalizacje z większą liczbą powiązanych punktów sprzedaży,
4. najpierw obszary kluczowe dla pracy,
5. rosnąco po `transformed_location.id`.

## Checklista ręcznej kontroli

Dla każdej lokalizacji recenzent powinien sprawdzić:

- czy adres źródłowy i adres znormalizowany opisują to samo miejsce,
- czy numer budynku, lokalu, pawilonu lub działki został dobrze odczytany,
- czy obecna pineska wskazuje właściwy budynek, działkę, pawilon albo obszar opisowy,
- czy wynik Google i wynik OSM wskazują podobne miejsce,
- jeżeli Google i OSM się różnią, który wynik lepiej odpowiada adresowi źródłowemu,
- czy punkt nie został przeniesiony na środek ulicy, placu, dzielnicy lub obiektu ogólnego,
- czy współrzędne znajdują się po właściwej stronie ulicy lub we właściwym kwartale,
- czy przypisanie do jednostki SIM jest zgodne z położeniem punktu,
- czy wiele źródłowych wariantów adresu faktycznie powinno prowadzić do tej samej lokalizacji,
- czy punkt jest na tyle niejednoznaczny, że powinien zostać oznaczony jako zweryfikowany, ale nadal przybliżony.

## Zachowanie narzędzia na mapie

Widok powinien pokazywać jedną lokalizację z aktywnej kategorii:

- aktualną pineskę wynikową,
- pineskę Google, jeżeli istnieje,
- pineskę OSM, jeżeli istnieje,
- ewentualne pineski ULDK/manual, jeżeli istnieją,
- adres źródłowy i adres znormalizowany,
- typ adresu, strategię, źródło, precyzję, powody niepewności i aktywne etykiety jakości,
- licencje i punkty sprzedaży powiązane z lokalizacją,
- jednostkę SIM dla aktualnych współrzędnych,
- odległość Google-OSM.

Interakcje:

- przeciągnięcie pineski ustawia proponowane ręczne współrzędne,
- kliknięcie istniejącej pineski kandydata wybiera jej współrzędne,
- przycisk `Wybierz` powinien przesuwać się razem z aktywną pineską i zapisywać decyzję,
- osobny przycisk `Zatwierdź bez zmiany` oznacza lokalizację jako sprawdzoną bez zmiany współrzędnych,
- osobny przycisk `Nie rozstrzygaj` zostawia lokalizację w aktywnym widoku kategorii z notatką,
- po zapisie narzędzie przechodzi do następnej lokalizacji w aktualnie wybranej kategorii.

## Zapis w bazie

Nie należy nadpisywać oryginalnych współrzędnych bez śladu. Najbezpieczniejszy model:

- dodać tabelę `geocoding_reviews`, która zapisuje fakt kontroli i decyzję,
- przy poprawie współrzędnych utworzyć nowy rekord w `geocoding_results` ze źródłem `manual_review`, strategią `manual_pin`, precyzją np. `manual/verified_point` albo `manual/approximate_place`,
- oznaczyć nowy rekord jako `selected = true`,
- odznaczyć wcześniejsze wyniki tej lokalizacji jako niewybrane,
- przepisać ręczne współrzędne do `transformed_locations.latitude` i `transformed_locations.longtitude`,
- zachować oryginalne współrzędne w rekordzie review,
- oznaczyć lokalizację jako zweryfikowaną także wtedy, gdy recenzent nie zmienił współrzędnych.

Status weryfikacji powinien być powiązany z lokalizacją i kategorią kontroli. Ta sama `transformed_location` może być poprawna w kategorii `Rozbieżność Google-OSM`, ale nadal wymagać sprawdzenia w kategorii `Sygnały grupowania`, bo tam pytanie dotyczy nie tylko współrzędnych, lecz także interpretacji punktu sprzedaży.

Proponowane pola `geocoding_reviews`:

- `transformed_location_id`,
- `review_status`: `verified`, `corrected`, `unresolved`,
- `reviewed_at`,
- `reviewed_by`,
- `original_latitude`,
- `original_longitude`,
- `manual_latitude`,
- `manual_longitude`,
- `selected_geocoding_result_id`,
- `manual_geocoding_result_id`,
- `signal_category`,
- `quality_signals`,
- `note`.

Manualny wynik powinien mieć najwyższy priorytet w wyborze geokodowania, aby późniejsze uruchomienie automatycznego geokodera nie nadpisało ręcznej decyzji.

## Pierwsze widoki do wdrożenia

Najpierw warto wdrożyć kategorie, które są najprostsze do policzenia i najbardziej prawdopodobne jako źródło błędów:

1. `location_uncertain`,
2. rozbieżność Google-OSM z progami 1000 m, 500 m, 250 m, 100 m i 50 m,
3. niska precyzja wybranego wyniku,
4. nietypowy typ adresu,
5. działki i pawilony,
6. korekty adresu,
7. sygnały grupowania,
8. próba losowa.

Po przejściu pierwszych partii należy raportować skuteczność osobno dla każdej kategorii: ile lokalizacji sprawdzono, ile poprawiono, ile zatwierdzono bez zmiany i ile zostało nierozstrzygniętych. Dopiero na tej podstawie można zdecydować, które sygnały są rzeczywiście najlepszym predyktorem błędu.
