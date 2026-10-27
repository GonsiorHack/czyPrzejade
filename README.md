# czyPrzejade - Miasta Bez Barier

> Skalowalna platforma miejskiej mikromobilności niwelująca bariery przestrzenne dla osób z ograniczoną mobilnością: użytkowników wózków manualnych i elektrycznych, seniorów oraz opiekunów z wózkami dziecięcymi. System łączy analizę wizyjną Computer Vision z dynamicznym routingiem omijającym przeszkody architektoniczne.

<p align="center">
  Aplikacja mobilna (Flutter) na iOS i Android - instrukcja uruchomienia w <a href="mobile/README.md">mobile/README.md</a>.
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Status-Seeking_Partners_and_Investors-1a1b26?style=for-the-badge&logoColor=white&labelColor=9ece6a" alt="Status" />
</p>

<p align="center">
  <a href="https://skillicons.dev" target="_blank">
    <img src="https://skillicons.dev/icons?i=py,fastapi,pytorch,flutter,dart" alt="Tech Stack Icons" />
  </a>
</p>

---

## Czym jest czyPrzejade?

to uniwersalny system nawigacyjny nowej generacji. Standardowe aplikacje mapowe skupiają się wyłącznie na kryterium najkrótszego dystansu lub czasu, ignorując ukształtowanie i jakość nawierzchni. 

Wprowadzamy silnik routingu wielokryterialnego, który ocenia parametry przejezdności chodników, wykrywa przeszkody terenowe i wyznacza bezpieczne korytarze komunikacyjne bez barier architektonicznych. Projekt został zaprojektowany jako uniwersalny silnik, gotowy do skalowania na dowolną aglomerację miejską.

---

## Problem: Ślepota Aplikacji Nawigacyjnych na Dostępność

Powszechnie stosowane nawigacje piesze (Google Maps, Apple Maps) opierają się na założeniu, że każdy użytkownik dysponuje pełną sprawnością ruchową:

* **Nierówne nawierzchnie**: Bruk, uszkodzona kostka, żwir, piasek czy pęknięte płyty chodnikowe generują opór toczenia uniemożliwiający przejazd wózkiem.

* **Bariery pionowe**: Schody bez podjazdów, uskoki terenu, brak wind i krawężniki powyżej kilku centrymetrów stanowią przeszkody bezwzględne, zmuszające użytkowników do zawracania i nadrabiania trasy.

* **Brak danych mikrografowych**: Otwarte bazy mapowe rzadko przechowują ustrukturyzowane informacje o fakturze chodników, szerokości przewężeń czy nachyleniu terenu.

* **Problem uniwersalny**: Wykluczenie komunikacyjne dotyka pieszych w każdym mieście ze zwartą zabudową, zabytkową starówką czy intensywnymi pracami remontowymi.

* **Potrzeba zależności**: Brak rzetelnej informacji o trasie wywołuje lęk przed wyjściem w przestrzeń publiczną i ogranicza samodzielność w załatwianiu codziennych spraw.
</p>

## Rozwiązanie: Nawigacja Uwzględniająca Strukturę Podłoża

Projekt łączy detekcję wizualną, routing przestrzenny:

1. **Wizualna Klasyfikacja Nawierzchni (Computer Vision)**: Model MobileNetV2 analizuje fotografie przestrzeni miejskiej i kategoryzuje nawierzchnię (schody, nierówny bruk, gładki asfalt/beton), przypisując współczynnik przejezdności.


2. **Dynamiczny Dual-Routing**: Silnik generuje równolegle dwie ścieżki:
   * *Trasę standardową* - klasyczną, najkrótszą drogę pieszą,
   * *Trasę bez barier* - wariant omijający strefy zidentyfikowanych przeszkód architektonicznych.

 
   
3. **Transparentne Porównanie Wariantów**: Użytkownik ma pełen wgląd w różnicę odległości, szacowanego czasu i profilu nawierzchni między obiema trasami.



