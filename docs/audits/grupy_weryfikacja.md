# Ręczna weryfikacja grup zezwoleń

Źródło: `grupy.md`, raport `2026-02-06 08:43:09`.

Legenda:
- `[x] OK` - w lokacji nie widać oczywistych brakujących połączeń grup.
- `[!] DO POPRAWY` - w lokacji są grupy, które wyglądają na ten sam podmiot i powinny być połączone.
- `[~] PODEJRZANE SCALENIE` - istniejąca grupa może łączyć podmioty, które nie powinny być razem.
- `[?] NIEPEWNE` - wymaga dodatkowego sprawdzenia poza samą nazwą.

## Sprawdzone

1. `[x] OK` Pawia 5 - 39 zezwoleń, 17 grup. Różne lokale w centrum handlowym; istniejące warianty `AMREST` i `UVA` są już połączone. `INVESTMENT PARTNERS BCC` i `INVESTMENT PARTNERS GB` zostawiam osobno, bo różnią się identyfikatorem podmiotu w nazwie.
2. `[x] OK` Podgórska 34 - 31 zezwoleń, 11 grup. Różne lokale; warianty `WYSZYNK GALICYJSKI` i `AMREST` są już połączone.
3. `[!] DO POPRAWY` Fabryczna 13 - 24 zezwolenia, 8 grup. Do połączenia wyglądają grupy:
   - `346348` - `F. R. B. INTER-BUD SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA`
   - `346345` - `F.R.B.INTER - BUD SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMADYTOWA`
   Pozostałe nazwy z członem `FABRYCZNA` wyglądają na osobne podmioty.
4. `[x] OK` Henryka Kamieńskiego 11 - 22 zezwolenia, 10 grup. Różne lokale w Bonarce; warianty `AMREST` są już połączone.
5. `[x] OK` Aleja Pokoju 67 - 20 zezwoleń, 11 grup. Różne lokale; brak oczywistych dubli nazw podmiotów.
6. `[x] OK` Marii Konopnickiej 28 - 15 zezwoleń, 3 grupy. `HALA FORUM` jest połączona; `FP HOLDING` i `SUKCESS` wyglądają osobno.
7. `[x] OK` Rynek Główny 6 - 15 zezwoleń, 5 grup. Różne podmioty.
8. `[x] OK` Aleja gen. Tadeusza Bora-Komorowskiego 41 - 14 zezwoleń, 7 grup. Różne podmioty; brak oczywistego dubla.
9. `[x] OK` Tadeusza Romanowicza 4 - 14 zezwoleń, 4 grupy. Różne podmioty.
10. `[x] OK` św. Jana 2 - 13 zezwoleń, 4 grupy. Różne podmioty.
11. `[x] OK` Bracka 3 - 12 zezwoleń, 4 grupy. `KŁOBUCH MAREK` i `KŁOBUCH MAREK, KŁOBUCH MARZENA` zostawiam osobno, bo drugi wpis dodaje wspólnika, więc automatyczne połączenie byłoby ryzykowne.
12. `[x] OK` Mikołajska 5 - 12 zezwoleń, 3 grupy. Różne podmioty.
13. `[!] DO POPRAWY` Plac Nowy 9 - 12 zezwoleń, 3 grupy. Do połączenia wyglądają grupy:
   - `347193` - `GRUPA SCANDALE PAJDA, KLESYK SPÓŁKA JAWNA`
   - `347195` - `GRUPA A & G PAJDA KLESYK SPÓŁKA JAWNA`
   Trzon osobowy `PAJDA KLESYK` jest ten sam; to odpowiada wcześniej znalezionemu przypadkowi.
14. `[x] OK` Plac Szczepański 3 - 12 zezwoleń, 4 grupy. Różne podmioty.
15. `[x] OK` Stolarska 5 - 12 zezwoleń, 4 grupy. Różne podmioty.
16. `[x] OK` Szczepańska 1 - 12 zezwoleń, 4 grupy. Różne podmioty.
17. `[x] OK` Sławkowska 10 - 12 zezwoleń, 4 grupy. `CIAPAŁA EWELINA` i `CIAPAŁA EWELINA, SZMALEC MACIEJ` zostawiam osobno, bo drugi wpis dodaje wspólnika.
18. `[x] OK` Sławkowska 13 - 12 zezwoleń, 4 grupy. Różne podmioty.
19. `[x] OK` Plac Szczepański 8 - 11 zezwoleń, 4 grupy. Warianty `INTER-CONSULT` są już połączone; pozostałe grupy są różne.
20. `[x] OK` Stawowa 61 - 10 zezwoleń, 5 grup. Różne podmioty; `AUC24` i `AUCHAN POLSKA` zostawiam osobno.
21. `[x] OK` Szpitalna 40 - 10 zezwoleń, 4 grupy. Różne podmioty.
22. `[x] OK` Agatowa 31 - 9 zezwoleń, 4 grupy. Różne podmioty.
23. `[x] OK` Józefa 11 - 9 zezwoleń, 3 grupy. Różne podmioty.
24. `[x] OK` Karmelicka 7 - 9 zezwoleń, 3 grupy. Różne podmioty.
25. `[!] DO POPRAWY` Królowej Jadwigi 248 - 9 zezwoleń, 4 grupy. Do połączenia wyglądają grupy:
   - `346730` - `JUSTYNA CZEKAJ - GROCHOWSKA`
   - `346729` - `CZEKAJ-GROCHOWSKA JUSTYNA`
   To wygląda na tę samą osobę zapisaną w odwróconej kolejności i z inną interpunkcją.
26. `[x] OK` Mała Góra 16 - 9 zezwoleń, 3 grupy. Różne podmioty.
27. `[x] OK` Mały Rynek 4 - 9 zezwoleń, 3 grupy. Różne podmioty.
28. `[x] OK` Mostowa 2 - 9 zezwoleń, 3 grupy. Warianty `MARCHEWKA Z GROSZKIEM` są już połączone; pozostałe grupy są różne.
29. `[x] OK` Osiedle 2 Pułku Lotniczego 1C - 9 zezwoleń, 3 grupy. Różne podmioty.
30. `[x] OK` Osiedle Na Wzgórzach 31 - 9 zezwoleń, 3 grupy. Różne podmioty.
31. `[!] DO POPRAWY` Plac Dominikański 4 - 9 zezwoleń, 3 grupy. Do połączenia wyglądają grupy:
   - `348558` - `MADEJ ELŻBIETA, STĘPIEŃ PAWEŁ`
   - `348559` - `STĘPIEŃ PAWEŁ, MADEJ ELŻBIETA`
   To ten sam zestaw osób w odwróconej kolejności.
