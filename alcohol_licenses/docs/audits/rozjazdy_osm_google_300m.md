# Rozjazdy Google/OSM > 300 m - najnowszy raport

Porównanie `lat/lng` (wybrana geolokacja mapy) z `osm_lat/osm_lng` (OSM/Nominatim).

## Podsumowanie

- OSM słaby fallback; Google raczej OK: 27
- działka/bulwar; sprawdzić ewidencję vs Google/OSM: 12
- OSM trafił w miejscowość/POI; Google raczej OK: 11
- średni konflikt; sprawdzić po adresie: 10
- konflikt Google rooftop vs OSM budynek; sprawdzić ręcznie: 3
- bardzo duży konflikt; sprawdzić ręcznie: 2
- Google interpolowany; sprawdzić ręcznie: 2

## Pełna lista

| # | m | adres | firma | główne źródło | OSM | ocena |
|---:|---:|---|---|---|---|---|
| 1 | 10425.2 | Komandosów 1 | POZNAŃSKA - CHLEBDA KAZIMIERA | google/ROOFTOP/premise\|street_address | address_point/retail/building | konflikt Google rooftop vs OSM budynek; sprawdzić ręcznie |
| 2 | 9019.9 | Tyniecka 47 | SITEK ŁUKASZ, SITEK MARCIN | google/ROOFTOP/premise\|street_address | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 3 | 8469.8 | Lipowa 6C | BAŃDO ANDRZEJ, GAWRYLUK JACEK, EDRIES TIMUR | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 4 | 7202.0 | Stróża Rybna 16D | GUT BOGUSŁAW | google/ROOFTOP/premise\|street_address | address_point/residential/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 5 | 4867.5 | Bulwar Kurlandzki dz. 137/7 obr. 12 | KAPUSTA KRYSTIAN | google/ROOFTOP/street_address\|subpremise | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 6 | 4867.5 | Bulwar Kurlandzki dz.137/7 obr.12 | OWTO SPÓŁKA Z O.O. | google/ROOFTOP/street_address\|subpremise | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 7 | 4172.2 | Józefa Dietla 58 | SH&H SPÓŁKA Z O.O. SPÓLKA KOMANDYTOWA | google/ROOFTOP/street_address\|subpremise | address_point/hostel/tourism | bardzo duży konflikt; sprawdzić ręcznie |
| 8 | 2940.2 | Aleja Pokoju dz. nr 113/12 | BUGAJSKA MAGDALENA | manual_street_audit/derived/parcel/S-17 | street_fallback/secondary/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 9 | 2596.9 | Skotnicka 268 | BIER SEBASTIAN | google/ROOFTOP/street_address\|subpremise | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 10 | 2507.1 | Balicka 18D | PIETRUSA PATRYCJA | google/ROOFTOP/street_address\|subpremise | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 11 | 2219.0 | Bieżanowska 78G | CZURŁOWSKI RYSZARD | google/ROOFTOP/street_address\|subpremise | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 12 | 2045.3 | Wiślna 5 | KOLBA GROUP SPÓŁKA Z O.O. | google/ROOFTOP/premise\|street_address | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 13 | 2045.3 | Wiślna 5 | KOWALSKA ALEKSANDRA | google/ROOFTOP/premise\|street_address | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 14 | 2045.3 | Wiślna 5 | WWS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ | google/ROOFTOP/premise\|street_address | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 15 | 1956.2 | Wiślna 11 | GRZEGORZ ROJEK | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 16 | 1956.2 | Wiślna 11 | SIERANT LESZEK | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 17 | 1911.0 | Półłanki 80A | PIBER ELŻBIETA | google/ROOFTOP/street_address\|subpremise | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 18 | 1325.1 | Półłanki dz.123/11 | FOOD FACTORY SPÓŁKA Z O.O. | manual_geo_completion/derived/street | street_fallback/residential/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 19 | 1195.5 | Mogilska 21L | ZACHARIASZ SYLWIA | google/ROOFTOP/street_address\|subpremise | address_point/secondary/road | OSM słaby fallback; Google raczej OK |
| 20 | 1168.4 | Sołtysowska 1 | POPIOŁEK MATEUSZ | google/ROOFTOP/street_address\|subpremise | address_point/car_parts/shop | bardzo duży konflikt; sprawdzić ręcznie |
| 21 | 1140.9 | płk. Stanisława Dąbka 30 | PRO-CAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ | google/ROOFTOP/premise\|street_address | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 22 | 1093.3 | Kolna dz. 370 obr. 2 | STĘPNIEWSKI PAWEŁ | uldk/parcel/P-2 | street_fallback/residential/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 23 | 1003.3 | Księcia Józefa 24A | KOLEJOWY KLUB WODNY 1929 SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ | google/ROOFTOP/street_address\|subpremise | address_point/secondary/road | OSM słaby fallback; Google raczej OK |
| 24 | 994.1 | dr. Józefa Babińskiego 2 | NGUYEN SY NGOC | google/ROOFTOP/establishment\|health\|hospital\|point_of_interest | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 25 | 938.0 | Nadbrzezie 1A | RZEPKA MARTA, RZEPKA SŁAWOMIR | google/ROOFTOP/premise\|street_address | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 26 | 878.4 | Stefana Grota-Roweckiego działka 40/15 obr. 34 | SZWED TOMASZ | uldk/parcel/P-34 | street_fallback/secondary/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 27 | 857.1 | Bulwar Czerwieński dz. nr 172 | KRAKOWSKA GRUPA AMNIS SPÓŁKA Z O.O. | manual_street_audit/derived/parcel/S-145 | cadastral_parcel/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 28 | 838.7 | Osiedle Kolorowe 16A | JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA | google/ROOFTOP/street_address\|subpremise | address_point/retail/building | konflikt Google rooftop vs OSM budynek; sprawdzić ręcznie |
| 29 | 816.5 | Orla 62 | HANDLOWA SPÓŁDZIELNIA JUBILAT | google/ROOFTOP/premise\|street_address | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 30 | 808.4 | Aleja Jerzego Waszyngtona 1 | KUSEK DARIUSZ | google/ROOFTOP/premise\|street_address | address_point/place_of_worship/amenity | średni konflikt; sprawdzić po adresie |
| 31 | 808.4 | Aleja Jerzego Waszyngtona 1 | MIKURDA BARBARA, CHECHELSKI ADAM | google/ROOFTOP/premise\|street_address | address_point/place_of_worship/amenity | średni konflikt; sprawdzić po adresie |
| 32 | 634.7 | Kapelanka 43 | FRYTKI BELGIJSKIE W KRAKOWIE, ŁUKASZ WILK I MATEUSZ SZPAK SPÓŁKA JAWNA | google/ROOFTOP/premise\|street_address | address_point/secondary/road | OSM słaby fallback; Google raczej OK |
| 33 | 620.0 | Kobierzyńska 112B | SZWED TOMASZ | google/ROOFTOP/premise\|street_address | address_point/tertiary/road | OSM słaby fallback; Google raczej OK |
| 34 | 605.1 | dr. Józefa Babińskiego 74A | PIWOWARCZYK ANNA | google/ROOFTOP/establishment\|health\|hospital\|point_of_interest | address_point/convenience/shop | średni konflikt; sprawdzić po adresie |
| 35 | 559.4 | Bohdana Zaleskiego 1 | KASPERCZYK MARCIN | google/ROOFTOP/street_address\|subpremise | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 36 | 555.9 | Białoruska 7K | MEJER TADEUSZ | google/ROOFTOP/premise\|street_address | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 37 | 543.4 | Osiedle Dywizjonu 303 55A | MUSIAŁ ADAM | google/ROOFTOP/premise\|street_address | address_point/neighbourhood/neighbourhood | OSM słaby fallback; Google raczej OK |
| 38 | 533.8 | Białoruska MINI CENTRUM PAWILON NR 10 | PAWLIK PIOTR | google/ROOFTOP/premise\|street_address | street_fallback/residential/road | OSM słaby fallback; Google raczej OK |
| 39 | 520.5 | Pawia 5P | KAMIŃSKA BARBARA, KAMIŃSKI MARIUSZ | google/GEOMETRIC_CENTER/premise\|street_address | address_point/tertiary/road | średni konflikt; sprawdzić po adresie |
| 40 | 520.5 | Pawia 5P | RAI ADAM | google/GEOMETRIC_CENTER/premise\|street_address | address_point/tertiary/road | średni konflikt; sprawdzić po adresie |
| 41 | 520.5 | Pawia 5P | ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z OGRANICZONĄ | google/GEOMETRIC_CENTER/premise\|street_address | address_point/tertiary/road | średni konflikt; sprawdzić po adresie |
| 42 | 514.5 | Bulwar Czerwieński dz. nr 81/5 | KRAKOWSKA GRUPA AMNIS SPÓŁKA Z O.O. | manual_street_audit/derived/parcel/S-146 | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 43 | 514.5 | Bulwar Czerwieński dz. 81/5 | KRAKÓW FOR YOU SPÓŁKA Z O.O. | manual_street_audit/derived/parcel/S-146 | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 44 | 514.5 | Bulwar Czerwieński dz. nr 81/5 obr. 146 | STER EWA BIGOSZ - LASSOTA I PIOTR WIŚNIEWSKI SPÓŁKA JAWNA | uldk/parcel/S-146 | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 45 | 514.5 | Bulwar Czerwieński dz. 81/5 obr. 146 i | SZEWCZYK EDYTA | uldk/parcel/S-146 | street_fallback/path/road | działka/bulwar; sprawdzić ewidencję vs Google/OSM |
| 46 | 505.5 | Zdrowa 1 | GĘBKA WIOLETA | google/ROOFTOP/street_address\|subpremise | address_point/place_of_worship/amenity | średni konflikt; sprawdzić po adresie |
| 47 | 504.6 | Władysława Jagiełły 31A | AD - SYSTEM SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ | google/ROOFTOP/street_address\|subpremise | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 48 | 504.0 | Juliusza Lea 26 | SWAJDO PAWEŁ | google/ROOFTOP/street_address\|subpremise | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 49 | 500.7 | Kruszwicka 22C | SKOWRON DOROTA | google/ROOFTOP/street_address\|subpremise | address_point/unclassified/road | OSM słaby fallback; Google raczej OK |
| 50 | 470.4 | Plac Dominikański 5 | FORTE DE LEO SPÓŁKA Z O.O. | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 51 | 459.5 | Wadowicka 3 | GRYGNY SYLWIA | google/ROOFTOP/street_address\|subpremise | address_point/bakery/shop | średni konflikt; sprawdzić po adresie |
| 52 | 449.0 | Blokowa 1 | DONIEC ZBIGNIEW | google/RANGE_INTERPOLATED/street_address | address_point/tertiary/road | Google interpolowany; sprawdzić ręcznie |
| 53 | 396.2 | Osiedle Kolorowe 9F | ORLEN SPÓŁKA AKCYJNA | google/ROOFTOP/premise\|street_address | address_point/neighbourhood/neighbourhood | OSM słaby fallback; Google raczej OK |
| 54 | 394.4 | Kruszwicka 12J | GĄSIOREK TOMASZ, GĄSIOREK BEATA | google/ROOFTOP/street_address\|subpremise | address_point/unclassified/road | OSM słaby fallback; Google raczej OK |
| 55 | 380.6 | Karola Bunscha 2 | BACÓWKA TOWARY TRADYCYJNE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ | google/ROOFTOP/street_address\|subpremise | address_point/secondary/road | OSM słaby fallback; Google raczej OK |
| 56 | 354.4 | Zakopiańska 105 | KISIEL ANETA | google/ROOFTOP/street_address\|subpremise | address_point/mall/shop | średni konflikt; sprawdzić po adresie |
| 57 | 354.4 | Zakopiańska 105 | SLAB SPÓŁKA Z O.O. | google/ROOFTOP/street_address\|subpremise | address_point/mall/shop | średni konflikt; sprawdzić po adresie |
| 58 | 343.2 | Osiedle Dywizjonu 303 paw. 1 | WIELECKA ALICJA | google/ROOFTOP/premise\|street_address | street_fallback/neighbourhood/neighbourhood | OSM słaby fallback; Google raczej OK |
| 59 | 334.9 | Stanisława Klimeckiego 14B | CUBE WALLS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA | google/ROOFTOP/premise\|street_address | address_point/primary/road | OSM słaby fallback; Google raczej OK |
| 60 | 334.9 | Stanisława Klimeckiego 14B | PSK INVEST SPÓŁKA Z O.O. | google/ROOFTOP/premise\|street_address | address_point/primary/road | OSM słaby fallback; Google raczej OK |
| 61 | 330.7 | Tadeusza Śliwiaka 38 | JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 62 | 329.2 | Osiedle Złotego Wieku 23C | KĘKUŚ WOJCIECH | google/ROOFTOP/street_address\|subpremise | address_point/residential/neighbourhood | OSM słaby fallback; Google raczej OK |
| 63 | 328.2 | Rzemieślnicza 20H | KRZANIK URSZULA, KRZANIK JAKUB | google/ROOFTOP/premise\|street_address | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 64 | 314.7 | Starowiślna 32 | ABRAMCZYK ADAM, ABRAMCZYK WIOLETTA | google/ROOFTOP/street_address\|subpremise | address_point/house/place | OSM trafił w miejscowość/POI; Google raczej OK |
| 65 | 312.6 | Aleja 3 Maja 9 | PARK KLUB RESTAURACJA SPÓŁKA Z O.O. SPÓŁKA KOMANDYTOWA | google/ROOFTOP/premise\|street_address | address_point/office/building | konflikt Google rooftop vs OSM budynek; sprawdzić ręcznie |
| 66 | 303.6 | Kawiory 8U | KUNICKI KAMIL | google/ROOFTOP/street_address\|subpremise | address_point/residential/road | OSM słaby fallback; Google raczej OK |
| 67 | 301.5 | Osiedle Dywizjonu 303 69 | PIĄTEK JAROSŁAW | google/RANGE_INTERPOLATED/street_address | address_point/neighbourhood/neighbourhood | Google interpolowany; sprawdzić ręcznie |