4. **Katalog Zweryfikowanych Miejsc Dostępnych**: Zintegrowana baza lokali usługowych, gastronomicznych i instytucji publicznych spełniających rygorystyczne normy dostępności architektonicznej.



5. **Moduł Zgłoszeń Terenowych**: Użytkownicy mogą przesyłać zdjęcia napotkanych barier tymczasowych (remonty, ubytki), zasilając bazę danych w modelu crowdsourcingowym, wspierając technologię Computer Vision.

---

## Geneza: Droga ku Startupowi

Koncepcja oraz działający prototyp powstały w zaledwie **24 godziny podczas HackYeah** - największego stacjonarnego hackathonu w Europie. Startując jako 3-osobowy zespół, zmierzyliśmy się z wyzwaniem z obszaru miejskiej dostępności i inkluzywności.

Zaprojektowane rozwiązanie spotkało się z bardzo pozytywnym odbiorem sędziów - zakończyliśmy rywalizację z notą powyżej średniej wszystkich zespołów hackathonu, zdobywając wysokie oceny w kryteriach użyteczności, UX oraz bezpośredniej odpowiedzi na realny problem społeczny. 

Mimo że nie weszliśmy do ścisłej piątki finalistów kategorii, walidacja pomysłu i działający prototyp potwierdziły nasze przypuszczenia, ogromny potencjał tego projektu. 

**Nie zamykamy projektu w szufladzie - przekształcamy czyPrzejade w pełnoprawny startup. Aktywnie poszukujemy inwestorów wczesnego etapu, sponsorów infrastruktury chmurowej, partnerów samorządowych oraz podmiotów zainteresowanych zakupem lub komercyjnym wdrożeniem technologii.**

---

## Wyzwania Wdrożeniowe (R&D)

Otwarcie podchodzimy do obecnych ograniczeń prototypu i realizujemy plan ich eliminacji:

### 1. Detekcja W Osi Pionowej (Drzewa, Daszki, Rusztowania)
* **Wąskie gardło**: Aktualny model analizuje wyłącznie płaszczyznę podłoża (fakturę nawierzchni) z satelit. Algorytm nie uwzględnia przeszkód zakrytych przez przeszkody w tej płaszczyźnie, blokujących widok na nawierzchnię: koron drzew, dachów, markiz sklepowych czy rusztowań.

* **Rozwiązanie B+R**: Projektujemy **osobny model AI (Computer Vision 3D / Foliage & Overhead Obstacle Segmentation)** dedykowany detekcji przeszkód kubaturowych w pionowym obrysie korytarza pieszego, który pozwoli weryfikować skrajnię drogową i wprowadzać strefy ograniczeń wysokościowych do grafu.

### 2. Ograniczenia Modułu Mapowego & Dostępność Wersji Live Demo
* **Architektura prototypu**: Choć cała logika aplikacji, algorytmy scoringu i API w FastAPI są autorskie, element silnika mapowego bazuje obecnie na darmowych, zewnętrznych endpointach z restrykcyjnym limitem do około 2000 zapytań na dobę.

* **Dostępność Live Demo**: Aby uniknąć wyczerpania darmowych puli zapytań poza testami, moduł mapowo-routingowy jest usypiany i wyłączany w okresach bezczynności. Z tego względu publiczna instancja demonstracyjna może okresowo zgłaszać przerwę w działaniu kalkulacji tras.

* **Kierunek długofalowy**: Przygotowujemy wdrożenie **własnego, dedykowanego serwera klastrowego do routingu (Self-hosted Valhalla / OSRM)** z dedykowanymi profilami przejezdności. Zapewni to niezależność od zewnętrznych limitów, czas odpowiedzi poniżej 50 ms oraz bezproblemową skalowalność na dowolny region świata.

---

## Stos Technologiczny