32. `[x] OK` Plac Mariacki 1 - 9 zezwoleń, 1 grupa. Warianty `BULLDOG BAR` są już połączone.
33. `[x] OK` Profesora Michała Bobrzyńskiego 33 - 9 zezwoleń, 3 grupy. Różne podmioty.
34. `[x] OK` Raciborska 17 - 9 zezwoleń, 3 grupy. Warianty `MIJAMOJE` są już połączone; pozostałe grupy są różne.
35. `[x] OK` Rynek Główny 19 - 9 zezwoleń, 1 grupa. Wszystko w jednej grupie `NAWITO`.
36. `[x] OK` Rynek Główny 34 - 9 zezwoleń, 3 grupy. Różne podmioty.
37. `[x] OK` Stolarska 13 - 9 zezwoleń, 3 grupy. Różne podmioty.
38. `[x] OK` Szczepańska 3 - 9 zezwoleń, 3 grupy. `WANOWICZ MAŁGORZATA` i `WANOWICZ MAŁGORZATA, BRODA KAMA` zostawiam osobno, bo drugi wpis dodaje wspólnika.
39. `[x] OK` Szewska 20 - 9 zezwoleń, 3 grupy. Różne podmioty.
40. `[x] OK` Westerplatte 15 - 9 zezwoleń, 3 grupy. Różne podmioty.
41. `[x] OK` Wielicka 259 - 9 zezwoleń, 6 grup. Różne podmioty.
42. `[x] OK` Wiślna 5 - 9 zezwoleń, 3 grupy. Różne podmioty.
43. `[x] OK` Wrocławska 53A/2 - 9 zezwoleń, 2 grupy. Różne podmioty.
44. `[x] OK` Zakopiańska 62 - 9 zezwoleń, 3 grupy. Warianty `CINEMA CITY POLAND` są już połączone; pozostałe grupy są różne.
45. `[x] OK` Aleja gen. Tadeusza Bora-Komorowskiego 37 - 8 zezwoleń, 4 grupy. Różne podmioty.
46. `[x] OK` Benedyktyńska 37 - 8 zezwoleń, 1 grupa. Warianty `BENEDICITE/BENEDICTE` są już połączone.
47. `[x] OK` Floriańska 38 - 8 zezwoleń, 3 grupy. Różne podmioty.
48. `[x] OK` Józefa Dietla 44 - 8 zezwoleń, 3 grupy. Różne podmioty.
49. `[x] OK` Kazimierza Brodzińskiego 3 - 8 zezwoleń, 3 grupy. Różne podmioty.
50. `[x] OK` Księcia Józefa 20 - 8 zezwoleń, 4 grupy. Różne podmioty.
51. `[x] OK` Miodowa 33 - 8 zezwoleń, 2 grupy. Warianty `LESU` są już połączone; druga grupa jest innym podmiotem.
52. `[x] OK` Plac Szczepański 5 - 8 zezwoleń, 2 grupy. Warianty `B FUND` są już połączone; druga grupa jest innym podmiotem.
53. `[x] OK` Rynek Główny 29 - 8 zezwoleń, 3 grupy. Różne podmioty.
54. `[x] OK` Rynek Kleparski 20 - 8 zezwoleń, 3 grupy. Warianty `POTOCKI & CO` są już połączone; pozostałe grupy są różne.
55. `[x] OK` Stolarska 6 - 8 zezwoleń, 3 grupy. Różne podmioty.
56. `[x] OK` Balicka 18 - 7 zezwoleń, 3 grupy. Różne podmioty.
57. `[x] OK` Bracka 6 - 7 zezwoleń, 3 grupy. Różne podmioty.
58. `[x] OK` Galicyjska 16 - 7 zezwoleń, 3 grupy. Różne podmioty.
59. `[x] OK` Grodzka 34 - 7 zezwoleń, 2 grupy. Różne podmioty.
60. `[x] OK` Meiselsa 24 - 7 zezwoleń, 1 grupa. Warianty `GRUPA BAZAAR` są już połączone.
61. `[x] OK` Mieczysława Medweckiego 2 - 7 zezwoleń, 4 grupy. Różne podmioty.
62. `[x] OK` Miodowa 19 - 7 zezwoleń, 2 grupy. Warianty `TAJSKA` są już połączone; druga grupa jest innym podmiotem.
63. `[x] OK` Młyńska 8 - 7 zezwoleń, 3 grupy. Różne podmioty.
64. `[x] OK` Rynek Główny 27 - 7 zezwoleń, 2 grupy. Różne podmioty.
65. `[x] OK` Rynek Główny 46 - 7 zezwoleń, 2 grupy. Warianty `PIJALNIE CZEKOLADY` są już połączone; druga grupa jest innym podmiotem.
66. `[x] OK` Rynek Kleparski 20K - 7 zezwoleń, 2 grupy. Różne podmioty.
67. `[x] OK` Sienna 12 - 7 zezwoleń, 2 grupy. Wspólny człon `MSHG`, ale różne nazwy lokali/podmiotów, więc zostawiam osobno.
68. `[x] OK` Stradomska 11 - 7 zezwoleń, 2 grupy. Różne podmioty.
69. `[x] OK` Szewska 21 - 7 zezwoleń, 3 grupy. Różne podmioty.
70. `[x] OK` Szewska 22 - 7 zezwoleń, 2 grupy. Warianty `PT1` są już połączone; druga grupa jest innym podmiotem.
71. `[x] OK` Sławkowska 26 - 7 zezwoleń, 2 grupy. Różne podmioty.
72. `[x] OK` Wincentego Witosa 19A - 7 zezwoleń, 3 grupy. Różne podmioty.
73. `[x] OK` Agatowa 1 - 6 zezwoleń, 2 grupy. Różne podmioty; podobieństwo nazwiska `RADECKI/STOLARZ-RADECKA` nie wystarcza do scalenia.
74. `[x] OK` Aleja Ignacego Daszyńskiego 3 - 6 zezwoleń, 1 grupa.
75. `[x] OK` Aleja Jerzego Waszyngtona 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
76. `[x] OK` Aleja Juliusza Słowackiego 64 - 6 zezwoleń, 2 grupy. Różne podmioty.
77. `[x] OK` Aleja Marszałka Ferdinanda Focha 1 - 6 zezwoleń, 1 grupa.
78. `[x] OK` Aleja Pokoju 14 - 6 zezwoleń, 2 grupy. Różne podmioty.
79. `[x] OK` Aleja Pokoju 81 - 6 zezwoleń, 2 grupy. Różne podmioty.
80. `[x] OK` Aleja Zygmunta Krasińskiego 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
81. `[x] OK` Aleja Zygmunta Krasińskiego 8 - 6 zezwoleń, 2 grupy. Różne podmioty.
82. `[x] OK` Aleja płk. Władysława Beliny-Prażmowskiego 2D - 6 zezwoleń, 2 grupy. Różne podmioty.
83. `[x] OK` Bartosza Głowackiego 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
84. `[x] OK` Bernarda Wapowskiego 8 - 6 zezwoleń, 1 grupa. Warianty `WINNICA & WINO` są już połączone.
85. `[x] OK` Beskidzka 30 - 6 zezwoleń, 2 grupy. Różne podmioty.
86. `[x] OK` Bocheńska 7 - 6 zezwoleń, 2 grupy. Różne podmioty.
87. `[x] OK` Borsucza 12 - 6 zezwoleń, 2 grupy. Różne podmioty.
88. `[x] OK` Bożego Ciała 14 - 6 zezwoleń, 1 grupa. Warianty `LITEX HORECA` są już połączone.
89. `[x] OK` Bożego Ciała 7 - 6 zezwoleń, 2 grupy. Różne podmioty.
90. `[x] OK` Bracka 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
91. `[x] OK` Brzozowa 17 - 6 zezwoleń, 2 grupy. Różne podmioty.
92. `[x] OK` Bulwar Czerwieński; dz. 81/5, obręb 146 - 6 zezwoleń, 2 grupy. Różne podmioty.
93. `[x] OK` Bulwar Kurlandzki; dz. 137/7, obręb 12 - 6 zezwoleń, 2 grupy. Różne podmioty.
94. `[x] OK` Bulwar Kurlandzki; dz. 94, obręb 15 - 6 zezwoleń, 2 grupy. Różne podmioty.
95. `[x] OK` Centralna 41A - 6 zezwoleń, 2 grupy. Różne podmioty.
96. `[x] OK` Czysta 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
97. `[x] OK` Dobrego Pasterza 100 - 6 zezwoleń, 2 grupy. Różne podmioty.
98. `[x] OK` Dąbska 5 - 6 zezwoleń, 1 grupa.
99. `[x] OK` Estery 18 - 6 zezwoleń, 2 grupy. Wspólny człon `NOVA` i osoba `ADAM MELNYCZUK`, ale nazwy/formy podmiotów są różne (`NOVA` vs `NOVA KLUBOWA`, sp.k. vs sp.j.), więc zostawiam osobno.
100. `[x] OK` Floriańska 15 - 6 zezwoleń, 2 grupy. Różne podmioty.
101. `[x] OK` Floriańska 20 - 6 zezwoleń, 2 grupy. Warianty `STAROPOLSKIE TRUNKI REGIONALNE` są już połączone; druga grupa jest innym podmiotem.
102. `[x] OK` Floriańska 24 - 6 zezwoleń, 2 grupy. Różne podmioty.
103. `[x] OK` Floriańska 26 - 6 zezwoleń, 2 grupy. Różne podmioty.
104. `[x] OK` Floriańska 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
105. `[x] OK` Floriańska 47 - 6 zezwoleń, 2 grupy. Różne podmioty.
106. `[x] OK` Floriańska 9 - 6 zezwoleń, 1 grupa. Warianty `REST-KRAK GASTROX` są już połączone.
107. `[x] OK` Gołębia 2 - 6 zezwoleń, 2 grupy. Warianty `MAJEWSKA-SKROBICH` są już połączone; druga grupa jest innym podmiotem.
108. `[x] OK` Gołębia 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
109. `[x] OK` Grodzka 51 - 6 zezwoleń, 2 grupy. Różne podmioty.
110. `[x] OK` Grodzka 6 - 6 zezwoleń, 1 grupa. Warianty `REST-KRAK GASTROX` są już połączone.
111. `[x] OK` Grodzka 63 - 6 zezwoleń, 2 grupy. Różne podmioty.
112. `[x] OK` Grodzka 9 - 6 zezwoleń, 1 grupa.
113. `[x] OK` Henryka Pachońskiego 8 - 6 zezwoleń, 2 grupy. Różne podmioty.
114. `[x] OK` Henryka Pachońskiego 8A - 6 zezwoleń, 2 grupy. Różne podmioty.
115. `[x] OK` Izaaka 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
116. `[x] OK` Jagiellońska 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
117. `[x] OK` Jana Kilińskiego 2 - 6 zezwoleń, 1 grupa.
118. `[x] OK` Jana Kurczaba 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
119. `[x] OK` Josepha Conrada 79 - 6 zezwoleń, 2 grupy. Warianty `VININOVA` są już połączone; druga grupa jest innym podmiotem.
120. `[x] OK` Juliusza Lea 90A - 6 zezwoleń, 2 grupy. Różne podmioty.
121. `[x] OK` Józefa 17 - 6 zezwoleń, 2 grupy. Różne podmioty.
122. `[x] OK` Józefa 26 - 6 zezwoleń, 2 grupy. Różne podmioty.
123. `[x] OK` Józefa 34 - 6 zezwoleń, 2 grupy. Różne podmioty.
124. `[x] OK` Józefa Dietla 55 - 6 zezwoleń, 1 grupa. Warianty `N&N NA JUNHYOUNG/JUNYOUNG` są już połączone.
125. `[x] OK` Józefa Dietla 75 - 6 zezwoleń, 2 grupy. Różne podmioty.
126. `[x] OK` Józefa Dietla 85 - 6 zezwoleń, 2 grupy. Różne podmioty.
127. `[x] OK` Józefa Dietla 91 - 6 zezwoleń, 2 grupy. Różne podmioty.
128. `[x] OK` Józefa Wybickiego 54 - 6 zezwoleń, 2 grupy. Różne podmioty.
129. `[x] OK` Kamienna 2 - 6 zezwoleń, 2 grupy. Różne podmioty.
130. `[x] OK` Kanonicza 11 - 6 zezwoleń, 1 grupa.
131. `[x] OK` Kapelanka 54 - 6 zezwoleń, 4 grupy. Różne podmioty.
132. `[x] OK` Karola Bunscha 19 - 6 zezwoleń, 2 grupy. Różne podmioty.
133. `[x] OK` Kawiory 41 - 6 zezwoleń, 2 grupy. Różne podmioty.
134. `[x] OK` Kobierzyńska 106 - 6 zezwoleń, 1 grupa.
135. `[x] OK` Kobierzyńska 62A - 6 zezwoleń, 1 grupa.
136. `[x] OK` Komandosów 1 - 6 zezwoleń, 1 grupa. Warianty `POZNAŃSKA-CHLEBDA` są już połączone.
137. `[x] OK` Krakowska 6 - 6 zezwoleń, 1 grupa. Warianty `PG GROUP` są już połączone.
138. `[x] OK` Krupnicza 9 - 6 zezwoleń, 2 grupy. Warianty `SIMMART` są już połączone; druga grupa jest innym podmiotem.
139. `[x] OK` Królewska 52 - 6 zezwoleń, 1 grupa.
140. `[!] DO POPRAWY` Leonida Teligi 11 - 6 zezwoleń, 3 grupy. Do połączenia wyglądają grupy:
   - `346769` - `CZAPIGA MARIUSZ, CZAPIGA ZBIGNIEW`
   - `346767` - `MARIUSZ CZAPIGA, ZBIGNIEW CZAPIGA`
   To ten sam zestaw osób zapisany w innym szyku.
