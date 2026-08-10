# Audyt grupowania punktów sprzedaży

Raport: `2026-02-06 08:43:09`.

Zakres kontroli:
- wszystkie grupy, w których algorytm połączył więcej niż jeden `business_id`: 100,
- losowa, deterministyczna próba adresów wielopodmiotowych bez scalenia podmiotów: 50 z 204.

Legenda decyzji:
- `OK` - grupowanie wygląda poprawnie.
- `ZA DUŻO SCALONE` - algorytm połączył podmioty, które powinny być osobnymi punktami.
- `POWINNO BYĆ SCALONE` - algorytm zostawił osobno wpisy, które wyglądają na ten sam punkt/podmiot.
- `NIEPEWNE` - sam wykaz nie wystarcza do rozstrzygnięcia.

## A. Grupy scalające więcej niż jeden podmiot

### A001. Aleja 3 Maja 55

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053221`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA 3 MAJA 55`
- `business_id`: `3536`, `9226`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9226` WISTERIA SPÓŁKA Z O.O. SPÓŁKA KOMANDYTOWO-AKCYJNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ALEJA 3 MAJA 55`)
  - `3536` WISTERIA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWO-AKCYJNA (2 zez.; detal A, detal B; źródło: `ALEJA 3 MAJA 55`)

### A002. Aleja Kijowska 7 lok. 169

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054841`
- lokal po normalizacji: `169`
- zapisy źródłowe adresu/lokalu: `ALEJA KIJOWSKA 7 lok. 169`, `KIJOWSKA 7 lok. 169`
- `business_id`: `9195`, `9627`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9195` FAVO RETAIL GROUP SPÓŁKA Z O. O. (2 zez.; detal B, detal C; źródło: `KIJOWSKA 7 lok. 169`)
  - `9627` FAVO RETAIL GROUP SPÓŁKA Z O.O. (2 zez.; gastronomia B, gastronomia C; źródło: `ALEJA KIJOWSKA 7 lok. 169`)

### A003. Aleja Solidarności 11

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053275`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA SOLIDARNOŚCI 11`
- `business_id`: `38`, `701`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `701` SPOŁEM POWSZECHNA SPÓŁDZIELNIA SPOŻYWCÓW "NOWA HUTA" W KRAKOWIE (1 zez.; detal A; źródło: `ALEJA SOLIDARNOŚCI 11`)
  - `38` SPOŁEM POWSZECHNA SPÓŁDZIELNIA SPOŻYWCÓW NOWA HUTA W KRAKOWIE (2 zez.; detal B, detal C; źródło: `ALEJA SOLIDARNOŚCI 11`)

### A004. Aleja płk. Władysława Beliny-Prażmowskiego 49A

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053252`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA PŁK. WŁADYSŁAWA BELINY- PRAŻMOWSKIEGO 49 A`, `ALEJA PŁK. WŁADYSŁAWA BELINY- PRAŻMOWSKIEGO 49A`
- `business_id`: `387`, `9183`
- podobieństwo nazw: 0.154
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9183` PAWEŁ SAŁAPA, ROBERT TOCZEK (1 zez.; detal B; źródło: `ALEJA PŁK. WŁADYSŁAWA BELINY- PRAŻMOWSKIEGO 49 A`)
  - `387` TOCZEK ROBERT, SAŁAPA PAWEŁ (1 zez.; detal A; źródło: `ALEJA PŁK. WŁADYSŁAWA BELINY- PRAŻMOWSKIEGO 49A`)

### A005. Bartosza Głowackiego 16B

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053324`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BARTOSZA GŁOWACKIEGO 16B`
- `business_id`: `2998`, `3077`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `2998` DUDA PAWEL (2 zez.; detal B, detal C; źródło: `BARTOSZA GŁOWACKIEGO 16B`)
  - `3077` DUDA PAWEŁ (1 zez.; detal A; źródło: `BARTOSZA GŁOWACKIEGO 16B`)

### A006. Benedyktyńska 37

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053330`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BENEDYKTYŃSKA 37`
- `business_id`: `2999`, `7804`
- podobieństwo nazw: 0.983
- zezwolenia w grupie: 8

Podmioty w scalonej grupie:
  - `7804` "BENEDICITE" JEDNOSTKA GOSPODARCZA OPACTWA BENEDYKTYNÓW W TYŃCU (5 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `BENEDYKTYŃSKA 37`)
  - `2999` "BENEDICTE"JEDNOSTKA GOSPODARCZA OPACTWA BENEDYKTYNÓW W TYŃCU (3 zez.; detal A, detal B, detal C; źródło: `BENEDYKTYŃSKA 37`)

### A007. Bernarda Wapowskiego 8

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053333`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BERNARDA WAPOWSKIEGO 8`
- `business_id`: `8870`, `9248`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9248` WINNICA & WINO SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `BERNARDA WAPOWSKIEGO 8`)
  - `8870` WINNICA&WINO SPÓŁKA Z O.O. (3 zez.; detal A, detal B, detal C; źródło: `BERNARDA WAPOWSKIEGO 8`)

### A008. Czysta 8 lok. 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054807`
- lokal po normalizacji: `2`
- zapisy źródłowe adresu/lokalu: `CZYSTA 8/LU2`
- `business_id`: `9187`, `9276`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9187` RAW NEST SP. Z O.O. (1 zez.; detal B; źródło: `CZYSTA 8/LU2`)
  - `9276` RAW NEST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ, SPÓŁKA KOMANDYTOWA (2 zez.; gastronomia A, gastronomia B; źródło: `CZYSTA 8/LU2`)

### A009. Dajwór 20 lok. 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054809`
- lokal po normalizacji: `6`
- zapisy źródłowe adresu/lokalu: `DAJWÓR 20 LU 6`
- `business_id`: `2652`, `8326`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `2652` WINIARNIA SPÓŁKA Z O.O. (2 zez.; gastronomia B, gastronomia C; źródło: `DAJWÓR 20 LU 6`)
  - `8326` WINIARNIA SPÓŁKA Z OGRANICZNĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `DAJWÓR 20 LU 6`)

### A010. Fabryczna 13

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053513`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FABRYCZNA 13`
- `business_id`: `8091`, `8456`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `8456` F. R. B. INTER-BUD SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FABRYCZNA 13`)
  - `8091` F.R.B.INTER - BUD SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMADYTOWA (3 zez.; detal A, detal B, detal C; źródło: `FABRYCZNA 13`)

### A011. Fabryczna 13

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053515`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FABRYCZNA 13`, `FABRYCZNA 13 seg. Z 2`
- `business_id`: `8454`, `9644`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9644` WEGE FABRYCZNA SPÓŁKA Z O.O. (1 zez.; gastronomia C; źródło: `FABRYCZNA 13 seg. Z 2`)
  - `8454` WEGE FABRYCZNA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `FABRYCZNA 13`)

### A012. Floriańska 20

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054816`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 20`
- `business_id`: `1676`, `5645`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `5645` STAROPOLSKIE TRUNKI REGIONALNE SPÓŁKA Z O. O. (2 zez.; detal B, detal C; źródło: `FLORIAŃSKA 20`)
  - `1676` STAROPOLSKIE TRUNKI REGIONALNE SPÓŁKA Z O.O. (2 zez.; gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 20`)

### A013. Floriańska 9

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053527`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 9`
- `business_id`: `6425`, `8460`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `6425` REST - KRAK GASTROX SPÓŁKA Z O. O. SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `FLORIAŃSKA 9`)
  - `8460` REST - KRAK GASTROX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 9`)

### A014. Gołębia 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054821`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GOŁĘBIA 2`
- `business_id`: `3608`, `3699`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `3699` MAJEWSKA - SKROBICH LEOKADIA (2 zez.; detal B, detal C; źródło: `GOŁĘBIA 2`)
  - `3608` MAJEWSKA-SKROBICH LEOKADIA (1 zez.; gastronomia C; źródło: `GOŁĘBIA 2`)

### A015. Grodzka 10

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054823`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRODZKA 10`
- `business_id`: `3740`, `9190`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9190` CERASUS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓLKA KOMANDYTOWA (1 zez.; detal B; źródło: `GRODZKA 10`)
  - `3740` CERASUS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (1 zez.; gastronomia B; źródło: `GRODZKA 10`)

### A016. Grodzka 46

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053604`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRODZKA 46`
- `business_id`: `8108`, `8927`
- podobieństwo nazw: 0.231
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `8927` KAROLINA PACH (1 zez.; detal A; źródło: `GRODZKA 46`)
  - `8108` PACH KAROLINA (1 zez.; detal A; źródło: `GRODZKA 46`)

### A017. Grodzka 48

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053605`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRODZKA 48`
- `business_id`: `3252`, `3340`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3252` PIZZATOPIA SPÓLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal B; źródło: `GRODZKA 48`)
  - `3340` PIZZATOPIA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `GRODZKA 48`)

### A018. Grodzka 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053597`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRODZKA 6`
- `business_id`: `8105`, `8460`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `8460` REST - KRAK GASTROX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `GRODZKA 6`)
  - `8105` REST-KRAK GASTROX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `GRODZKA 6`)

### A019. Heleny 18

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053622`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `HELENY 18`
- `business_id`: `1489`, `2802`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `2802` JERONIMO MARTINS POLSKA SPÓLKA AKCYJNA (1 zez.; detal A; źródło: `HELENY 18`)
  - `1489` JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA (2 zez.; detal B, detal C; źródło: `HELENY 18`)

### A020. Henryka Kamieńskiego 11

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053559`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GEN. HENRYKA KAMIEŃSKIEGO 11`, `HENRYKA KAMIEŃSKIEGO 11`
- `business_id`: `3135`, `7575`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `3135` "AMREST" SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; gastronomia A; źródło: `HENRYKA KAMIEŃSKIEGO 11`)
  - `7575` AMREST SPÓLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `GEN. HENRYKA KAMIEŃSKIEGO 11`)

### A021. Isep 9

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053648`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ISEP 9`
- `business_id`: `1482`, `8113`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `1482` LOBO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal C; źródło: `ISEP 9`)
  - `8113` LOBO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILNOŚCIĄ (2 zez.; detal A, detal B; źródło: `ISEP 9`)

### A022. Jakuba 19

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055262`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JAKUBA 19`
- `business_id`: `3374`, `8503`
- podobieństwo nazw: 0.400
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `8503` WOŁKOUN MARCIN, ZGÓRKIEWICZ KRZYSZTOF, KURBIEL RAFAŁ (2 zez.; gastronomia A, gastronomia B; źródło: `JAKUBA 19`)
  - `3374` ZGÓRKIEWICZ KRZYSZTOF, WOŁKOUN MARCIN, KURBIEL RAFAŁ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JAKUBA 19`)