| Warstwa | Technologie |
|---|---|
| Aplikacja mobilna (`mobile/`) | Flutter 3.x / Dart 3.x (iOS, Android), `provider` (stan), `flutter_map` + `latlong2` (mapa OSM), `geolocator`, `http`, `image_picker`, `video_player`, `flutter_svg`, `shared_preferences` |
| Backend (`backend/`) | Python, FastAPI, Uvicorn, OpenRouteService (routing i geokodowanie) |
| Uczenie maszynowe (`machinelearning/`) | Python, PyTorch, MobileNetV2 (klasyfikacja nawierzchni) |
| Dane | OpenStreetMap, GeoJSON |
| Narzędzia | Android Emulator + scrcpy (`dev-android.sh`), flutter analyze |

### Szybki start

```bash
# backend
cd backend && python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000

# aplikacja (emulator Androida)
cd mobile && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Dodatkowo `./dev-android.sh` uruchamia backend, emulator i aplikację jedną komendą (`./dev-android.sh stop` zatrzymuje wszystko). Szczegóły: [mobile/README.md](mobile/README.md), [backend/README_BACKEND.md](backend/README_BACKEND.md).

---

## Architektura Systemu

```
┌────────────────────────────────────────────────────────┐
│         Klient mobilny (Flutter + flutter_map)         │
│        Interfejs mobilny, porównanie tras, UX          │
└───────────────────────────┬────────────────────────────┘
                            │ REST / GeoJSON
┌───────────────────────────▼────────────────────────────┐
│                Core API (FastAPI Python)               │
│        Walidacja, routing hybrydowy, agregacja         │
└─────────────┬────────────────────────────┬─────────────┘
              │                            │