141. `[!] DO POPRAWY` Lipowa 6F - 6 zezwoleń, 2 grupy. Do połączenia wyglądają grupy:
   - `346778` - `JAROSZ JANUSZ, SIEWIOREK AGNIESZKA`
   - `346779` - `SIEWIOREK AGNIESZKA, JAROSZ JANUSZ`
   To ten sam zestaw osób w odwróconej kolejności.
142. `[x] OK` Lubicz 26 - 6 zezwoleń, 2 grupy. Różne podmioty.
143. `[x] OK` Marii Konopnickiej 33 - 6 zezwoleń, 1 grupa.
144. `[x] OK` Mazowiecka 88 - 6 zezwoleń, 2 grupy. Różne podmioty.
145. `[x] OK` Mikołajska 9 - 6 zezwoleń, 2 grupy. Różne podmioty.
146. `[x] OK` Miodowa 23 - 6 zezwoleń, 1 grupa.
147. `[x] OK` Miodowa 25 - 6 zezwoleń, 2 grupy. Różne podmioty.
148. `[x] OK` Miodowa 28 - 6 zezwoleń, 2 grupy. Różne podmioty.
149. `[x] OK` Miodowa 43 - 6 zezwoleń, 2 grupy. Różne podmioty.
150. `[x] OK` Mogilska 86 - 6 zezwoleń, 2 grupy. Różne podmioty.
151. `[x] OK` Mostowa 6 - 6 zezwoleń, 2 grupy. Różne podmioty.
152. `[x] OK` Mostowa 8 - 6 zezwoleń, 3 grupy. `BULWARY SZTUKI` i `FUNDACJA BULWARY SZTUKI` zostawiam osobno, bo fundacja może być odrębnym podmiotem.
153. `[x] OK` Nadwiślańska 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
154. `[x] OK` Nadwiślańska 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
155. `[x] OK` Nefrytowa 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
156. `[x] OK` Osiedle Bohaterów Września 82 - 6 zezwoleń, 2 grupy. Różne podmioty.
157. `[x] OK` Osiedle Jagiellońskie 19 - 6 zezwoleń, 2 grupy. Różne podmioty.
158. `[x] OK` Osiedle Józefa Strusia 21 - 6 zezwoleń, 1 grupa. Warianty `LIDL` są już połączone.
159. `[x] OK` Osiedle Kalinowe 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
160. `[x] OK` Osiedle Na Lotnisku 2 - 6 zezwoleń, 1 grupa. Warianty `ALDI` są już połączone.
161. `[x] OK` Osiedle Na Lotnisku 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
162. `[x] OK` Osiedle Na Skarpie 39 - 6 zezwoleń, 2 grupy. Różne podmioty.
163. `[x] OK` Osiedle Słoneczne 8 - 6 zezwoleń, 2 grupy. Różne podmioty.
164. `[x] OK` Papiernicza 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
165. `[x] OK` Pawia 18B - 6 zezwoleń, 1 grupa.
166. `[x] OK` Piastowska 47 - 6 zezwoleń, 2 grupy. Różne podmioty.
167. `[x] OK` Plac Dominikański 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
168. `[x] OK` Plac Nowy 1 - 6 zezwoleń, 1 grupa. Warianty `KRAKODERO` są już połączone.
169. `[x] OK` Plac Nowy 7 - 6 zezwoleń, 2 grupy. Różne podmioty.
170. `[x] OK` Plac Szczepański 2 - 6 zezwoleń, 2 grupy. Różne podmioty.
171. `[x] OK` Plac Szczepański 7 - 6 zezwoleń, 2 grupy. Różne podmioty.
172. `[x] OK` Podzamcze 24 - 6 zezwoleń, 2 grupy. Różne podmioty.
173. `[x] OK` Przewóz 40A/3 - 6 zezwoleń, 2 grupy. Różne podmioty.
174. `[x] OK` Rajska 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
175. `[x] OK` Rakowicka 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
176. `[x] OK` Rakowicka 11 - 6 zezwoleń, 2 grupy. Różne podmioty.
177. `[x] OK` Rynek Główny 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
178. `[x] OK` Rynek Główny 10 - 6 zezwoleń, 2 grupy. Różne podmioty.
179. `[x] OK` Rynek Główny 22 - 6 zezwoleń, 2 grupy. Różne podmioty.
180. `[x] OK` Rynek Główny 28 - 6 zezwoleń, 2 grupy. Różne podmioty.
181. `[x] OK` Rynek Główny 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
182. `[x] OK` Rynek Główny 36 - 6 zezwoleń, 2 grupy. Różne podmioty.
183. `[x] OK` Rynek Główny 39 - 6 zezwoleń, 2 grupy. Różne podmioty.
184. `[x] OK` Rynek Główny 7 - 6 zezwoleń, 1 grupa. Warianty `FIGA-2` są już połączone.
185. `[x] OK` Rynek Główny 9 - 6 zezwoleń, 2 grupy. Różne podmioty.
186. `[x] OK` Siewna 17 - 6 zezwoleń, 1 grupa. Warianty `LIDL` są już połączone.
187. `[x] OK` Stanisława Klimeckiego 14B - 6 zezwoleń, 2 grupy. Różne podmioty.
188. `[x] OK` Stanisława Kunickiego 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
189. `[x] OK` Stanisława Lema 7 - 6 zezwoleń, 1 grupa.
190. `[x] OK` Starowiślna 15A - 6 zezwoleń, 2 grupy. Różne podmioty.
191. `[x] OK` Stefana Batorego 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
192. `[x] OK` Strzelców 26 - 6 zezwoleń, 2 grupy. Różne podmioty.
193. `[x] OK` Sukiennicza 8/5 - 6 zezwoleń, 1 grupa.
194. `[x] OK` Szeroka 20 - 6 zezwoleń, 2 grupy. Różne podmioty.
195. `[x] OK` Szewska 9 - 6 zezwoleń, 2 grupy. Różne podmioty.
196. `[x] OK` Szlak 50 - 6 zezwoleń, 2 grupy. Różne podmioty.
197. `[x] OK` Szpitalna 1 - 6 zezwoleń, 1 grupa. Warianty `MUSIC EVENTS` są już połączone.
198. `[x] OK` Szpitalna 38 - 6 zezwoleń, 2 grupy. Różne podmioty.
199. `[x] OK` Sławkowska 12 - 6 zezwoleń, 1 grupa.
200. `[x] OK` Sławkowska 4 - 6 zezwoleń, 2 grupy. Różne podmioty.
201. `[x] OK` Tadeusza Kościuszki 42 - 6 zezwoleń, 2 grupy. Różne podmioty.
202. `[x] OK` Tadeusza Romanowicza 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
203. `[x] OK` Targowa 2 - 6 zezwoleń, 2 grupy. Różne podmioty.
204. `[x] OK` Tyniecka 118H - 6 zezwoleń, 1 grupa.
205. `[x] OK` Walerego Sławka 45A - 6 zezwoleń, 2 grupy. Różne podmioty.
206. `[x] OK` Warszauera 1 - 6 zezwoleń, 2 grupy. Różne podmioty.
207. `[x] OK` Wiślna 11 - 6 zezwoleń, 2 grupy. Różne podmioty.
208. `[x] OK` Wrocławska 28 - 6 zezwoleń, 2 grupy. Różne podmioty.
209. `[x] OK` Zakopiańska 56 - 6 zezwoleń, 2 grupy. Różne podmioty.
210. `[x] OK` gen. Augusta Fieldorfa-Nila 17 - 6 zezwoleń, 2 grupy. Różne podmioty.
211. `[x] OK` Ślusarska 9 - 6 zezwoleń, 2 grupy. Różne podmioty.
212. `[x] OK` św. Gertrudy 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
213. `[x] OK` św. Gertrudy 7 - 6 zezwoleń, 2 grupy. Różne podmioty.
214. `[x] OK` św. Jana 5 - 6 zezwoleń, 2 grupy. Różne podmioty.
215. `[x] OK` św. Jana 6 - 6 zezwoleń, 1 grupa. Warianty `DREVNY KOCUR KRAKÓW` są już połączone.
216. `[x] OK` św. Sebastiana 33 - 6 zezwoleń, 2 grupy. Różne podmioty.
217. `[x] OK` św. Tomasza 8 - 6 zezwoleń, 2 grupy. Różne podmioty.
218. `[x] OK` św. Wawrzyńca 19 - 6 zezwoleń, 2 grupy. Różne podmioty.
219. `[x] OK` św. Wawrzyńca 3 - 6 zezwoleń, 2 grupy. Różne podmioty.
220. `[x] OK` Aleja 29 Listopada 57 - 5 zezwoleń, 2 grupy. Różne podmioty.
221. `[x] OK` Aleja 3 Maja 55 - 5 zezwoleń, 1 grupa. Warianty `WISTERIA` są już połączone.
222. `[x] OK` Aleja Juliusza Słowackiego 22 - 5 zezwoleń, 2 grupy. Różne podmioty.
223. `[x] OK` Armii Krajowej 19 - 5 zezwoleń, 2 grupy. Różne podmioty.
224. `[x] OK` Bożego Ciała 12 - 5 zezwoleń, 2 grupy. Różne podmioty.
225. `[x] OK` Centralna 30 - 5 zezwoleń, 2 grupy. Różne podmioty.
226. `[x] OK` Estery 5 - 5 zezwoleń, 1 grupa.
227. `[x] OK` Floriańska 13 - 5 zezwoleń, 2 grupy. Różne podmioty.
228. `[!] DO POPRAWY` Grodzka 46 - 5 zezwoleń, 3 grupy. Do połączenia wyglądają grupy:
   - `346447` - `KAROLINA PACH`
   - `346448` - `PACH KAROLINA`
   To ta sama osoba w odwróconej kolejności.