### A023. Jana Zamoyskiego 24

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054826`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JANA ZAMOYSKIEGO 24`
- `business_id`: `3704`, `8334`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `8334` WINE GARAGE SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (1 zez.; detal B; źródło: `JANA ZAMOYSKIEGO 24`)
  - `3704` WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JANA ZAMOYSKIEGO 24`)

### A024. Josepha Conrada 79

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053683`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JOSEPHA CONRADA 79`
- `business_id`: `8117`, `8335`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `8335` VININOVA SPÓLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal B, detal C; źródło: `JOSEPHA CONRADA 79`)
  - `8117` VININOVA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `JOSEPHA CONRADA 79`)

### A025. Jutrzenka 36

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053739`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JUTRZENKA 36`
- `business_id`: `8960`, `9361`
- podobieństwo nazw: 0.568
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `8960` ARKADIUSZ BIERNACIK, PAWIŃSKI WALDEMAR (1 zez.; detal A; źródło: `JUTRZENKA 36`)
  - `9361` BIERNACIK ARKADIUSZ, PAWIŃSKI WALDEMAR (1 zez.; gastronomia A; źródło: `JUTRZENKA 36`)

### A026. Józefa Dietla 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053692`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JÓZEFA DIETLA 1`
- `business_id`: `3263`, `7380`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3263` T.E.A. TIME SPÓŁKA Z O. O. (1 zez.; detal A; źródło: `JÓZEFA DIETLA 1`)
  - `7380` T.E.A. TIME SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA DIETLA 1`)

### A027. Józefa Dietla 33

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054831`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JÓZEFA DIETLA 33`
- `business_id`: `9192`, `9347`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9347` SMAKI GRUZJI SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA DIETLA 33`)
  - `9192` SMAKI GRUZJI SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `JÓZEFA DIETLA 33`)

### A028. Józefa Dietla 55 lok. 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053702`
- lokal po normalizacji: `1`
- zapisy źródłowe adresu/lokalu: `JÓZEFA DIETLA 55/1`, `JÓZEFA DIETLA 55/1 part`, `JÓZEFA DIETLA 55/1 piwni`
- `business_id`: `8949`, `8950`
- podobieństwo nazw: 0.917
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `8949` N&N NA JUNHYOUNG SPÓŁKA KOMANDYTOWA (4 zez.; detal A, detal B, gastronomia A, gastronomia B; źródło: `JÓZEFA DIETLA 55/1`, `JÓZEFA DIETLA 55/1 part`)
  - `8950` N&N NA JUNYOUNG SPÓŁKA KOMANDYTOWA (2 zez.; detal A, detal B; źródło: `JÓZEFA DIETLA 55/1 piwni`)

### A029. Józefa Dietla 85 lok. 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054832`
- lokal po normalizacji: `1`
- zapisy źródłowe adresu/lokalu: `JÓZEFA DIETLA 85 lok. 1`, `JÓZEFA DIETLA 85/1`
- `business_id`: `8523`, `9193`
- podobieństwo nazw: 0.167
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9193` KOTOWICZ BARTOSZ, WALCZEWSKI GRZEGORZ (1 zez.; detal B; źródło: `JÓZEFA DIETLA 85 lok. 1`)
  - `8523` WALCZEWSKI GRZEGORZ, KOTOWICZ BARTOSZ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA DIETLA 85/1`)

### A030. Kamienna 17

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055341`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KAMIENNA 17`
- `business_id`: `5454`, `8029`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `5454` POLPUB SPÓŁKA Z O.O. (2 zez.; gastronomia A, gastronomia B; źródło: `KAMIENNA 17`)
  - `8029` POLPUB SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; gastronomia C; źródło: `KAMIENNA 17`)

### A031. Kapelanka 30

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053756`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KAPELANKA 30`
- `business_id`: `549`, `1176`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `1176` KRAK-TAR SPÓŁKA Z O.O. (1 zez.; detal B; źródło: `KAPELANKA 30`)
  - `549` KRAK-TAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal C; źródło: `KAPELANKA 30`)

### A032. Karola Bunscha 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053773`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KAROLA BUNSCHA 2`
- `business_id`: `2848`, `2906`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `2848` BACÓWKA TOWARY TRADYCYJNE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `KAROLA BUNSCHA 2`)
  - `2906` BACÓWKA TOWARY TRADYCYJNE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (2 zez.; detal A, detal C; źródło: `KAROLA BUNSCHA 2`)

### A033. Kobierzyńska 174

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054844`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KOBIERZYŃSKA 174`
- `business_id`: `9196`, `9635`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9635` CK WINIARNIA SPÓŁKA Z O.O. (1 zez.; gastronomia B; źródło: `KOBIERZYŃSKA 174`)
  - `9196` CK WINIARNIA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `KOBIERZYŃSKA 174`)

### A034. Komandosów 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053821`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KOMANDOSÓW 1`
- `business_id`: `848`, `8977`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `848` POZNAŃSKA - CHLEBDA KAZIMIERA (3 zez.; detal A, detal B, detal C; źródło: `KOMANDOSÓW 1`)
  - `8977` POZNAŃSKA CHLEBDA KAZIMIERA (3 zez.; detal A, detal B, detal C; źródło: `KOMANDOSÓW 1`)

### A035. Kompozytorów 3 lok. 93

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054847`
- lokal po normalizacji: `93`
- zapisy źródłowe adresu/lokalu: `KOMPOZYTORÓW 3 lok 93`, `KOMPOZYTORÓW 3/93`
- `business_id`: `8341`, `8822`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `8822` VISION WINE SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ (1 zez.; gastronomia B; źródło: `KOMPOZYTORÓW 3/93`)
  - `8341` VISION WINE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `KOMPOZYTORÓW 3 lok 93`)

### A036. Kompozytorów 5 lok. 145

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054945`
- lokal po normalizacji: `145`
- zapisy źródłowe adresu/lokalu: `KOMPOZYTORÓW 5/ LU 145`, `KOMPOZYTORÓW 5/LU145`
- `business_id`: `9221`, `9380`
- podobieństwo nazw: 0.321
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9221` PAULINA PISKLAK, KAMIL MARCOL (1 zez.; detal C; źródło: `KOMPOZYTORÓW 5/LU145`)
  - `9380` PISKLAK PAULINA, MARCOL KAMIL (2 zez.; gastronomia A, gastronomia B; źródło: `KOMPOZYTORÓW 5/ LU 145`)

### A037. Krakowska 27

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053848`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRAKOWSKA 27`, `KRAKOWSKA 27/SKAŁECZNA 2`
- `business_id`: `8984`, `9386`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9386` NOLIO GOLAŃSKI, GOSTYLLA SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `KRAKOWSKA 27`)
  - `8984` NOLIO GOLAŃSKI,GOSTYLLA SPÓŁKA JAWNA (2 zez.; detal A, detal B; źródło: `KRAKOWSKA 27/SKAŁECZNA 2`)

### A038. Krakowska 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053841`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRAKOWSKA 6`
- `business_id`: `8982`, `9384`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9384` PG GROUP SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `KRAKOWSKA 6`)
  - `8982` PG GROUP SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `KRAKOWSKA 6`)

### A039. Krupnicza 9 lok. 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054859`
- lokal po normalizacji: `2`
- zapisy źródłowe adresu/lokalu: `KRUPNICZA 9/2`
- `business_id`: `9199`, `9637`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9637` SIMMART SPÓŁKA Z O.O. (2 zez.; gastronomia B, gastronomia C; źródło: `KRUPNICZA 9/2`)
  - `9199` SIMMART SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal B, detal C; źródło: `KRUPNICZA 9/2`)

### A040. Królowej Jadwigi 228

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054853`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRÓLOWEJ JADWIGI 228`
- `business_id`: `3709`, `8010`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `3709` AWITEKS SPÓLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (1 zez.; detal B; źródło: `KRÓLOWEJ JADWIGI 228`)
  - `8010` AWITEKS SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA SPÓŁKA KOMANDYTOWA (1 zez.; gastronomia B; źródło: `KRÓLOWEJ JADWIGI 228`)

### A041. Królowej Jadwigi 230A

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054855`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRÓLOWEJ JADWIGI 230A`
- `business_id`: `9198`, `9243`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9243` NAWITO SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `KRÓLOWEJ JADWIGI 230A`)
  - `9198` NAWITO SPÓŁKA Z OGRANICZONĄ (1 zez.; detal B; źródło: `KRÓLOWEJ JADWIGI 230A`)

### A042. Królowej Jadwigi 248

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053870`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRÓLOWEJ JADWIGI 248`
- `business_id`: `3626`, `9396`
- podobieństwo nazw: 0.360
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3626` CZEKAJ-GROCHOWSKA JUSTYNA (1 zez.; detal B; źródło: `KRÓLOWEJ JADWIGI 248`)
  - `9396` JUSTYNA CZEKAJ - GROCHOWSKA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `KRÓLOWEJ JADWIGI 248`)

### A043. Leonida Teligi 11

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053907`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `LEONIDA TELIGI 11`
- `business_id`: `2912`, `8999`
- podobieństwo nazw: 0.500
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `2912` CZAPIGA MARIUSZ, CZAPIGA ZBIGNIEW (2 zez.; detal B, detal C; źródło: `LEONIDA TELIGI 11`)
  - `8999` MARIUSZ CZAPIGA, ZBIGNIEW CZAPIGA (1 zez.; detal A; źródło: `LEONIDA TELIGI 11`)