┌─────────────▼──────────────┐ ┌───────────▼─────────────┐
│    Silnik Trasowania GIS   │ │      Computer Vision    │
│ - Wariant Standardowy      │ │ - MobileNetV2 (Podłoże) │
│ - Wariant Bez Barier       │ │ - Moduł R&D (Skrajnia)  │
│ - Docelowo: Własny klaster │ │ - GeoJSON Polygon Export│
└────────────────────────────┘ └─────────────────────────┘
```

---

## Potencjał Rynkowy, Finansowanie & Skalowalność

Projekt nie jest ograniczony geograficznie - dzięki integracji z danymi OpenStreetMap może zostać uruchomiony w dowolnej aglomeracji miejskiej w Polsce, Europie i na świecie.

### 1. Ścieżki Finansowania Publicznego i Grantowego
Model rozwoju aplikacji idealnie wpisuje się w kluczowe programy wsparcia innowacji społecznych i infrastrukturalnych:
* **PFRON (Państwowy Fundusz Rehabilitacji Osób Niepełnosprawnych)**: Granty na technologie asystujące, cyfrową dostępność oraz niwelowanie barier w komunikowaniu się.
* **Program Dostępność Plus (MFiPR)**: Dofinansowania dla innowacji samorządowych i startupowych w obszarach mobilności miejskiej i przestrzeni bez barier.
* **FENG (Fundusze Europejskie dla Nowoczesnej Gospodarki) / Ścieżka SMART (NCBR/PARP)**: Finansowanie fazy badawczo-rozwojowej (B+R) dedykowanej autorskim modelom AI analizującym przestrzeń miejską.
* **Programy GovTech i Smart City**: Wdrożenia pilotażowe i licencjonowanie narzędzi analitycznych wspierających samorządy w audytach dostępności i planowaniu remontów.
* **Horizon Europe / EIC Accelerator**: Europejskie dofinansowania innowacji z zakresu inkluzywności społecznej i zrównoważonego transportu.

### 2. Etyczna Monetyzacja B2C/B2B: Katalog Miejsc (Natywny Model CSR)
Tradycyjna, inwazyjna reklama banerowa obniża czytelność nawigacji. Zamiast niej wdrażamy partnerski model promocji w sekcji „Miejsca Dostępne”:
* **Pozytywny wizerunek CSR dla biznesu**: Hotele, restauracje, kawiarnie, przychodnie i instytucje kultury mogą wykupić zweryfikowany profil partnerski, prezentując swoje udogodnienia (podjazdy, windy, drzwi automatyczne, toalety przystosowane dla OzN).
* **Nienachalna wartość dla użytkownika**: Rekomendacja w aplikacji nie jest spamem - stanowi sprawdzoną, bezpośrednią informację o lokalu, do którego użytkownik dotrze bez ryzyka zderzenia z barierą architektoniczną.
* **Praktyczna korzyść**: Użytkownik zyskuje pewność bezstresowej wizyty, a lokal pozyskuje lojalnych klientów, promując otwartość i społeczną odpowiedzialność.

### 3. Komercjalizacja Danych B2B (Data-as-a-Service)
* Sprzedaż zagregowanych raportów o wąskich gardłach infrastrukturalnych biurom planowania przestrzennego i jednostkom miejskim.
* Udostępnianie dedykowanego API trasowania dla zewnętrznych systemów zarządzania flotą mikromobilności, portali turystycznych oraz aplikacji hotelowych.

---

---

## Społeczność i Koordynacja

Rozwijamy projekt w modelu otwartego dialogu ze środowiskiem akademickim, deweloperami oraz pasjonatami technologii asystujących (Tech for Good). Serwer Discord stanowi przestrzeń roboczą dla bieżącej koordynacji technicznej i wymiany wiedzy:
<br>
<p align="center">
  <a href="https://discord.gg/AFcjXn9h" target="_blank">
    <img src="https://img.shields.io/badge/Discord-Dołącz_do_Społeczności-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord czyPrzejade" />
  </a>
</p>

---

## 👥 Poznaj Nasz [Team](https://github.com/GonsiorHack)

<p align="right">
  <img src="https://skillicons.dev/icons?i=dart,flutter,figma" height="40" style="vertical-align: middle;" alt="Dart, Flutter, Figma" />
  &nbsp;&nbsp;
  <a href="https://github.com/sh3kda" target="_blank"><strong>@sh3kda</strong></a>
  &nbsp;&nbsp;
  <a href="https://github.com/sh3kda" target="_blank">
    <img src="https://github.com/sh3kda.png" width="56" height="56" style="border-radius: 50%; vertical-align: middle;" alt="sh3kda" />
  </a>
  <br />
  <em>Mobile (Flutter) • Software Architecture • Deployment</em>↲&nbsp;&nbsp;
</p>

---

<p align="right">
  <img src="https://skillicons.dev/icons?i=py,pytorch,fastapi" height="40" style="vertical-align: middle;" alt="Python, PyTorch, FastAPI" />
  &nbsp;&nbsp;
  <a href="https://github.com/GaskaPiotr" target="_blank"><strong>@GaskaPiotr</strong></a>
  &nbsp;&nbsp;
  <a href="https://github.com/GaskaPiotr" target="_blank">
    <img src="https://github.com/GaskaPiotr.png" width="56" height="56" style="border-radius: 50%; vertical-align: middle;" alt="GaskaPiotr" />
  </a>
  <br />
  <em>Geospatial AI • Backend Engineering • Routing Algorithms</em>↲&nbsp;&nbsp;
</p>

---

<p align="right">
  <img src="https://skillicons.dev/icons?i=py,postman" height="40" style="vertical-align: middle;" alt="Python, Postman, Git" />
  &nbsp;&nbsp;
  <a href="https://github.com/Antoine052" target="_blank"><strong>@Antoine052</strong></a>
  &nbsp;&nbsp;
  <a href="https://github.com/Antoine052" target="_blank">
    <img src="https://github.com/Antoine052.png" width="56" height="56" style="border-radius: 50%; vertical-align: middle;" alt="Antoine052" />
  </a>
  <br />
  <em>Spatial Data Science • GIS Engineering • Data Sourcing</em> ↲&nbsp;&nbsp;
</p>