229. `[x] OK` Grzegórzecka 69 - 5 zezwoleń, 2 grupy. Różne podmioty.
230. `[x] OK` Henryka i Karola Czeczów 48/6 - 5 zezwoleń, 2 grupy. Różne podmioty.
231. `[!] DO POPRAWY` Jakuba 19 - 5 zezwoleń, 2 grupy. Do połączenia wyglądają grupy:
   - `348177` - `ZGÓRKIEWICZ KRZYSZTOF, WOŁKOUN MARCIN, KURBIEL RAFAŁ`
   - `348178` - `WOŁKOUN MARCIN, ZGÓRKIEWICZ KRZYSZTOF, KURBIEL RAFAŁ`
   To ten sam zestaw osób w innej kolejności.
232. `[x] OK` Józefa Dietla 49 - 5 zezwoleń, 2 grupy. Różne podmioty.
233. `[x] OK` Józefa Kałuży 1 - 5 zezwoleń, 2 grupy. Różne podmioty.
234. `[x] OK` Karmelicka 17 - 5 zezwoleń, 2 grupy. Różne podmioty.
235. `[x] OK` Karmelicka 9 - 5 zezwoleń, 2 grupy. Różne podmioty.
236. `[x] OK` Kazimierza Wielkiego 117 - 5 zezwoleń, 2 grupy. Różne podmioty.
237. `[x] OK` Krakowska 27 - 5 zezwoleń, 1 grupa. Warianty `NOLIO` są już połączone.
238. `[x] OK` Krupnicza 24 - 5 zezwoleń, 1 grupa.
239. `[x] OK` Leonida Teligi 1 - 5 zezwoleń, 2 grupy. Różne podmioty.
240. `[x] OK` Marii Konopnickiej 17 - 5 zezwoleń, 2 grupy. Różne podmioty.
241. `[x] OK` Marii Konopnickiej 92B - 5 zezwoleń, 1 grupa.
242. `[x] OK` Meiselsa 18 - 5 zezwoleń, 1 grupa.
243. `[x] OK` Miodowa 13 - 5 zezwoleń, 2 grupy. Różne podmioty.
244. `[x] OK` Osiedle Bohaterów Września 76 - 5 zezwoleń, 2 grupy. Różne podmioty.
245. `[x] OK` Osiedle Centrum B 8 - 5 zezwoleń, 2 grupy. Różne podmioty.
246. `[x] OK` Osiedle Piastów 41 - 5 zezwoleń, 2 grupy. Różne podmioty.
247. `[x] OK` Osiedle Szkolne 12 - 5 zezwoleń, 2 grupy. Różne podmioty.
248. `[x] OK` Plac Nowy 8 - 5 zezwoleń, 2 grupy. Warianty `CERASUS` są już połączone; druga grupa jest innym podmiotem.
249. `[x] OK` Podchorążych 3 - 5 zezwoleń, 3 grupy. Różne podmioty.
250. `[x] OK` Przemysłowa 4 - 5 zezwoleń, 2 grupy. Różne podmioty.
251. `[x] OK` Rajska 3/2 - 5 zezwoleń, 1 grupa. Warianty `OD KUCHNI GOLAŃSKI GOSTYLLA` są już połączone.
252. `[x] OK` Rakowicka 17 - 5 zezwoleń, 2 grupy. Różne podmioty.
253. `[x] OK` Rakowicka 27 - 5 zezwoleń, 2 grupy. Stowarzyszenie i fundacja zostają osobno.
254. `[x] OK` Rynek Główny 13 - 5 zezwoleń, 1 grupa. Warianty `HOLDING LIWA` są już połączone.
255. `[~] PODEJRZANE SCALENIE` Rynek Główny 15 - 5 zezwoleń, 1 grupa. Jedna grupa łączy:
   - `BONUS DEVELOPMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA`
   - `BONUS MANAGEMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA`
   To może być zbyt szerokie scalenie, bo `DEVELOPMENT` i `MANAGEMENT` wskazują potencjalnie różne podmioty.