### A044. Lipowa 6F

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053917`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `LIPOWA 6F`
- `business_id`: `3295`, `7638`
- podobieństwo nazw: 0.182
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `3295` JAROSZ JANUSZ, SIEWIOREK AGNIESZKA (3 zez.; detal A, detal B, detal C; źródło: `LIPOWA 6F`)
  - `7638` SIEWIOREK AGNIESZKA, JAROSZ JANUSZ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `LIPOWA 6F`)

### A045. Lubicz 17J

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053929`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `LUBICZ 17J`
- `business_id`: `9005`, `9408`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9408` BROWAR LUBICZ SPÓLKA Z O.O. SPÓLKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `LUBICZ 17J`)
  - `9005` BROWAR LUBICZ SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄSPÓŁKA KOMANDYTOWA (1 zez.; detal A; źródło: `LUBICZ 17J`)

### A046. Marii Konopnickiej 28

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055499`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MARII KONOPNICKIEJ 28`
- `business_id`: `7852`, `7853`, `9415`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 9

Podmioty w scalonej grupie:
  - `7852` HALA FORUM SPOŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MARII KONOPNICKIEJ 28`)
  - `9415` HALA FORUM SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MARII KONOPNICKIEJ 28`)
  - `7853` HALA FORUM SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MARII KONOPNICKIEJ 28`)

### A047. Meiselsa 24

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054011`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MEISELSA 24`
- `business_id`: `8178`, `8600`, `9420`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 7

Podmioty w scalonej grupie:
  - `8178` GRUPA BAZAAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `MEISELSA 24`)
  - `8600` GRUPA BAZAAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (1 zez.; detal B; źródło: `MEISELSA 24`)
  - `9420` GRUPA BAZAAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MEISELSA 24`)

### A048. Meiselsa 9 lok. B

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054013`
- lokal po normalizacji: `B`
- zapisy źródłowe adresu/lokalu: `MEISELSA 9 lok B,g`, `MEISELSA 9/B,G`
- `business_id`: `3307`, `7410`
- podobieństwo nazw: 0.526
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3307` STUDNICKI KRZYSZTOF, STUDNICKI WOJCIECH (1 zez.; detal A; źródło: `MEISELSA 9 lok B,g`)
  - `7410` STUDNICKI WOJCIECH, STUDNICKI KRZYSZTOF (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MEISELSA 9/B,G`)

### A049. Michała Bałuckiego 9A

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054015`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MICHAŁA BAŁUCKIEGO 9A`
- `business_id`: `22`, `9018`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9018` FIRMA HANDLOWA EWA WĄCŁAWSKA ,MAREK WĄCŁAWSKI SPÓŁKA JAWNA (1 zez.; detal A; źródło: `MICHAŁA BAŁUCKIEGO 9A`)
  - `22` FIRMA HANDLOWA EWA WĄCŁAWSKA, MAREK WĄCŁAWSKI SPÓŁKA JAWNA (2 zez.; detal B, detal C; źródło: `MICHAŁA BAŁUCKIEGO 9A`)

### A050. Miechowska 18

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055520`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MIECHOWSKA 18`
- `business_id`: `4100`, `6889`
- podobieństwo nazw: 0.500
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `4100` LE JOANNA, LE SON (2 zez.; gastronomia A, gastronomia B; źródło: `MIECHOWSKA 18`)
  - `6889` SON LE, JOANNA LE (1 zez.; gastronomia C; źródło: `MIECHOWSKA 18`)

### A051. Miodowa 13A

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054033`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MIODOWA 13A`
- `business_id`: `3094`, `3374`
- podobieństwo nazw: 0.980
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3374` ZGÓRKIEWICZ KRZYSZTOF, WOŁKOUN MARCIN, KURBIEL RAFAŁ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MIODOWA 13A`)
  - `3094` ZGÓRKIEWICZ KRZYSZTOF, WOŁKUN MARCIN, KURBIEL RAFAŁ (1 zez.; detal A; źródło: `MIODOWA 13A`)

### A052. Mostowa 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055581`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MOSTOWA 2`
- `business_id`: `8027`, `9440`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `8027` MARCHEWKA Z GROSZKIEM SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA (1 zez.; gastronomia C; źródło: `MOSTOWA 2`)
  - `9440` MARCHEWKA Z GROSZKIEM SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `MOSTOWA 2`)

### A053. Mostowa 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054064`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MOSTOWA 4`
- `business_id`: `3311`, `7659`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3311` WILCZEK KRAKÓW SPOŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `MOSTOWA 4`)
  - `7659` WILCZEK KRAKÓW SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MOSTOWA 4`)

### A054. Na Kozłówce 3

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054083`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `NA KOZŁÓWCE 3`
- `business_id`: `8195`, `9033`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9033` PARO 2 SPÓLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `NA KOZŁÓWCE 3`)
  - `8195` PARO 2 SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal B, detal C; źródło: `NA KOZŁÓWCE 3`)

### A055. Osiedle Centrum D 2 lok. 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1053433`
- lokal po normalizacji: `1`
- zapisy źródłowe adresu/lokalu: `CENTRUM D 2 lok LU1`, `CENTRUM D 2 lok. LU 1`, `OSIEDLE CENTRUM D 2 LU 1`
- `business_id`: `3232`, `7863`
- podobieństwo nazw: 0.120
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `3232` GRYSZA MICHAŁ, WARUNEK JAN (2 zez.; detal A, gastronomia B; źródło: `CENTRUM D 2 lok LU1`, `CENTRUM D 2 lok. LU 1`)
  - `7863` WARUNEK JAN, GRYSZA MICHAŁ (1 zez.; gastronomia A; źródło: `OSIEDLE CENTRUM D 2 LU 1`)

### A056. Osiedle Dywizjonu 303 62B lok. 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054170`
- lokal po normalizacji: `6`
- zapisy źródłowe adresu/lokalu: `OSIEDLE DYWIZJONU 303 62B lok. LU6`, `OSIEDLE DYWIZJONU 303 62B/LU6`
- `business_id`: `8211`, `9204`
- podobieństwo nazw: 0.231
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9204` DOMINIKA PLAK (1 zez.; detal B; źródło: `OSIEDLE DYWIZJONU 303 62B/LU6`)
  - `8211` PLAK DOMINIKA (1 zez.; detal A; źródło: `OSIEDLE DYWIZJONU 303 62B lok. LU6`)

### A057. Osiedle Józefa Strusia 21

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054178`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE JÓZEFA STRUSIA 21`
- `business_id`: `2358`, `9051`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9051` LIDL SPÓLKA Z O.O. SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE JÓZEFA STRUSIA 21`)
  - `2358` LIDL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE JÓZEFA STRUSIA 21`)

### A058. Osiedle Na Lotnisku 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054198`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE NA LOTNISKU 2`
- `business_id`: `2455`, `3122`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `3122` ALDI SPOLKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE NA LOTNISKU 2`)
  - `2455` ALDI SPÓŁKA Z O.O. (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE NA LOTNISKU 2`)

### A059. Osiedle Wandy 30A

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054241`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE WANDY 30A`, `WANDY 30A`
- `business_id`: `8851`, `9222`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `8851` ORLEN SPÓŁKA AKCYJNA (1 zez.; detal A; źródło: `OSIEDLE WANDY 30A`)
  - `9222` ORLEN SPŁKA AKCYJNA (1 zez.; detal C; źródło: `WANDY 30A`)

### A060. Osiedle Złotego Wieku 75

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054250`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE ZŁOTEGO WIEKU 75`
- `business_id`: `1360`, `1534`
- podobieństwo nazw: 0.226
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `1360` MUSIAŁ ADAM, ZIELENIAK SEBASTIAN (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE ZŁOTEGO WIEKU 75`)
  - `1534` ZIELENIAK SEBASTIAN, MUSIAŁ ADAM (1 zez.; detal A; źródło: `OSIEDLE ZŁOTEGO WIEKU 75`)

### A061. Pawia 5

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054268`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PAWIA 5`
- `business_id`: `3629`, `7978`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `7978` UVA SPÓŁKA Z O.O.S.K. (1 zez.; gastronomia B; źródło: `PAWIA 5`)
  - `3629` UVA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (2 zez.; detal B, detal C; źródło: `PAWIA 5`)

### A062. Pawia 5

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054271`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PAWIA 5`, `PAWIA 5 poziom + 1`
- `business_id`: `3510`, `9207`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `3510` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O.O. (1 zez.; detal B; źródło: `PAWIA 5`)
  - `9207` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z OGRANICZONĄ (1 zez.; detal B; źródło: `PAWIA 5 poziom + 1`)

### A063. Pawia 5

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054273`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PAWIA 5`
- `business_id`: `3801`, `7167`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `3801` AMREST SPÓŁKA Z O.O. (1 zez.; gastronomia A; źródło: `PAWIA 5`)
  - `7167` AMREST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `PAWIA 5`)

### A064. Plac Bohaterów Getta 17

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054880`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC BOHATERÓW GETTA 17`
- `business_id`: `3748`, `7533`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `3748` COFFEE BROTHERS SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `PLAC BOHATERÓW GETTA 17`)
  - `7533` COFFEE BROTHERS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; gastronomia B; źródło: `PLAC BOHATERÓW GETTA 17`)

### A065. Plac Dominikański 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055676`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC DOMINIKAŃSKI 4`
- `business_id`: `8648`, `9463`
- podobieństwo nazw: 0.143
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `8648` MADEJ ELŻBIETA, STĘPIEŃ PAWEŁ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC DOMINIKAŃSKI 4`)
  - `9463` STĘPIEŃ PAWEŁ, MADEJ ELŻBIETA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC DOMINIKAŃSKI 4`)

### A066. Plac Nowowiejski 2 lok. 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054884`
- lokal po normalizacji: `4`
- zapisy źródłowe adresu/lokalu: `PLAC NOWOWIEJSKI 2 kiosk 4`, `PLAC NOWOWIEJSKI 2/4`
- `business_id`: `3549`, `3597`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `3597` NATURALIŚCI SPÓŁKA Z O.O. (1 zez.; gastronomia B; źródło: `PLAC NOWOWIEJSKI 2 kiosk 4`)
  - `3549` NATURALIŚCI SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `PLAC NOWOWIEJSKI 2/4`)

