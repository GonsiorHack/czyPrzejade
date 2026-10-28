# czyPrzejade Backend – Routing API

Backend aplikacji oparty na frameworku **FastAPI** oraz silniku **OpenRouteService (ORS)**. Odpowiada za dynamiczne kalkulowanie tras dla osób z ograniczeniami ruchowymi, omijanie barier architektonicznych (wykrytych przez model ML) oraz serwowanie geometrii stref dla aplikacji mobilnej (Flutter).

---

## UWAGA: Zależność od modułu Machine Learning!

Backend pobiera geometrię barier bezpośrednio z plików wygenerowanych przez moduł sztucznej inteligencji.

**Zanim uruchomisz serwer backendowy, upewnij się, że zapoznałeś/aś się z README.md w folderze machinelearning oraz wykonałeś/aś odpowiednie kroki.**
1. W module ML został uruchomiony trening (`train_model.py`).
2. Został uruchomiony skrypt analityczny (`analyze_map_data.py`).
3. Folder **`analyzed_data/`** (zawierający plik `all_zones.geojson` oraz podfoldery z wynikami) wygenerował się prawidłowo

```text
machinelearning/
├── analyzed_data/
│   └── all_zones.geojson    # WYMAGANE: Wynik działania pipeline'u ML!
├── data/         # Opcjonalne ręczne strefy zamknięte
├── surface_model.pth
└── train_model.py
```

*Bez folderu `analyzed_data` backend nie będzie wiedział, które obszary omijać i trasy bezpieczne nie zostaną poprawnie wyznaczone!*

---

## Konfiguracja klucza OpenRouteService (.env)

Aplikacja korzysta z silnika routingu OpenRouteService. Aby uzyskać bezpłatny klucz API:

1. Wejdź na stronę: **[https://openrouteservice.org/dev/#/signup](https://openrouteservice.org/dev/#/signup)** i załóż darmowe konto.
2. Po zalogowaniu przejdź do zakładki **Key**: [https://openrouteservice.org/dev/#/home](https://openrouteservice.org/dev/#/home)
3. Kliknij **Request a Token**, wybierz typ tokena: **Standard (Free)**, wpisz nazwę (np. `WheelRoute`) i zatwierdź.
4. Skopiuj wygenerowany ciąg znaków (klucz API).
5. W katalogu `backend/` utwórz plik o nazwie **`.env`** i wklej do niego swój klucz:

```env
5b3ce3597851110001cf6248...
```

---

## Instalacja zależności

Wymagany Python 3.10+. Zainstaluj pakiety:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
```

---

## 🏃 Uruchomienie lokalne

Uruchom serwer developerski poleceniem:

```bash
.venv/bin/uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Po uruchomieniu:
* **Interaktywna dokumentacja Swagger UI:** http://localhost:8000/docs

---

## Udostępnianie przez ngrok (wyłącznie kontrolowane demo mapy)

Aby aplikacja mobilna (Flutter) mogła komunikować się z lokalnym backendem przez Internet:

1. Uruchom tunel na porcie 8000:
```bash
ngrok http 8000
```
2. Skopiuj wygenerowany adres HTTPS (np. `[https://xxxx-xxxx.ngrok-free.dev](https://xxxx-xxxx.ngrok-free.dev)`).
3. Przekaż ten adres aplikacji: `flutter run --dart-define=API_BASE_URL=https://xxxx.ngrok-free.dev`
   (zob. [README aplikacji mobilnej](../mobile/README.md)).