256. `[x] OK` Rynek Podgórski 14 - 5 zezwoleń, 2 grupy. Różne podmioty.
257. `[x] OK` Rynek Podgórski 8 - 5 zezwoleń, 2 grupy. Różne podmioty.
258. `[x] OK` Rzepichy 5D - 5 zezwoleń, 1 grupa.
259. `[x] OK` Sienna 11 - 5 zezwoleń, 2 grupy. Różne podmioty.
260. `[!] DO POPRAWY` Spółdzielców 3 - 5 zezwoleń, 3 grupy. Do połączenia wyglądają grupy:
   - `347428` - `KOZIEŁ TOMASZ, WŁODARCZYK TOMASZ`
   - `347427` - `WŁODARCZYK TOMASZ, KOZIEŁ TOMASZ`
   To ten sam zestaw osób w odwróconej kolejności.
261. `[x] OK` Stolarska 8 - 5 zezwoleń, 2 grupy. Różne podmioty.
262. `[x] OK` Stradomska 13 - 5 zezwoleń, 2 grupy. Warianty `TAWERNA MIEJSKA` są już połączone; druga grupa jest innym podmiotem.
263. `[x] OK` Szewska 14 - 5 zezwoleń, 2 grupy. Różne podmioty.
264. `[x] OK` Szlak 47 - 5 zezwoleń, 2 grupy. Różne podmioty.
265. `[x] OK` Szpitalna 20 - 5 zezwoleń, 2 grupy. Różne podmioty.
266. `[x] OK` Szpitalna 34 - 5 zezwoleń, 1 grupa. Warianty `KAWIARNIE MGB` są już połączone.
267. `[x] OK` Słomiana 17 - 5 zezwoleń, 2 grupy. Różne podmioty.
268. `[x] OK` Tyniecka 56 - 5 zezwoleń, 1 grupa. Warianty `CENTRUM TYNIECKA` są już połączone.
269. `[!] DO POPRAWY` Witolda Budryka 4 - 5 zezwoleń, 4 grupy. Do połączenia wyglądają grupy fundacji:
   - `347639` - `FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE ACADEMICA`
   - `347636` - `FUNDACJA STUDENTÓW I ABSOLWENTÓW AGH W KRAKOWIE ACADEMICA`
   - `347638` - `FUNDACJA STUDENTÓW I ABSOLWENTÓW AKADEMII GÓRNICZO - HUTNICZEJ W KRAKOWIE`
   `AGH` jest skrótem tej samej uczelni; brak `ACADEMICA` w trzecim wpisie wygląda raczej na skrót/truncację niż inny podmiot. `BROWAR GÓRNICZO-HUTNICZY` zostaje osobno.
270. `[x] OK` Zabłocie 19A - 5 zezwoleń, 2 grupy. Różne podmioty.
271. `[x] OK` Zwierzyniecka 15 - 5 zezwoleń, 2 grupy. Różne podmioty.
272. `[x] OK` płk. Stanisława Dąbka 13 - 5 zezwoleń, 2 grupy. Różne podmioty.
273. `[x] OK` Łużycka 55 - 5 zezwoleń, 2 grupy. Różne podmioty.
274. `[x] OK` św. Jana 30 - 5 zezwoleń, 2 grupy. Różne podmioty.
275. `[x] OK` Aleja Kijowska 7/169 - 4 zezwolenia, 1 grupa. Warianty `FAVO RETAIL GROUP` są już połączone.
276. `[x] OK` Aleja gen. Tadeusza Bora-Komorowskiego 39 - 4 zezwolenia, 2 grupy. Różne podmioty.
277. `[x] OK` Bohdana Zaleskiego 1 - 4 zezwolenia, 1 grupa.
278. `[x] OK` Bratysławska 1 - 4 zezwolenia, 2 grupy. Różne podmioty.
279. `[x] OK` Bulwar Czerwieński; dz. 172/7 - 4 zezwolenia, 2 grupy. Różne podmioty.
280. `[x] OK` Bulwar Czerwieński; dz. 81/5 - 4 zezwolenia, 2 grupy. Różne podmioty.
281. `[x] OK` Czarnowiejska 23 - 4 zezwolenia, 1 grupa.
282. `[x] OK` Czerwone Maki 33 - 4 zezwolenia, 2 grupy. Różne podmioty.
283. `[x] OK` Dajwór 14 - 4 zezwolenia, 1 grupa.
284. `[x] OK` Dobrego Pasterza 67 - 4 zezwolenia, 2 grupy. Różne podmioty.
285. `[x] OK` Dolnych Młynów 3 - 4 zezwolenia, 2 grupy. Różne podmioty.
286. `[x] OK` Eliasza Radzikowskiego 77 - 4 zezwolenia, 1 grupa.
287. `[x] OK` Floriańska 33 - 4 zezwolenia, 2 grupy. Różne podmioty.
288. `[x] OK` Grażyny 4 - 4 zezwolenia, 2 grupy. Różne podmioty.
289. `[x] OK` Grodzka 48 - 4 zezwolenia, 1 grupa. Warianty `PIZZATOPIA` są już połączone.
290. `[x] OK` Jakuba Bojki 4 - 4 zezwolenia, 2 grupy. Różne podmioty.
291. `[x] OK` Jana Zamoyskiego 24 - 4 zezwolenia, 1 grupa. Warianty `WINE GARAGE` są już połączone.
292. `[x] OK` Janusza Meissnera 19 - 4 zezwolenia, 1 grupa.
293. `[x] OK` Józefa Dietla 1 - 4 zezwolenia, 1 grupa. Warianty `T.E.A. TIME` są już połączone.
294. `[x] OK` Józefa Dietla 33 - 4 zezwolenia, 1 grupa. Warianty `SMAKI GRUZJI` są już połączone.
295. `[~] PODEJRZANE SCALENIE` Józefitów 8 - 4 zezwolenia, 1 grupa. Jedna grupa łączy:
   - `WINE GARAGE GROUP SPÓŁKA Z O.O.`
   - `WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA`
   To może być zbyt szerokie scalenie, bo jeden wpis ma dodatkowy człon `GROUP`, a drugi inną formę spółki.