### A067. Plac Nowy 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055697`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC NOWY 1`
- `business_id`: `9470`, `9471`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9470` KRAKODERO ROBERT MUCHA, WITOLD BAĆ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC NOWY 1`)
  - `9471` KRAKODERO ROBERT MUCHA,WITOLD BAĆ SPÓŁKA KOMANDYTOWA, - (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC NOWY 1`)

### A068. Plac Nowy 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054298`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC NOWY 4`
- `business_id`: `3340`, `7436`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `7436` PIZZATOPIA SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA (2 zez.; gastronomia A, gastronomia B; źródło: `PLAC NOWY 4`)
  - `3340` PIZZATOPIA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal B; źródło: `PLAC NOWY 4`)

### A069. Plac Nowy 8

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054886`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC NOWY 8`
- `business_id`: `9208`, `9639`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9639` CERASUS SP. Z O.O. SP. K. (1 zez.; gastronomia B; źródło: `PLAC NOWY 8`)
  - `9208` CERASUS SPÓŁKA Z O.O.O. SPÓŁKA KOMANDYTOWA (1 zez.; detal B; źródło: `PLAC NOWY 8`)

### A070. Plac Nowy 9

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054299`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC NOWY 9`
- `business_id`: `3341`, `6737`
- podobieństwo nazw: 0.571
- zezwolenia w grupie: 9

Podmioty w scalonej grupie:
  - `6737` GRUPA A & G PAJDA KLESYK SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC NOWY 9`)
  - `3341` GRUPA SCANDALE PAJDA, KLESYK SPÓŁKA JAWNA (6 zez.; detal A, detal B, detal C, gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC NOWY 9`)

### A071. Plac Szczepański 5

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054889`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC SZCZEPAŃSKI 5`
- `business_id`: `9209`, `9476`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9476` B FUND SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC SZCZEPAŃSKI 5`)
  - `9209` B FUND SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal B, detal C; źródło: `PLAC SZCZEPAŃSKI 5`)

### A072. Plac Szczepański 8

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054305`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC SZCZEPAŃSKI 8`
- `business_id`: `3542`, `7993`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `7993` "INTER - CONSULT" SPÓŁKA AKCYJNA (1 zez.; gastronomia B; źródło: `PLAC SZCZEPAŃSKI 8`)
  - `3542` INTER-CONSULT SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `PLAC SZCZEPAŃSKI 8`)

### A073. Podgórska 34

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054322`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PODGÓRSKA 34`
- `business_id`: `7913`, `9071`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9071` WYSZYNK GALICYJSKI SPÓŁKA Z O.O. (2 zez.; detal A, detal B; źródło: `PODGÓRSKA 34`)
  - `7913` WYSZYNK GALICYJSKI SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PODGÓRSKA 34`)

### A074. Podgórska 34

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054325`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PODGÓRSKA 34`
- `business_id`: `3801`, `7167`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3801` AMREST SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PODGÓRSKA 34`)
  - `7167` AMREST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; gastronomia A; źródło: `PODGÓRSKA 34`)

### A075. Podwale 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054337`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PODWALE 6-7`
- `business_id`: `3345`, `7698`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `7698` C. K. BROWAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PODWALE 6-7`)
  - `3345` C.K.BROWAR SPOŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `PODWALE 6-7`)

### A076. Raciborska 17 lok. P11

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054397`
- lokal po normalizacji: `P11`
- zapisy źródłowe adresu/lokalu: `RACIBORSKA 17 lok. P 11`, `RACIBORSKA 17/P11`
- `business_id`: `7708`, `8246`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `8246` MIJAMOJE SPÓŁKA Z O. O. (1 zez.; detal A; źródło: `RACIBORSKA 17 lok. P 11`)
  - `7708` MIJAMOJE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RACIBORSKA 17/P11`)

### A077. Rajska 3 lok. 2

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054403`
- lokal po normalizacji: `2`
- zapisy źródłowe adresu/lokalu: `RAJSKA 3 lok. LU2`, `RAJSKA 3/LU2`
- `business_id`: `9089`, `9496`
- podobieństwo nazw: 0.963
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9089` OD KUCHNI GOLAŃSKI GOSTYLA SPÓLKA JAWNA (2 zez.; detal A, detal B; źródło: `RAJSKA 3 lok. LU2`)
  - `9496` OD KUCHNI GOLAŃSKI GOSTYLLA SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RAJSKA 3/LU2`)

### A078. Retoryka 21

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054899`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RETORYKA 21`
- `business_id`: `3355`, `9211`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `9211` WINOMAN.PL A BOCHEŃSKI SPÓŁKA JAWNA (1 zez.; detal B; źródło: `RETORYKA 21`)
  - `3355` WINOMAN.PL A. BOCHEŃSKI SPÓŁKA JAWNA (1 zez.; gastronomia B; źródło: `RETORYKA 21`)

### A079. Rynek Główny 13

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054901`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 13`, `RYNEK GŁÓWNY 13.0`
- `business_id`: `820`, `7358`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `7358` HOLDING LIWA SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 13`, `RYNEK GŁÓWNY 13.0`)
  - `820` HOLDING LIWA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal B, detal C; źródło: `RYNEK GŁÓWNY 13`)

### A080. Rynek Główny 46

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054902`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GŁÓWNY 46`, `RYNEK GŁÓWNY 46`
- `business_id`: `3436`, `3521`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3436` PIJALNIE CZEKOLADY SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `GŁÓWNY 46`)
  - `3521` PIJALNIE CZEKOLADY SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `RYNEK GŁÓWNY 46`)

### A081. Rynek Kleparski 20

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054907`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RYNEK KLEPARSKI 20`
- `business_id`: `3723`, `8362`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `3723` POTOCKI & CO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK KLEPARSKI 20`)
  - `8362` POTOCKI&CO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `RYNEK KLEPARSKI 20`)

### A082. Siewna 17

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054478`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SIEWNA 17`
- `business_id`: `2358`, `9051`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9051` LIDL SPÓLKA Z O.O. SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `SIEWNA 17`)
  - `2358` LIDL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `SIEWNA 17`)

### A083. Spółdzielców 3

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054506`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SPÓŁDZIELCÓW 3`
- `business_id`: `5786`, `8706`
- podobieństwo nazw: 0.419
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `5786` KOZIEŁ TOMASZ, WŁODARCZYK TOMASZ (1 zez.; gastronomia B; źródło: `SPÓŁDZIELCÓW 3`)
  - `8706` WŁODARCZYK TOMASZ, KOZIEŁ TOMASZ (1 zez.; gastronomia A; źródło: `SPÓŁDZIELCÓW 3`)

### A084. Starowiślna 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055879`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `STAROWIŚLNA 6`
- `business_id`: `4616`, `7738`
- podobieństwo nazw: 0.263
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `4616` NGUYEN THI NGOC ANH (1 zez.; gastronomia B; źródło: `STAROWIŚLNA 6`)
  - `7738` THI NGOC ANH NGUYEN (1 zez.; gastronomia A; źródło: `STAROWIŚLNA 6`)

### A085. Stradomska 13

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055917`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `STRADOMSKA 13`
- `business_id`: `8723`, `9642`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9642` TAWERNA MIEJSKA SPÓLKA Z O.O. (1 zez.; gastronomia B; źródło: `STRADOMSKA 13`)
  - `8723` TAWERNA MIEJSKA SPÓŁKA Z O.O. (2 zez.; gastronomia A, gastronomia C; źródło: `STRADOMSKA 13`)

### A086. Szewska 21 lok. 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054577`
- lokal po normalizacji: `4`
- zapisy źródłowe adresu/lokalu: `SZEWSKA 21 lok. LU 4-5`, `SZEWSKA 21/LU4-5`
- `business_id`: `9134`, `9549`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9549` MQTB SPÓLKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZEWSKA 21 lok. LU 4-5`)
  - `9134` MQTB SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `SZEWSKA 21/LU4-5`)

### A087. Szewska 22

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054574`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZEWSKA 22`
- `business_id`: `8279`, `8740`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `8279` PT1 SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal B; źródło: `SZEWSKA 22`)
  - `8740` PT1 SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `SZEWSKA 22`)

### A088. Szpitalna 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055970`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZPITALNA 1`
- `business_id`: `7756`, `9551`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `7756` MUSIC EVENTS SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZPITALNA 1`)
  - `9551` MUSIC EVENTS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZPITALNA 1`)

### A089. Szpitalna 34

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054922`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZPITALNA 34`
- `business_id`: `3730`, `9217`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `3730` KAWIARNIE MGB M. BORUTA SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZPITALNA 34`)
  - `9217` KAWIARNIE MGB M.BORUTA SPÓŁKA JAWNA (2 zez.; detal B, detal C; źródło: `SZPITALNA 34`)

### A090. Szpitalna 9

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054582`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZPITALNA 9`
- `business_id`: `8746`, `9135`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `8746` TAJSKA SPÓŁKA Z O.O. TOMASZA SP. K. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZPITALNA 9`)
  - `9135` TAJSKA SPÓŁKA Z O.O. TOMASZA SPÓŁKA KOMANDYTOWA (1 zez.; detal A; źródło: `SZPITALNA 9`)

### A091. Szybka 25 lok. 1

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1055977`
- lokal po normalizacji: `1`
- zapisy źródłowe adresu/lokalu: `SZYBKA 25/1`
- `business_id`: `9554`, `9645`
- podobieństwo nazw: 0.091
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `9554` MARIA MILEWSKA, PĘDZIWIATR BARBARA (2 zez.; gastronomia A, gastronomia B; źródło: `SZYBKA 25/1`)
  - `9645` PĘDZIWIATR BARBARA, MARIA MILEWSKA (1 zez.; gastronomia C; źródło: `SZYBKA 25/1`)

### A092. Tyniecka 56

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054637`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `TYNIECKA 56`
- `business_id`: `9146`, `9589`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 5

Podmioty w scalonej grupie:
  - `9146` CENTRUM TYNIECKA SPÓŁKA OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal B; źródło: `TYNIECKA 56`)
  - `9589` CENTRUM TYNIECKA SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `TYNIECKA 56`)

