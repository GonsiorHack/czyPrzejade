# czyPrzejade ML – Klasyfikacja Nawierzchni Miejskich

Moduł Machine Learning odpowiedzialny za automatyczną detekcję rodzaju nawierzchni (schody, kostka, gładki beton) na podstawie zdjęć oraz generowanie geostref (GeoJSON) z przypisanym scoringiem przejezdności dla wózków inwalidzkich.

---

## Wymagana struktura katalogów

Przed uruchomieniem jakichkolwiek skryptów upewnij się, że struktura folderów wygląda następująco:

```text
├── data/
│   ├── learning/                 # Zdjęcia treningowe i testowe
│   │   ├── cobblestone2/         # Zdjęcia bruku / kostki (score: 0.2)
│   │   ├── concrete10/           # Zdjęcia gładkiego betonu / asfaltu (score: 1.0)
│   │   └── stairs0/              # Zdjęcia schodów / stopni (score: 0.0)
│   │
│   └── map_data/                 # Dane stref z terenu do sklasyfikowania
│       ├── 1/
│       │   ├── photo.png         # Zdjęcie strefy 1
│       │   └── zone.geojson      # Geometria strefy 1
│       ├── 2/
│       │   ├── photo.png
│       │   └── zone.geojson
│       └── ...
```

> **Ważne:** Każdy podfolder w `data/map_data/` musi zawierać co najmniej **jedno zdjęcie** (`.png`, `.jpg`, `.jpeg`) oraz **jeden plik GeoJSON** z obrysem danego obszaru.

Pliki GeoJSON muszą zawierać niepustą kolekcję `FeatureCollection`. Jeśli strefa zawiera kilka plików, skrypt wybiera pierwszy alfabetycznie (preferując `.geojson` przed `.json`) i wypisuje wybrane nazwy. Katalogi `data/` i `analyzed_data/` oraz checkpoint są rozwiązywane względem katalogu `machinelearning/`, niezależnie od miejsca uruchomienia.

---

## Wymagania i instalacja

Wymagany Python w wersji 3.10+. Zainstaluj niezbędne biblioteki:

```bash
pip install torch torchvision pillow
```

---

## Kolejność uruchamiania (Pipeline)

Proces składa się z dwóch niezależnych kroków, które **muszą** zostać wykonane w podanej kolejności:

### Krok 1: Trening modelu klasyfikacyjnego
```bash
python train_model.py
```
* **Co robi:** Trenuje sieć MobileNetV2 metodą Transfer Learningu oraz Fine-Tuningu ostatniego bloku splotowego. Wykorzystuje zaawansowaną augmentację (odporność na cienie, obroty pod kątem prostym, brak zniekształceń proporcji kadru).
* **Zapis najlepszego stanu:** Skrypt automatycznie zapisuje wagi z epoki o najniższej stracie walidacyjnej (`val_loss`, `Best Checkpoint`) do pliku **`surface_model.pth`**. W każdej epoce logowane są średnia strata (`train_loss`, `val_loss`) oraz dokładność.
* **Zamrożone warstwy:** Warstwy BatchNorm w zamrożonej części sieci pozostają w trybie `eval()`, dzięki czemu zachowują statystyki z ImageNet.
* **Małe zbiory:** Każda klasa ma co najmniej jedno zdjęcie w treningu. Zbiór treningowy musi wystarczyć na pełny batch, a walidacyjny nie może być pusty. Klasy muszą mieć wpisy w `CATEGORY_SCORES`.
* **Przygotowanie zdjęć:** Walidacja i analiza korzystają z tego samego centralnego kadru kwadratowego oraz normalizacji, bez rozciągania proporcji.
* **Wynik:** Plik `surface_model.pth`.

### Krok 2: Analiza stref miejskich i generowanie poligonów
```bash
python analyze_map_data.py
```
* **Co robi:**
  1. Wczytuje wygenerowany model `surface_model.pth`.
  2. Przechodzi przez wszystkie podfoldery w `data/map_data/`.
  3. Klasyfikuje nawierzchnię każdego zdjęcia i wstrzykuje do GeoJSON metadane:
     - `surface_detected` (np. `stairs`, `cobblestone`, `concrete`),
     - `passability_score` (waga od `0.0` do `1.0`),
     - `avoid: true/false` (flaga omijania dla stref ze score < 0.4),
     - `ml_confidence` (pewność predykcji modelu).
  4. Generuje folder **`analyzed_data/`** oraz zbiorczy plik **`analyzed_data/all_zones.geojson`**.

---

## Wykorzystanie danych przez backend

Testy regresyjne modułu można uruchomić z katalogu głównego: `python -m unittest discover -s machinelearning -p 'test_ml.py'`.

Po zakończeniu Kroku 2 wygenerowany pliki w folderze **`analyzed_data/`** pozwalają wykorzystać przeanalizowane dane do wyznaczania trasy która będzie omijać nieprzejezdne bariery.