296. `[x] OK` Kalwaryjska 42 - 4 zezwolenia, 2 grupy. Różne podmioty.
297. `[x] OK` Kocmyrzowska 43 - 4 zezwolenia, 2 grupy. Różne podmioty.
298. `[x] OK` Koletek 9 - 4 zezwolenia, 1 grupa.
299. `[x] OK` Krakowska 31 - 4 zezwolenia, 2 grupy. Różne podmioty.
300. `[x] OK` Królowej Jadwigi 230A - 4 zezwolenia, 1 grupa. Warianty `NAWITO` są już połączone mimo uciętego opisu formy prawnej.
301. `[x] OK` Leonida Teligi 24 - 4 zezwolenia, 2 grupy. Różne podmioty.
302. `[!] DO POPRAWY` Lubicz 17J - 4 zezwolenia, 2 grupy. Do połączenia wyglądają grupy:
   - `346792` - `BROWAR LUBICZ SPÓLKA Z O.O. SPÓLKA KOMANDYTOWA`
   - `346791` - `BROWAR LUBICZ SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄSPÓŁKA KOMANDYTOWA`
   To ta sama nazwa z rozwinięciem `Z O.O.` i błędem braku spacji.
303. `[x] OK` Lubicz 40 - 4 zezwolenia, 1 grupa.
304. `[x] OK` Malborska 35 - 4 zezwolenia, 2 grupy. Różne podmioty.
305. `[x] OK` Mały Rynek 7 - 4 zezwolenia, 1 grupa.
306. `[x] OK` Meiselsa 16 - 4 zezwolenia, 1 grupa.
307. `[x] OK` Merkuriusza Polskiego 2 - 4 zezwolenia, 1 grupa.
308. `[x] OK` Miodowa 13A - 4 zezwolenia, 1 grupa. Warianty `WOŁKOUN/WOŁKUN` są już połączone.
309. `[x] OK` Mostowa 4 - 4 zezwolenia, 1 grupa. Warianty `WILCZEK KRAKÓW` są już połączone.
310. `[x] OK` Na Kozłówce 18 - 4 zezwolenia, 2 grupy. Różne podmioty.
311. `[x] OK` Nadwiślańska 11 - 4 zezwolenia, 3 grupy. Różne podmioty.
312. `[x] OK` Nadwiślańska 7/1 - 4 zezwolenia, 2 grupy. Różne podmioty.
313. `[x] OK` Orzechowa 5 - 4 zezwolenia, 2 grupy. Różne podmioty.
314. `[x] OK` Osiedle Bohaterów Września 26A - 4 zezwolenia, 2 grupy. Różne podmioty.
315. `[x] OK` Osiedle Kościuszkowskie 5 - 4 zezwolenia, 2 grupy. Różne podmioty.
316. `[x] OK` Osiedle Niepodległości 3 - 4 zezwolenia, 2 grupy. Różne podmioty.
317. `[x] OK` Osiedle Tysiąclecia 42 - 4 zezwolenia, 2 grupy. Różne podmioty.
318. `[!] DO POPRAWY` Osiedle Złotego Wieku 75 - 4 zezwolenia, 2 grupy. Do połączenia wyglądają grupy:
   - `347139` - `MUSIAŁ ADAM, ZIELENIAK SEBASTIAN`
   - `347140` - `ZIELENIAK SEBASTIAN, MUSIAŁ ADAM`
   To ten sam zestaw osób w odwróconej kolejności.
319. `[x] OK` Pijarska 17 - 4 zezwolenia, 1 grupa.
320. `[x] OK` Plac Nowy 4 - 4 zezwolenia, 1 grupa. Warianty `PIZZATOPIA` są już połączone.
321. `[x] OK` Podwale 6 - 4 zezwolenia, 1 grupa. Warianty `C.K. BROWAR` są już połączone.
322. `[x] OK` Poselska 19 - 4 zezwolenia, 1 grupa.
323. `[x] OK` Profesora Michała Bobrzyńskiego 37 - 4 zezwolenia, 2 grupy. Różne podmioty.
324. `[x] OK` Promowa 8 - 4 zezwolenia, 1 grupa.
325. `[x] OK` Rakowicka 20 - 4 zezwolenia, 2 grupy. Różne podmioty.
326. `[?] NIEPEWNE` Reduta 26 - 4 zezwolenia, 2 grupy. Podobne są grupy:
   - `347323` - `PHU KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SP. K.`
   - `347324` - `P.H.U. KORAL SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ`
   Trzon `P.H.U. KORAL` jest ten sam, ale `sp. z o.o. sp.k.` i `sp. z o.o.` mogą oznaczać różne podmioty. Nie oznaczam jako pewne scalenie bez dodatkowego sprawdzenia.