### A093. Władysława Reymonta 17

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1056114`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `WŁADYSŁAWA REYMONTA 17`, `WŁADYSŁAWA STANISŁAWA REYMONTA 17`
- `business_id`: `4521`, `9599`
- podobieństwo nazw: 0.986
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `4521` FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO-HUTNICZEJ W KRAKOWIE ACADEMICA (2 zez.; gastronomia B, gastronomia C; źródło: `WŁADYSŁAWA REYMONTA 17`)
  - `9599` FUNDACJA STUDENTÓW I ABSOLWWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE ACADEMICA (1 zez.; gastronomia A; źródło: `WŁADYSŁAWA STANISŁAWA REYMONTA 17`)

### A094. Władysława Łokietka 256

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054930`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `WŁADYSŁAWA ŁOKIETKA 256`
- `business_id`: `3495`, `9220`
- podobieństwo nazw: 0.067
- zezwolenia w grupie: 2

Podmioty w scalonej grupie:
  - `3495` MICHNIAK SZYMON (1 zez.; detal B; źródło: `WŁADYSŁAWA ŁOKIETKA 256`)
  - `9220` SZYMON MICHNIAK (1 zez.; detal B; źródło: `WŁADYSŁAWA ŁOKIETKA 256`)

### A095. Zakopiańska 62

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054755`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ZAKOPIAŃSKA 62`
- `business_id`: `4104`, `7586`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `4104` CINEMA CITY POLAND SPÓŁKA Z O.O. (1 zez.; gastronomia C; źródło: `ZAKOPIAŃSKA 62`)
  - `7586` CINEMA CITY POLAND SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `ZAKOPIAŃSKA 62`)

### A096. Zwierzyniecka 32

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1056167`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ZWIERZYNIECKA 32`
- `business_id`: `7328`, `9623`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `7328` SETTE GROUP SPÓŁKA Z O.O. (1 zez.; gastronomia C; źródło: `ZWIERZYNIECKA 32`)
  - `9623` SETTE GROUP SPÓŁKA ZO.O. (2 zez.; gastronomia A, gastronomia B; źródło: `ZWIERZYNIECKA 32`)

### A097. Zygmunta Augusta 9 lok. 4

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054938`
- lokal po normalizacji: `4`
- zapisy źródłowe adresu/lokalu: `ZYGMUNTA AUGUSTA 9 lok 4`, `ZYGMUNTA AUGUSTA 9/4`
- `business_id`: `8318`, `8812`
- podobieństwo nazw: 0.235
- zezwolenia w grupie: 3

Podmioty w scalonej grupie:
  - `8812` KRZESIWO KATARZYNA, STEMPAK PAULINA (2 zez.; gastronomia A, gastronomia B; źródło: `ZYGMUNTA AUGUSTA 9/4`)
  - `8318` STEMPAK PAULINA, KRZESIWO KATARZYNA (1 zez.; detal B; źródło: `ZYGMUNTA AUGUSTA 9 lok 4`)

### A098. św. Jana 6

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1056002`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ŚW. JANA 6`
- `business_id`: `9563`, `9564`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 6

Podmioty w scalonej grupie:
  - `9563` DREVNY KOCUR KRAKÓW SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ŚW. JANA 6`)
  - `9564` DREVNY KOCUR KRAKÓW SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ŚW. JANA 6`)

### A099. św. Wawrzyńca 12

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054605`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ŚW. WAWRZYŃCA 12`
- `business_id`: `5371`, `9139`
- podobieństwo nazw: 0.933
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `5371` HOTELE DE SILVA SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ŚW. WAWRZYŃCA 12`)
  - `9139` HOTELE DESILVA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `ŚW. WAWRZYŃCA 12`)

### A100. Żabiniec 91

- decyzja: [x] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE
- notatka:
- `license_point_group_id`: `1054792`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ŻABINIEC 91`
- `business_id`: `9182`, `9626`
- podobieństwo nazw: 1.000
- zezwolenia w grupie: 4

Podmioty w scalonej grupie:
  - `9182` HERO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; detal A, detal B; źródło: `ŻABINIEC 91`)
  - `9626` HERO SPÓŁKA Z.O.O. (2 zez.; gastronomia A, gastronomia B; źródło: `ŻABINIEC 91`)

## B. Próba adresów wielopodmiotowych bez scalenia

### B001. Targowa 2

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13848`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `TARGOWA 2`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054625`: TARGOWA2 MICHAŁ TARGOSZ DOMINIK KOZA SPÓŁKA JAWNA
  - `business_id`: `8780`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TARGOWA 2`
  - `8780` TARGOWA2 MICHAŁ TARGOSZ DOMINIK KOZA SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `TARGOWA 2`)
- grupa `1054624`: ZAMOJSKI ERNEST
  - `business_id`: `2336`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TARGOWA 2`
  - `2336` ZAMOJSKI ERNEST (3 zez.; detal A, detal B, detal C; źródło: `TARGOWA 2`)

### B002. Wielicka 259

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13728`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `WIELICKA 259`
- liczba podmiotów: 5
- liczba grup: 5

Grupy pod tym adresem:
- grupa `1054676`: GREECE COMPANY SPÓŁKA Z O.O.
  - `business_id`: `9218`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WIELICKA 259`
  - `9218` GREECE COMPANY SPÓŁKA Z O.O. (1 zez.; detal B; źródło: `WIELICKA 259`)
- grupa `1054673`: KAUFLAND POLSKA MARKETY SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA JAWNA
  - `business_id`: `8060`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WIELICKA 259`
  - `8060` KAUFLAND POLSKA MARKETY SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA JAWNA (3 zez.; detal A, detal B, detal C; źródło: `WIELICKA 259`)
- grupa `1054677`: OTSU MARCIN SIKORA SPÓŁKA KOMANDYTOWO-AKCYJNA
  - `business_id`: `9592`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WIELICKA 259`
  - `9592` OTSU MARCIN SIKORA SPÓŁKA KOMANDYTOWO-AKCYJNA (2 zez.; gastronomia A, gastronomia B; źródło: `WIELICKA 259`)
- grupa `1054674`: REMESLO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8848`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WIELICKA 259`
  - `8848` REMESLO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `WIELICKA 259`)
- grupa `1054675`: ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O.O.
  - `business_id`: `3510`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WIELICKA 259`
  - `3510` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O.O. (1 zez.; detal B; źródło: `WIELICKA 259`)

### B003. Witolda Budryka 4

- decyzja: [ ] OK  [x] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15496`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `WITOLDA BUDRYKA 4`
- liczba podmiotów: 4
- liczba grup: 4

Grupy pod tym adresem:
- grupa `1054697`: BROWAR GÓRNICZO - HUTNICZY SPÓŁKA AKCYJNA
  - `business_id`: `9162`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WITOLDA BUDRYKA 4`
  - `9162` BROWAR GÓRNICZO - HUTNICZY SPÓŁKA AKCYJNA (1 zez.; detal A; źródło: `WITOLDA BUDRYKA 4`)
- grupa `1054696`: FUNDACJA STUDENTÓW I ABSOLWENTÓW AGH W KRAKOWIE ACADEMICA
  - `business_id`: `3381`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WITOLDA BUDRYKA 4`
  - `3381` FUNDACJA STUDENTÓW I ABSOLWENTÓW AGH W KRAKOWIE ACADEMICA (1 zez.; detal A; źródło: `WITOLDA BUDRYKA 4`)
- grupa `1054698`: FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE
  - `business_id`: `7779`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WITOLDA BUDRYKA 4`
  - `7779` FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE (1 zez.; gastronomia A; źródło: `WITOLDA BUDRYKA 4`)
- grupa `1054699`: FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE ACADEMICA
  - `business_id`: `5133`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WITOLDA BUDRYKA 4`
  - `5133` FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE ACADEMICA (2 zez.; gastronomia B, gastronomia C; źródło: `WITOLDA BUDRYKA 4`)

### B004. Stanisława Kunickiego 5

- decyzja: [ ] OK  [x] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13082`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `STANISŁAWA KUNICKIEGO 5`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054511`: MICHOŃ CZESŁAW
  - `business_id`: `4893`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `STANISŁAWA KUNICKIEGO 5`
  - `4893` MICHOŃ CZESŁAW (3 zez.; detal A, detal B, detal C; źródło: `STANISŁAWA KUNICKIEGO 5`)
- grupa `1054510`: PASY OLAF SAMEK I WSPÓLNICY SPÓŁKA JAWNA
  - `business_id`: `9118`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `STANISŁAWA KUNICKIEGO 5`
  - `9118` PASY OLAF SAMEK I WSPÓLNICY SPÓŁKA JAWNA (3 zez.; detal A, detal B, detal C; źródło: `STANISŁAWA KUNICKIEGO 5`)

### B005. Władysława Broniewskiego 1

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `12762`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `WŁADYSŁAWA BRONIEWSKIEGO 1`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054705`: PALCZEWSKA ANNA, KOWINA ELŻBIETA
  - `business_id`: `3304`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WŁADYSŁAWA BRONIEWSKIEGO 1`
  - `3304` PALCZEWSKA ANNA, KOWINA ELŻBIETA (3 zez.; detal A, detal B, detal C; źródło: `WŁADYSŁAWA BRONIEWSKIEGO 1`)
- grupa `1054706`: ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `3668`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `WŁADYSŁAWA BRONIEWSKIEGO 1`
  - `3668` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal B; źródło: `WŁADYSŁAWA BRONIEWSKIEGO 1`)

### B006. Osiedle Kazimierzowskie 30

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13337`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE KAZIMIERZOWSKIE 30`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054187`: LEWIATAN MARKET SPOŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8213`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `OSIEDLE KAZIMIERZOWSKIE 30`
  - `8213` LEWIATAN MARKET SPOŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `OSIEDLE KAZIMIERZOWSKIE 30`)
- grupa `1054186`: MUSIAŁ TOMASZ
  - `business_id`: `1950`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `OSIEDLE KAZIMIERZOWSKIE 30`
  - `1950` MUSIAŁ TOMASZ (1 zez.; detal A; źródło: `OSIEDLE KAZIMIERZOWSKIE 30`)

### B007. Osiedle Bohaterów Września 76

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13299`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `OSIEDLE BOHATERÓW WRZEŚNIA 76`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054163`: GUZIK PATRYCJA, GUZIK JULIA
  - `business_id`: `7861`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `OSIEDLE BOHATERÓW WRZEŚNIA 76`
  - `7861` GUZIK PATRYCJA, GUZIK JULIA (2 zez.; gastronomia A, gastronomia C; źródło: `OSIEDLE BOHATERÓW WRZEŚNIA 76`)
- grupa `1054162`: TUCZYŃSKI GRZEGORZ
  - `business_id`: `19`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `OSIEDLE BOHATERÓW WRZEŚNIA 76`
  - `19` TUCZYŃSKI GRZEGORZ (3 zez.; detal A, detal B, detal C; źródło: `OSIEDLE BOHATERÓW WRZEŚNIA 76`)

### B008. Gołębia 5

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `17142`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GOŁĘBIA 5`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053588`: EWMAX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8925`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GOŁĘBIA 5`
  - `8925` EWMAX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `GOŁĘBIA 5`)
- grupa `1053589`: HORECA INVESTMENTS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8486`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GOŁĘBIA 5`
  - `8486` HORECA INVESTMENTS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `GOŁĘBIA 5`)

### B009. Osiedle Jagiellońskie 19

- decyzja: [ ] OK  [x] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13330`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JAGIELLOŃSKIE 19`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053652`: JERONIMO MARTINS POSKA SPÓŁKA AKCYJNA
  - `business_id`: `8942`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JAGIELLOŃSKIE 19`
  - `8942` JERONIMO MARTINS POSKA SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `JAGIELLOŃSKIE 19`)
- grupa `1053651`: MIKUŁA MATEUSZ
  - `business_id`: `8941`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JAGIELLOŃSKIE 19`
  - `8941` MIKUŁA MATEUSZ (3 zez.; detal A, detal B, detal C; źródło: `JAGIELLOŃSKIE 19`)

