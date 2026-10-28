# czyPrzejade - aplikacja mobilna (Flutter)

Natywna aplikacja iOS i Android. Mapa: `flutter_map` + kafelki OpenStreetMap (HOT), bez klucza API.
Trasy i geokodowanie pochodzą z backendu FastAPI (`../backend`).

## Uruchomienie

```bash
cd mobile
flutter pub get
# Emulator Androida: host maszyny to 10.0.2.2
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
# Symulator iOS
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Bez `API_BASE_URL` aplikacja działa w trybie demonstracyjnym (zapisane trasy z `assets/data/demoRoutes.json`,
geokodowanie niedostępne). Backend uruchamia się zgodnie z `../backend/README_BACKEND.md`.

## Sterowanie mapą

- dotknięcie mapy ustawia punkt A, potem B; dotknięcie nieaktywnej trasy wybiera ją,
- długie przytrzymanie przesuwa najbliższy znacznik,
- przycisk lokalizacji centruje mapę na GPS,
- "Rozpocznij nawigację" śledzi pozycję i prowadzi kamerę.

## Zasoby

`assets/media/intro.mp4` (animacja wejścia), `assets/branding/*.svg` (logo), `assets/data/demoRoutes.json`.
Zarchiwizowane, niezarejestrowane grafiki i animacje: `assets/archive/`.

## Uprawnienia

Android: `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`
(ruch HTTP bez TLS dozwolony tylko w buildzie debug). iOS: opisy użycia lokalizacji, aparatu i zdjęć
w `ios/Runner/Info.plist`. Na produkcji użyj backendu po HTTPS.