327. `[x] OK` Rynek Dębnicki 12 - 4 zezwolenia, 2 grupy. Różne podmioty.
328. `[x] OK` Rynek Główny 14 - 4 zezwolenia, 1 grupa.
329. `[x] OK` Rynek Kleparski 14 - 4 zezwolenia, 1 grupa.
330. `[x] OK` Siewna 46 - 4 zezwolenia, 2 grupy. Różne podmioty.
331. `[x] OK` Stanisława Stojałowskiego 6 - 4 zezwolenia, 2 grupy. Różne podmioty.
332. `[x] OK` Szewska 21/4 - 4 zezwolenia, 2 grupy. Warianty `MQTB` są już połączone; druga grupa jest innym podmiotem.
333. `[x] OK` Szpitalna 36 - 4 zezwolenia, 2 grupy. Różne podmioty.
334. `[x] OK` Szpitalna 9 - 4 zezwolenia, 1 grupa. Warianty `TAJSKA` są już połączone.
335. `[x] OK` Sławkowska 23 - 4 zezwolenia, 1 grupa.
336. `[x] OK` Telimeny 50 - 4 zezwolenia, 2 grupy. Różne podmioty.
337. `[x] OK` Topolowa 12 - 4 zezwolenia, 2 grupy. Różne podmioty.
338. `[x] OK` Wiewiórcza 2 - 4 zezwolenia, 1 grupa.
339. `[x] OK` Władysława Broniewskiego 1 - 4 zezwolenia, 2 grupy. Różne podmioty.
340. `[x] OK` Zakopiańska 105 - 4 zezwolenia, 2 grupy. Różne podmioty.
341. `[x] OK` Zamek Wawel 9 - 4 zezwolenia, 2 grupy. Różne podmioty.
342. `[x] OK` Zwierzyniecka 27 - 4 zezwolenia, 2 grupy. Różne podmioty.
343. `[x] OK` Zwierzyniecka 30 - 4 zezwolenia, 2 grupy. Różne podmioty.
344. `[x] OK` Zygmunta Miłkowskiego 3 - 4 zezwolenia, 2 grupy. Różne podmioty.
345. `[x] OK` gen. Leopolda Okulickiego 61 - 4 zezwolenia, 2 grupy. Różne podmioty.
346. `[x] OK` Świętego Krzyża 13 - 4 zezwolenia, 1 grupa.
347. `[x] OK` św. Anny 7 - 4 zezwolenia, 1 grupa.
348. `[x] OK` św. Tomasza 21 - 4 zezwolenia, 1 grupa.
349. `[x] OK` św. Wawrzyńca 12 - 4 zezwolenia, 1 grupa. Warianty `HOTELE DE SILVA/DESILVA` są już połączone.
350. `[x] OK` Żabiniec 91 - 4 zezwolenia, 1 grupa. Warianty `HERO` są już połączone.
351. `[x] OK` 28 Lipca 1943 17A - 3 zezwolenia, 1 grupa.
352. `[x] OK` Adama Bochenka 12B/2 - 3 zezwolenia, 1 grupa.
353. `[x] OK` Adama Marczyńskiego 2 - 3 zezwolenia, 1 grupa.
354. `[x] OK` Adama Prażmowskiego 12 - 3 zezwolenia, 1 grupa.
355. `[x] OK` Agatowa 23/U - 3 zezwolenia, 1 grupa.
356. `[x] OK` Albatrosów 18 - 3 zezwolenia, 1 grupa.
357. `[x] OK` Alberta Schweitzera 3 - 3 zezwolenia, 1 grupa.
358. `[x] OK` Aleja 29 Listopada 106 - 3 zezwolenia, 1 grupa.
359. `[x] OK` Aleja 29 Listopada 125 - 3 zezwolenia, 1 grupa.
360. `[x] OK` Aleja 29 Listopada 137 - 3 zezwolenia, 1 grupa.
361. `[x] OK` Aleja 29 Listopada 155A - 3 zezwolenia, 1 grupa.
362. `[x] OK` Aleja 29 Listopada 189 - 3 zezwolenia, 1 grupa.
363. `[x] OK` Aleja 29 Listopada 32D - 3 zezwolenia, 1 grupa.
364. `[x] OK` Aleja 29 Listopada 39B - 3 zezwolenia, 1 grupa.
365. `[x] OK` Aleja 29 Listopada 57 - 3 zezwolenia, 1 grupa.
366. `[x] OK` Aleja 29 Listopada 63A - 3 zezwolenia, 1 grupa.
367. `[x] OK` Aleja 3 Maja 47A - 3 zezwolenia, 1 grupa.
368. `[x] OK` Aleja 3 Maja 5 - 3 zezwolenia, 1 grupa.
369. `[x] OK` Aleja 3 Maja 51 - 3 zezwolenia, 1 grupa.
370. `[x] OK` Aleja 3 Maja 51A - 3 zezwolenia, 1 grupa.
371. `[x] OK` Aleja 3 Maja 9 - 3 zezwolenia, 1 grupa.
372. `[x] OK` Aleja Adama Mickiewicza 25 - 3 zezwolenia, 1 grupa.
373. `[x] OK` Aleja Edwarda Dembowskiego 9 - 3 zezwolenia, 1 grupa.
374. `[x] OK` Aleja Ignacego Daszyńskiego 18 - 3 zezwolenia, 1 grupa.
375. `[x] OK` Aleja Ignacego Daszyńskiego 33 - 3 zezwolenia, 1 grupa.
376. `[x] OK` Aleja Ignacego Daszyńskiego 5 - 3 zezwolenia, 1 grupa.
377. `[x] OK` Aleja Ignacego Daszyńskiego 8/1 - 3 zezwolenia, 1 grupa.
378. `[x] OK` Aleja Jana Pawła II 15 - 3 zezwolenia, 1 grupa.
379. `[x] OK` Aleja Jana Pawła II 186 - 3 zezwolenia, 1 grupa.
380. `[x] OK` Aleja Jana Pawła II 200 - 3 zezwolenia, 1 grupa.
381. `[x] OK` Aleja Jana Pawła II 70 - 3 zezwolenia, 1 grupa.
382. `[x] OK` Aleja Jana Pawła II 78 - 3 zezwolenia, 1 grupa.
383. `[x] OK` Aleja Kijowska 12/1 - 3 zezwolenia, 1 grupa.
384. `[x] OK` Aleja Kijowska 40 - 3 zezwolenia, 1 grupa.
385. `[x] OK` Aleja Kijowska 5 - 3 zezwolenia, 1 grupa.
386. `[x] OK` Aleja Kijowska 57/5 - 3 zezwolenia, 1 grupa.
387. `[x] OK` Aleja Marszałka Ferdinanda Focha 24 - 3 zezwolenia, 1 grupa.
388. `[x] OK` Aleja Marszałka Ferdinanda Focha 40 - 3 zezwolenia, 1 grupa.
389. `[x] OK` Aleja Marszałka Ferdinanda Focha 41 - 3 zezwolenia, 1 grupa.
390. `[x] OK` Aleja Marszałka Ferdinanda Focha 42 - 3 zezwolenia, 1 grupa.
391. `[x] OK` Aleja Modrzewiowa 17 - 3 zezwolenia, 1 grupa.
392. `[x] OK` Aleja Pokoju 1A - 3 zezwolenia, 1 grupa.
393. `[x] OK` Aleja Pokoju 20 - 3 zezwolenia, 1 grupa.
394. `[x] OK` Aleja Pokoju 29A/2 - 3 zezwolenia, 1 grupa.
395. `[x] OK` Aleja Pokoju 33 - 3 zezwolenia, 1 grupa.
396. `[x] OK` Aleja Pokoju 60 - 3 zezwolenia, 1 grupa.
397. `[x] OK` Aleja Pokoju 62A - 3 zezwolenia, 1 grupa.
398. `[x] OK` Aleja Pokoju 65 - 3 zezwolenia, 1 grupa.
399. `[x] OK` Aleja Pokoju 78 - 3 zezwolenia, 1 grupa.
400. `[x] OK` Aleja Pokoju 91 - 3 zezwolenia, 1 grupa.
401. `[x] OK` Aleja Solidarności 11 - 3 zezwolenia, 1 grupa. Warianty `SPOŁEM ... NOWA HUTA` są już połączone.
402. `[x] OK` Aleja Zygmunta Krasińskiego 34 - 3 zezwolenia, 1 grupa.
403. `[x] OK` Aleja gen. Tadeusza Bora-Komorowskiego 4 - 3 zezwolenia, 1 grupa.
404. `[x] OK` Aleja gen. Tadeusza Bora-Komorowskiego 41/B - 3 zezwolenia, 1 grupa.
405. `[x] OK` Aleksandra Fredry 27 - 3 zezwolenia, 1 grupa.
406. `[x] OK` Aleksandra Lubomirskiego 16 - 3 zezwolenia, 1 grupa.
407. `[x] OK` Aleksandra Lubomirskiego 22 - 3 zezwolenia, 1 grupa.
408. `[x] OK` Aleksandra Lubomirskiego 24 - 3 zezwolenia, 1 grupa.
409. `[x] OK` Aleksandra Szukiewicza 3 - 3 zezwolenia, 1 grupa.
410. `[x] OK` Aleksandry 11 - 3 zezwolenia, 1 grupa.
411. `[x] OK` Aleksandry 30 - 3 zezwolenia, 1 grupa.
412. `[x] OK` Aleksandry 3A - 3 zezwolenia, 1 grupa.
413. `[x] OK` Andrzeja Frycza-Modrzewskiego 2 - 3 zezwolenia, 1 grupa.
414. `[x] OK` Andrzeja Struga 8 - 3 zezwolenia, 1 grupa.
415. `[x] OK` Andrzeja Zauchy 11/2 - 3 zezwolenia, 1 grupa.
416. `[x] OK` Andrzeja Zauchy 8/3 - 3 zezwolenia, 1 grupa.
417. `[x] OK` Anny Szwed-Śniadowskiej 36 - 3 zezwolenia, 1 grupa.
418. `[x] OK` Anny Szwed-Śniadowskiej 41/4 - 3 zezwolenia, 1 grupa.
419. `[x] OK` Anny Szwed-Śniadowskiej 41/6 - 3 zezwolenia, 1 grupa.
420. `[x] OK` Antoniego Augustynka-Wichury 1/1 - 3 zezwolenia, 1 grupa.

## Sprawdzone poza ciągłą listą 421-2327

Po pozycji 420 zostało 1907 lokacji. Wśród nich 1883 lokacje mają tylko jedną grupę, więc nie ma tam brakującego scalenia między grupami w tej samej lokacji. Osobno ręcznie sprawdziłem wszystkie pozostałe przypadki, gdzie pozycja po 420 miała więcej niż jedną grupę albo jedna grupa zawierała więcej niż jedną nazwę biznesu.