### B010. Aleja 29 Listopada 57

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `19907`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA 29 LISTOPADA 57-59`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053219`: MIŚKIEWICZ ZUZANNA, MIŚKIEWICZ GRZEGORZ
  - `business_id`: `7511`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA 29 LISTOPADA 57-59`
  - `7511` MIŚKIEWICZ ZUZANNA, MIŚKIEWICZ GRZEGORZ (2 zez.; gastronomia A, gastronomia B; źródło: `ALEJA 29 LISTOPADA 57-59`)
- grupa `1053218`: WIELECKI WIKTOR, WIELECKA ALICJA, WIELECKI MATEUSZ, WIELECKA WERONIKA, PROFIC TOMASZ, BANAŚ PIOTR
  - `business_id`: `8845`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA 29 LISTOPADA 57-59`
  - `8845` WIELECKI WIKTOR, WIELECKA ALICJA, WIELECKI MATEUSZ, WIELECKA WERONIKA, PROFIC TOMASZ, BANAŚ PIOTR (3 zez.; detal A, detal B, detal C; źródło: `ALEJA 29 LISTOPADA 57-59`)

### B011. Aleja Juliusza Słowackiego 22

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15762`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `AL. SŁOWACKIEGO 22`, `ALEJA JULIUSZA SŁOWACKIEGO 22`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053246`: CATERIX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8378`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `AL. SŁOWACKIEGO 22`
  - `8378` CATERIX SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `AL. SŁOWACKIEGO 22`)
- grupa `1053245`: RUSIN NORBERT
  - `business_id`: `8852`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA JULIUSZA SŁOWACKIEGO 22`
  - `8852` RUSIN NORBERT (3 zez.; detal A, detal B, detal C; źródło: `ALEJA JULIUSZA SŁOWACKIEGO 22`)

### B012. Reduta 26

- decyzja: [ ] OK  [x] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15317`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `REDUTA 26`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054413`: P.H.U. KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `9092`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `REDUTA 26`
  - `9092` P.H.U. KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (1 zez.; detal A; źródło: `REDUTA 26`)
- grupa `1054412`: PHU KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SP. K.
  - `business_id`: `3067`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `REDUTA 26`
  - `3067` PHU KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SP. K. (3 zez.; detal A, detal B, detal C; źródło: `REDUTA 26`)

### B013. Bratysławska 1

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `12753`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BRATYSŁAWSKA 1`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053393`: SHELL POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `164`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BRATYSŁAWSKA 1`
  - `164` SHELL POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `BRATYSŁAWSKA 1`)
- grupa `1053394`: THI LE
  - `business_id`: `9260`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BRATYSŁAWSKA 1`
  - `9260` THI LE (1 zez.; gastronomia A; źródło: `BRATYSŁAWSKA 1`)

### B014. Grzegórzecka 69

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15950`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRZEGÓRZECKA 69`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053612`: CARREFOUR POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `437`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GRZEGÓRZECKA 69`
  - `437` CARREFOUR POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `GRZEGÓRZECKA 69`)
- grupa `1053613`: QUOC PHONG LE
  - `business_id`: `7829`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GRZEGÓRZECKA 69`
  - `7829` QUOC PHONG LE (2 zez.; gastronomia A, gastronomia B; źródło: `GRZEGÓRZECKA 69`)

### B015. Sienna 11

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `14567`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SIENNA 11`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055838`: BOIKO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ
  - `business_id`: `8694`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIENNA 11`
  - `8694` BOIKO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SIENNA 11`)
- grupa `1055837`: BRYŚ KAMIL
  - `business_id`: `8695`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIENNA 11`
  - `8695` BRYŚ KAMIL (2 zez.; gastronomia A, gastronomia B; źródło: `SIENNA 11`)

### B016. Krakowska 31

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13033`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KRAKOWSKA 31`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053846`: CHWASTEK AGNIESZKA
  - `business_id`: `8343`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `KRAKOWSKA 31`
  - `8343` CHWASTEK AGNIESZKA (1 zez.; detal B; źródło: `KRAKOWSKA 31`)
- grupa `1053845`: ŚWIATŁOŃ JAN
  - `business_id`: `377`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `KRAKOWSKA 31`
  - `377` ŚWIATŁOŃ JAN (3 zez.; detal A, detal B, detal C; źródło: `KRAKOWSKA 31`)

### B017. Józefitów 8

- decyzja: [ ] OK  [x] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15516`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JÓZEFITÓW 8`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054833`: WINE GARAGE GROUP SPÓŁKA Z O.O.
  - `business_id`: `9194`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFITÓW 8`
  - `9194` WINE GARAGE GROUP SPÓŁKA Z O.O. (1 zez.; detal B; źródło: `JÓZEFITÓW 8`)
- grupa `1054834`: WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA
  - `business_id`: `3704`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFITÓW 8`
  - `3704` WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFITÓW 8`)

### B018. Stolarska 6

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16395`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `STOLARSKA 6`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055909`: B.O.H.O COFFEE & BAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8720`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `STOLARSKA 6`
  - `8720` B.O.H.O COFFEE & BAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `STOLARSKA 6`)
- grupa `1055908`: SIESTA MAGDALENA WILANOWSKA, TOMASZ WILANOWSKI SPÓŁKA JAWNA
  - `business_id`: `7741`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `STOLARSKA 6`
  - `7741` SIESTA MAGDALENA WILANOWSKA, TOMASZ WILANOWSKI SPÓŁKA JAWNA (2 zez.; gastronomia A, gastronomia B; źródło: `STOLARSKA 6`)

### B019. Rynek Główny 28

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15182`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 28`, `RYNEK GŁÓWNY 28.0`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055801`: ADAMCZYK JAKUB, WĘGLARZ MACIEJ
  - `business_id`: `6967`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 28`, `RYNEK GŁÓWNY 28.0`
  - `6967` ADAMCZYK JAKUB, WĘGLARZ MACIEJ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 28`, `RYNEK GŁÓWNY 28.0`)
- grupa `1055802`: DOBRA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `7460`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 28`, `RYNEK GŁÓWNY 28.0`
  - `7460` DOBRA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 28`, `RYNEK GŁÓWNY 28.0`)

### B020. Beskidzka 30

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `12696`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BESKIDZKA 30`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053336`: JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA
  - `business_id`: `1489`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BESKIDZKA 30`
  - `1489` JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `BESKIDZKA 30`)
- grupa `1053335`: SKALNIAK PAULINA
  - `business_id`: `2756`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BESKIDZKA 30`
  - `2756` SKALNIAK PAULINA (3 zez.; detal A, detal B, detal C; źródło: `BESKIDZKA 30`)

### B021. Papiernicza 3

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16225`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PAPIERNICZA 3`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055654`: CASINOS POLAND CP SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `7424`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `PAPIERNICZA 3`
  - `7424` CASINOS POLAND CP SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PAPIERNICZA 3`)
- grupa `1055655`: DONIMIRSKI JERZY
  - `business_id`: `1043`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `PAPIERNICZA 3`
  - `1043` DONIMIRSKI JERZY (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PAPIERNICZA 3`)

### B022. Plac Szczepański 7

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16263`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `PLAC SZCZEPAŃSKI 7`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055708`: CAPIVARA SPÓŁKA ZO.O.
  - `business_id`: `8655`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `PLAC SZCZEPAŃSKI 7`
  - `8655` CAPIVARA SPÓŁKA ZO.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC SZCZEPAŃSKI 7`)
- grupa `1055707`: THE SQUARE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ
  - `business_id`: `8654`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `PLAC SZCZEPAŃSKI 7`
  - `8654` THE SQUARE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `PLAC SZCZEPAŃSKI 7`)

### B023. Tadeusza Romanowicza 4

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15339`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `TADEUSZA ROMANOWICZA 4`
- liczba podmiotów: 4
- liczba grup: 4

Grupy pod tym adresem:
- grupa `1054615`: FFS BIS SPÓŁKA Z O.O.
  - `business_id`: `9584`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TADEUSZA ROMANOWICZA 4`
  - `9584` FFS BIS SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `TADEUSZA ROMANOWICZA 4`)
- grupa `1054616`: KISZONKI.PL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8777`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TADEUSZA ROMANOWICZA 4`
  - `8777` KISZONKI.PL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (2 zez.; gastronomia A, gastronomia B; źródło: `TADEUSZA ROMANOWICZA 4`)
- grupa `1054614`: P.H.U. ZACHĘTA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓLKA KOMANDYTOWA
  - `business_id`: `3188`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TADEUSZA ROMANOWICZA 4`
  - `3188` P.H.U. ZACHĘTA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓLKA KOMANDYTOWA (3 zez.; detal A, detal B, detal C; źródło: `TADEUSZA ROMANOWICZA 4`)