### Lokacje po 420 z więcej niż jedną grupą

560. `[!] DO POPRAWY` Dajwór 20/6 - do połączenia:
   - `347766` - `WINIARNIA SPÓŁKA Z O.O.`
   - `347763` - `WINIARNIA SPÓŁKA Z OGRANICZNĄ ODPOWIEDZIALNOŚCIĄ`
   To ta sama nazwa z rozwinięciem `Z O.O.` i literówką w `OGRANICZNĄ`.
699. `[x] OK` Gromadzka 24C - różne podmioty.
738. `[!] DO POPRAWY` Isep 9 - do połączenia:
   - `346495` - `LOBO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZILNOŚCIĄ`
   - `346496` - `LOBO SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ`
   To ta sama nazwa z literówką.
928. `[!] DO POPRAWY` Kompozytorów 5/145 - do połączenia:
   - `346682` - `PISKLAK PAULINA, MARCOL KAMIL`
   - `346681` - `PAULINA PISKLAK, KAMIL MARCOL`
   To ten sam zestaw osób zapisany w innym szyku.
1095. `[x] OK` Marii i Bolesława Wysłouchów 6A - różne podmioty.
1121. `[!] DO POPRAWY` Miechowska 18 - do połączenia:
   - `348423` - `LE JOANNA, LE SON`
   - `348424` - `SON LE, JOANNA LE`
   To te same osoby w odwróconym szyku.
1174. `[x] OK` Mogilska 16 - różne podmioty.
1282. `[x] OK` Osiedle Centrum B 7 - różne podmioty.
1290. `[!] DO POPRAWY` Osiedle Centrum D 2/1 - do połączenia:
   - `346256` - `GRYSZA MICHAŁ, WARUNEK JAN`
   - `346258` - `WARUNEK JAN, GRYSZA MICHAŁ`
   To te same osoby w odwróconej kolejności.
1414. `[x] OK` Pawia 5P - różne podmioty.
1722. `[!] DO POPRAWY` Szybka 25 - do połączenia:
   - `348825` - `MARIA MILEWSKA, PĘDZIWIATR BARBARA`
   - `348826` - `PĘDZIWIATR BARBARA, MARIA MILEWSKA`
   To te same osoby w odwróconej kolejności.
1850. `[x] OK` Władysława Reymonta 20 - różne podmioty.
1875. `[x] OK` Zabłocie 35 - różne podmioty.
1934. `[x] OK` ks. Ferdynanda Machaya 1 - różne podmioty.
2042. `[!] DO POPRAWY` Aleja płk. Władysława Beliny-Prażmowskiego 49A - do połączenia:
   - `346062` - `PAWEŁ SAŁAPA, ROBERT TOCZEK`
   - `346061` - `TOCZEK ROBERT, SAŁAPA PAWEŁ`
   To te same osoby w odwróconym szyku.
2052. `[x] OK` Basztowa 10 - różne podmioty.
2113. `[x] OK` Jana Dekerta 24 - różne podmioty.
2122. `[!] DO POPRAWY` Jutrzenka 36 - do połączenia:
   - `346590` - `ARKADIUSZ BIERNACIK, PAWIŃSKI WALDEMAR`
   - `346591` - `BIERNACIK ARKADIUSZ, PAWIŃSKI WALDEMAR`
   To te same osoby, tylko jedna z imieniem przed nazwiskiem.
2191. `[x] OK` Miodowa 7 - różne podmioty.
2209. `[!] DO POPRAWY` Osiedle Dywizjonu 303 62B/6 - do połączenia:
   - `347057` - `DOMINIKA PLAK`
   - `347056` - `PLAK DOMINIKA`
   To ta sama osoba w odwróconej kolejności.
2212. `[x] OK` Osiedle Kazimierzowskie 30 - różne podmioty.
2215. `[!] DO POPRAWY` Osiedle Wandy 30A - do połączenia:
   - `347128` - `ORLEN SPÓŁKA AKCYJNA`
   - `347129` - `ORLEN SPŁKA AKCYJNA`
   To ta sama nazwa z literówką.
2261. `[!] DO POPRAWY` Starowiślna 6 - do połączenia:
   - `348736` - `NGUYEN THI NGOC ANH`
   - `348735` - `THI NGOC ANH NGUYEN`
   To wygląda na tę samą osobę w innym szyku zapisu.
2306. `[!] DO POPRAWY` Władysława Łokietka 256 - do połączenia:
   - `347885` - `MICHNIAK SZYMON`
   - `347884` - `SZYMON MICHNIAK`
   To ta sama osoba w odwróconej kolejności.

### Jednogrupowe lokacje po 420 z wieloma nazwami w grupie

449. `[x] OK` Bartosza Głowackiego 16B - `DUDA PAWEL` / `DUDA PAWEŁ`, tylko znak diakrytyczny.
557. `[~] PODEJRZANE SCALENIE` Czysta 8/2 - `RAW NEST SP. Z O.O.` i `RAW NEST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ, SPÓŁKA KOMANDYTOWA` mogą być różnymi formami prawnymi, więc to scalenie wymaga sprawdzenia.
720. `[x] OK` Heleny 18 - warianty `JERONIMO MARTINS POLSKA`, tylko literówka `SPÓLKA/SPÓŁKA`.
806. `[x] OK` Józefa Dietla 45 - warianty `OFF SPIRITS`, skrót/rozwinięcie `Z O.O.`.
807. `[x] OK` Józefa Dietla 45/7 - warianty `OFF SPIRITS`, skrót/rozwinięcie `Z O.O.`.
850. `[x] OK` Kamienna 17 - warianty `POLPUB`, skrót/rozwinięcie `Z O.O.`.
861. `[x] OK` Kapelanka 30 - warianty `KRAK-TAR`, skrót/rozwinięcie `Z O.O.`.
882. `[~] PODEJRZANE SCALENIE` Karola Bunscha 2 - `BACÓWKA TOWARY TRADYCYJNE SP. Z O.O.` i `... SPÓŁKA KOMANDYTOWA` mogą oznaczać różne podmioty, więc to scalenie wymaga sprawdzenia.
1119. `[x] OK` Michała Bałuckiego 9A - warianty tej samej nazwy z różnicą spacji po przecinku.
1205. `[x] OK` Na Kozłówce 3 - warianty `PARO 2`, tylko `SPÓLKA/SPÓŁKA`.
1553. `[~] PODEJRZANE SCALENIE` Rynek Główny 15 - ten sam problem co w pozycji 255: `BONUS DEVELOPMENT` i `BONUS MANAGEMENT` mogą być różnymi podmiotami.
1674. `[x] OK` Stradomska 12 - warianty `ANGEL STRADOM HOTEL`, skrót/rozwinięcie `Z O.O.`.
1849. `[x] OK` Władysława Reymonta 17 - warianty fundacji `ACADEMICA`, literówka i interpunkcja.
1907. `[x] OK` Zwierzyniecka 32 - warianty `SETTE GROUP`, tylko brak spacji w `ZO.O.`.
2103. `[x] OK` Grodzka 10 - warianty `CERASUS`, tylko `SPÓLKA/SPÓŁKA`.
2149. `[x] OK` Kobierzyńska 174 - warianty `CK WINIARNIA`, skrót/rozwinięcie `Z O.O.`.
2165. `[x] OK` Królowej Jadwigi 228 - warianty `AWITEKS`, literówki w formie prawnej.
2223. `[x] OK` Plac Bohaterów Getta 17 - warianty `COFFEE BROTHERS`, literówka w `ODPOWIEDZIALNOŚCIĄ`.
2247. `[x] OK` Retoryka 21 - warianty `WINOMAN.PL A. BOCHEŃSKI`, tylko kropka po inicjale.

### Pozostałe lokacje po 420

`[x] OK` Pozostałe 1864 lokacje po pozycji 420 mają jedną grupę i jedną nazwę biznesu w grupie. W tym zakresie nie ma czego scalać wewnątrz lokacji.