- grupa `1054613`: SALUTE GLAZER, GOSTYLLA, JASNOSZ, MACHETA SPÓŁKA JAWNA
  - `business_id`: `8289`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `TADEUSZA ROMANOWICZA 4`
  - `8289` SALUTE GLAZER, GOSTYLLA, JASNOSZ, MACHETA SPÓŁKA JAWNA (6 zez.; detal A, detal B, detal C, gastronomia A, gastronomia B, gastronomia C; źródło: `TADEUSZA ROMANOWICZA 4`)

### B024. Szpitalna 36

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `14201`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZPITALNA 36`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054583`: MARUNCHAK OLHA
  - `business_id`: `9136`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZPITALNA 36`
  - `9136` MARUNCHAK OLHA (1 zez.; detal A; źródło: `SZPITALNA 36`)
- grupa `1054584`: PAWEŁCZYK MARCIN
  - `business_id`: `8747`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZPITALNA 36`
  - `8747` PAWEŁCZYK MARCIN (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZPITALNA 36`)

### B025. Józefa 34

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `20049`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JÓZEFA 34`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055291`: SKUZA-KASZUBA ALEKSANDRA, KASZUBA MARIUSZ
  - `business_id`: `5018`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFA 34`
  - `5018` SKUZA-KASZUBA ALEKSANDRA, KASZUBA MARIUSZ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA 34`)
- grupa `1055290`: VIDOJU SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA
  - `business_id`: `7568`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFA 34`
  - `7568` VIDOJU SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA 34`)

### B026. Floriańska 26

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15893`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 26`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055169`: GRUZIŃSKIE CHACZAPURI SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA
  - `business_id`: `8464`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 26`
  - `8464` GRUZIŃSKIE CHACZAPURI SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 26`)
- grupa `1055168`: TMK INWESTYCJE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ
  - `business_id`: `8465`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 26`
  - `8465` TMK INWESTYCJE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILANOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 26`)

### B027. Mały Rynek 4

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15555`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MAŁY RYNEK 4`
- liczba podmiotów: 3
- liczba grup: 3

Grupy pod tym adresem:
- grupa `1055491`: BOROŃ ANNA, IGNAS-MADEJ WERONIKA
  - `business_id`: `6548`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MAŁY RYNEK 4`
  - `6548` BOROŃ ANNA, IGNAS-MADEJ WERONIKA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MAŁY RYNEK 4`)
- grupa `1055489`: ODUS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `7644`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MAŁY RYNEK 4`
  - `7644` ODUS SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MAŁY RYNEK 4`)
- grupa `1055490`: WOŁKOUN MARCIN, ZGÓRKIEWICZ KRZYSZTOF
  - `business_id`: `5304`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MAŁY RYNEK 4`
  - `5304` WOŁKOUN MARCIN, ZGÓRKIEWICZ KRZYSZTOF (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MAŁY RYNEK 4`)

### B028. Rynek Główny 34

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13574`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 34`
- liczba podmiotów: 3
- liczba grup: 3

Grupy pod tym adresem:
- grupa `1054440`: JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA
  - `business_id`: `1489`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 34`
  - `1489` JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `RYNEK GŁÓWNY 34`)
- grupa `1054442`: LOŻA KRZYSZTOF NOWOSAD SPÓŁKA JAWNA
  - `business_id`: `5543`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 34`
  - `5543` LOŻA KRZYSZTOF NOWOSAD SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 34`)
- grupa `1054441`: N FOOD HOŁUBICZKO, EDRIES, GAWRYLUK SPÓŁKA KOMANDYTOWA
  - `business_id`: `8617`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 34`
  - `8617` N FOOD HOŁUBICZKO, EDRIES, GAWRYLUK SPÓŁKA KOMANDYTOWA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 34`)

### B029. Rynek Podgórski 8

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15320`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `RYNEK PODGÓRSKI 8`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054453`: KOZIŃSKA KATARZYNA
  - `business_id`: `3159`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK PODGÓRSKI 8`
  - `3159` KOZIŃSKA KATARZYNA (3 zez.; detal A, detal B, detal C; źródło: `RYNEK PODGÓRSKI 8`)
- grupa `1054454`: MILENA GUMIENNY
  - `business_id`: `9514`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK PODGÓRSKI 8`
  - `9514` MILENA GUMIENNY (2 zez.; gastronomia A, gastronomia B; źródło: `RYNEK PODGÓRSKI 8`)

### B030. Aleja gen. Tadeusza Bora-Komorowskiego 39

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `12647`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 39`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053227`: BP EUROPA SE SPÓŁKA EUROPEJSKA ODDZIAŁ W POLSCE
  - `business_id`: `1456`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 39`
  - `1456` BP EUROPA SE SPÓŁKA EUROPEJSKA ODDZIAŁ W POLSCE (3 zez.; detal A, detal B, detal C; źródło: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 39`)
- grupa `1053228`: TRAN VAN MAGDALENA, ZALEJSKI WIESŁAW
  - `business_id`: `7240`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 39`
  - `7240` TRAN VAN MAGDALENA, ZALEJSKI WIESŁAW (1 zez.; gastronomia A; źródło: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 39`)

### B031. Henryka i Karola Czeczów 48 lok. 6

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `19491`
- lokal po normalizacji: `6`
- zapisy źródłowe adresu/lokalu: `HENRYKA I KAROLA CZECZÓW 48 lok LU6`, `HENRYKA I KAROLA CZECZÓW 48 lok. LU 6`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053626`: KULT KAWY SPÓŁKA Z O.O.
  - `business_id`: `9330`
  - lokal po normalizacji: `6`
  - zapisy źródłowe adresu/lokalu: `HENRYKA I KAROLA CZECZÓW 48 lok. LU 6`
  - `9330` KULT KAWY SPÓŁKA Z O.O. (2 zez.; gastronomia A, gastronomia B; źródło: `HENRYKA I KAROLA CZECZÓW 48 lok. LU 6`)
- grupa `1053625`: RACHWAŁ DAWID
  - `business_id`: `8111`
  - lokal po normalizacji: `6`
  - zapisy źródłowe adresu/lokalu: `HENRYKA I KAROLA CZECZÓW 48 lok LU6`
  - `8111` RACHWAŁ DAWID (3 zez.; detal A, detal B, detal C; źródło: `HENRYKA I KAROLA CZECZÓW 48 lok LU6`)

### B032. Rynek Główny 29

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16333`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GŁÓWNY 29`, `RYNEK GŁÓWNY 29`, `RYNEK GŁÓWNY 29.0`
- liczba podmiotów: 3
- liczba grup: 3

Grupy pod tym adresem:
- grupa `1055805`: ADAMCZYK JAKUB, WĘGLARZ MACIEJ
  - `business_id`: `6967`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GŁÓWNY 29`, `RYNEK GŁÓWNY 29`
  - `6967` ADAMCZYK JAKUB, WĘGLARZ MACIEJ (2 zez.; gastronomia A, gastronomia B; źródło: `GŁÓWNY 29`, `RYNEK GŁÓWNY 29`)
- grupa `1055803`: KULISA PAWEŁ, FRANCZAK PAWEŁ
  - `business_id`: `4560`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 29`, `RYNEK GŁÓWNY 29.0`
  - `4560` KULISA PAWEŁ, FRANCZAK PAWEŁ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 29`, `RYNEK GŁÓWNY 29.0`)
- grupa `1055804`: ZAJĄC-SOLECKA ZDZISŁAWA, SOLECKI BOGDAN
  - `business_id`: `7881`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `RYNEK GŁÓWNY 29`, `RYNEK GŁÓWNY 29.0`
  - `7881` ZAJĄC-SOLECKA ZDZISŁAWA, SOLECKI BOGDAN (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `RYNEK GŁÓWNY 29`, `RYNEK GŁÓWNY 29.0`)

### B033. Malborska 35

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13164`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MALBORSKA 35`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053964`: MICHALSKA - SOBESTO AGNIESZKA
  - `business_id`: `8170`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MALBORSKA 35`
  - `8170` MICHALSKA - SOBESTO AGNIESZKA (3 zez.; detal A, detal B, detal C; źródło: `MALBORSKA 35`)
- grupa `1053965`: NGUYEN THI GIANG
  - `business_id`: `7407`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MALBORSKA 35`
  - `7407` NGUYEN THI GIANG (1 zez.; gastronomia A; źródło: `MALBORSKA 35`)

### B034. Grażyny 4

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `20063`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `GRAŻYNY 4`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053591`: JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA
  - `business_id`: `1489`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GRAŻYNY 4`
  - `1489` JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `GRAŻYNY 4`)
- grupa `1053592`: ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O. O.
  - `business_id`: `3623`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `GRAŻYNY 4`
  - `3623` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O. O. (1 zez.; detal B; źródło: `GRAŻYNY 4`)

### B035. Bulwar Czerwieński dz. 172/7

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `20135`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BULWAR CZERWIEŃSKI dz. nr 172/7`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055064`: KAPUSTA KRYSTIAN
  - `business_id`: `883`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BULWAR CZERWIEŃSKI dz. nr 172/7`
  - `883` KAPUSTA KRYSTIAN (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `BULWAR CZERWIEŃSKI dz. nr 172/7`)
- grupa `1055063`: KRAKOWSKA GRUPA AMNIS SPÓŁKA Z O.O.
  - `business_id`: `6516`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BULWAR CZERWIEŃSKI dz. nr 172/7`
  - `6516` KRAKOWSKA GRUPA AMNIS SPÓŁKA Z O.O. (1 zez.; gastronomia A; źródło: `BULWAR CZERWIEŃSKI dz. nr 172/7`)

### B036. Józefa 26

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `20048`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `JÓZEFA 26`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055288`: KUCHNIA WŁOSKA BEATA SEWERYN, ŁUKASZ PRZYBYLSKI SPÓŁKA JAWNA, .
  - `business_id`: `7040`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFA 26`
  - `7040` KUCHNIA WŁOSKA BEATA SEWERYN, ŁUKASZ PRZYBYLSKI SPÓŁKA JAWNA, . (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA 26`)
- grupa `1055287`: VARIOS ADAM MELNYCZUK SPÓŁKA JAWNA
  - `business_id`: `4082`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `JÓZEFA 26`
  - `4082` VARIOS ADAM MELNYCZUK SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `JÓZEFA 26`)

### B037. Szeroka 20

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16428`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZEROKA 20`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055945`: AFT HOTEL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8734`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZEROKA 20`
  - `8734` AFT HOTEL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZEROKA 20`)
- grupa `1055944`: ŁADOCHA MAGDALENA
  - `business_id`: `5961`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZEROKA 20`
  - `5961` ŁADOCHA MAGDALENA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZEROKA 20`)

### B038. Szewska 14

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16438`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SZEWSKA 14`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055956`: CZERNECKI DANIEL
  - `business_id`: `9545`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZEWSKA 14`
  - `9545` CZERNECKI DANIEL (2 zez.; gastronomia A, gastronomia B; źródło: `SZEWSKA 14`)
- grupa `1055955`: WARMUZ ŁUKASZ
  - `business_id`: `5814`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SZEWSKA 14`
  - `5814` WARMUZ ŁUKASZ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SZEWSKA 14`)

### B039. Aleja gen. Tadeusza Bora-Komorowskiego 37

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `12646`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- 37`, `ALEJA GEN. TADEUSZA BORA- KAOLEMJAO GREONW. STKAIDEGEUOSZA BORA- 37`, `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 37`, `KOMOROWSKIEGO 37`
- liczba podmiotów: 3
- liczba grup: 3

Grupy pod tym adresem:
- grupa `1053224`: AUCHAN POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `1483`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- KAOLEMJAO GREONW. STKAIDEGEUOSZA BORA- 37`, `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 37`
  - `1483` AUCHAN POLSKA SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `ALEJA GEN. TADEUSZA BORA- KAOLEMJAO GREONW. STKAIDEGEUOSZA BORA- 37`, `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 37`)
- grupa `1053225`: KRAVCHENKO ANDRIY
  - `business_id`: `2650`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 37`, `KOMOROWSKIEGO 37`
  - `2650` KRAVCHENKO ANDRIY (3 zez.; detal A, detal B, detal C; źródło: `ALEJA GEN. TADEUSZA BORA- KOMOROWSKIEGO 37`, `KOMOROWSKIEGO 37`)
- grupa `1053226`: ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SP. Z O.O.
  - `business_id`: `3640`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA GEN. TADEUSZA BORA- 37`
  - `3640` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SP. Z O.O. (1 zez.; detal B; źródło: `ALEJA GEN. TADEUSZA BORA- 37`)

### B040. Nefrytowa 4

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13246`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `NEFRYTOWA 4`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054109`: ANEX SPÓŁKA Z O. O.
  - `business_id`: `8203`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `NEFRYTOWA 4`
  - `8203` ANEX SPÓŁKA Z O. O. (3 zez.; detal A, detal B, detal C; źródło: `NEFRYTOWA 4`)
- grupa `1054110`: HIGH FLY SPÓLKA Z O.O.
  - `business_id`: `9453`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `NEFRYTOWA 4`
  - `9453` HIGH FLY SPÓLKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `NEFRYTOWA 4`)

### B041. Karmelicka 17

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15145`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KARMELICKA 17`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053764`: MARYNOWSKA KATARZYNA
  - `business_id`: `8131`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `KARMELICKA 17`
  - `8131` MARYNOWSKA KATARZYNA (3 zez.; detal A, detal B, detal C; źródło: `KARMELICKA 17`)
- grupa `1053765`: WASZKIEWICZ ADAM, WASZKIEWICZ STANISŁAWA
  - `business_id`: `8544`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `KARMELICKA 17`
  - `8544` WASZKIEWICZ ADAM, WASZKIEWICZ STANISŁAWA (2 zez.; gastronomia A, gastronomia B; źródło: `KARMELICKA 17`)

### B042. Miodowa 43

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16157`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MIODOWA 43`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055561`: MS GROUP SEBASTIAN BANAŚ MARCIN MIERNICZEK SPÓŁKA JAWNA
  - `business_id`: `7655`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MIODOWA 43`
  - `7655` MS GROUP SEBASTIAN BANAŚ MARCIN MIERNICZEK SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MIODOWA 43`)
- grupa `1055562`: SIERPIŃSKI PIOTR
  - `business_id`: `7060`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MIODOWA 43`
  - `7060` SIERPIŃSKI PIOTR (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MIODOWA 43`)

### B043. św. Gertrudy 5

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13674`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ŚW. GERTRUDY 5`, `ŚWIETEJ GERTRUDY 5`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054598`: ABRAMCIÓW RAFAŁ
  - `business_id`: `2578`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ŚWIETEJ GERTRUDY 5`
  - `2578` ABRAMCIÓW RAFAŁ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ŚWIETEJ GERTRUDY 5`)
- grupa `1054597`: DELIKATESY CENTRUM SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `3065`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ŚW. GERTRUDY 5`
  - `3065` DELIKATESY CENTRUM SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; detal A, detal B, detal C; źródło: `ŚW. GERTRUDY 5`)

### B044. Bracka 4

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15804`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `BRACKA 4`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053391`: 1ST FLOOR SPÓŁKA Z O.O.
  - `business_id`: `5210`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BRACKA 4`
  - `5210` 1ST FLOOR SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `BRACKA 4`)
- grupa `1053390`: CIAPAŁA EWELINA
  - `business_id`: `1635`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `BRACKA 4`
  - `1635` CIAPAŁA EWELINA (3 zez.; detal A, detal B, detal C; źródło: `BRACKA 4`)

### B045. Osiedle Kościuszkowskie 5

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13351`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `KOŚCIUSZKOWSKIE 5`, `OSIEDLE KOŚCIUSZKOWSKIE 5`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053839`: DOKTOR NO MACIEJ JOJCZYK, RAFAŁ NOGA SPÓŁKA JAWNA
  - `business_id`: `1685`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `OSIEDLE KOŚCIUSZKOWSKIE 5`
  - `1685` DOKTOR NO MACIEJ JOJCZYK, RAFAŁ NOGA SPÓŁKA JAWNA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `OSIEDLE KOŚCIUSZKOWSKIE 5`)
- grupa `1053838`: SPOŁEM POWSZECHNA SPÓŁDZIELNIA SPOZYWCÓW NOWA HUTA W KRAKOWIE
  - `business_id`: `2443`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `KOŚCIUSZKOWSKIE 5`
  - `2443` SPOŁEM POWSZECHNA SPÓŁDZIELNIA SPOZYWCÓW NOWA HUTA W KRAKOWIE (1 zez.; detal A; źródło: `KOŚCIUSZKOWSKIE 5`)

### B046. Aleja Pokoju 81

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16780`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `ALEJA POKOJU 81`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1053270`: MROCZEK MICHAŁ
  - `business_id`: `8046`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA POKOJU 81`
  - `8046` MROCZEK MICHAŁ (3 zez.; detal A, detal B, detal C; źródło: `ALEJA POKOJU 81`)
- grupa `1053271`: TRATTORIA KRAKÓW SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8396`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `ALEJA POKOJU 81`
  - `8396` TRATTORIA KRAKÓW SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `ALEJA POKOJU 81`)

### B047. Sienna 12

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `13597`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SIENNA 12`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054476`: FOOD & FRIENDS MSHG SPÓŁKA Z O.O.
  - `business_id`: `9111`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIENNA 12`
  - `9111` FOOD & FRIENDS MSHG SPÓŁKA Z O.O. (4 zez.; detal A, gastronomia A, gastronomia B, gastronomia C; źródło: `SIENNA 12`)
- grupa `1054477`: KOGEL MOGEL MSHG SPÓŁKA Z O.O.
  - `business_id`: `6757`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIENNA 12`
  - `6757` KOGEL MOGEL MSHG SPÓŁKA Z O.O. (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `SIENNA 12`)

### B048. Mikołajska 9

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `16140`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `MIKOŁAJSKA 9`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055535`: DZIEDZIC DAGMARA
  - `business_id`: `5427`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MIKOŁAJSKA 9`
  - `5427` DZIEDZIC DAGMARA (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MIKOŁAJSKA 9`)
- grupa `1055534`: PRO-BAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ
  - `business_id`: `8604`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `MIKOŁAJSKA 9`
  - `8604` PRO-BAR SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `MIKOŁAJSKA 9`)

### B049. Floriańska 47

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15899`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 47`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1055179`: RESTAURACJA VOTO SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ, .
  - `business_id`: `8470`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 47`
  - `8470` RESTAURACJA VOTO SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOŚCIĄ, . (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 47`)
- grupa `1055178`: SMAGACZ TOMASZ
  - `business_id`: `5056`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `FLORIAŃSKA 47`
  - `5056` SMAGACZ TOMASZ (3 zez.; gastronomia A, gastronomia B, gastronomia C; źródło: `FLORIAŃSKA 47`)

### B050. Siewna 46

- decyzja: [x] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE
- notatka:
- `transformed_location_id`: `15013`
- lokal po normalizacji: brak
- zapisy źródłowe adresu/lokalu: `SIEWNA 46`
- liczba podmiotów: 2
- liczba grup: 2

Grupy pod tym adresem:
- grupa `1054479`: JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA
  - `business_id`: `1489`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIEWNA 46`
  - `1489` JERONIMO MARTINS POLSKA SPÓŁKA AKCYJNA (3 zez.; detal A, detal B, detal C; źródło: `SIEWNA 46`)
- grupa `1054480`: ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O. O.
  - `business_id`: `3623`
  - lokal po normalizacji: brak
  - zapisy źródłowe adresu/lokalu: `SIEWNA 46`
  - `3623` ROSSMANN SUPERMARKETY DROGERYJNE POLSKA SPÓŁKA Z O. O. (1 zez.; detal B; źródło: `SIEWNA 46`)
