import 'package:latlong2/latlong.dart';

/// Tożsamość aplikacji, adres backendu i domyślne ustawienia mapy.
class AppConfig {
  AppConfig._();

  static const name = 'czyPrzejade';
  static const title = 'czyPrzejade?';
  static const tagline = 'Miasta Bez Barier';

  /// Adres backendu ustawiany przy buildzie:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`.
  /// Pusta wartość włącza trasy demo offline i wyłącza geokodowanie.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBase => apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  static const apiAccessibleRoute = '/api/route';
  static const apiStandardRoute = '/api/route-standard';
  static const apiGeocode = '/api/geocode';

  /// Kafelki OSM. CARTO Voyager wymaga obecnie klucza API (zwraca znak wodny), więc nie jest używany.
  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const tileSubdomains = <String>[];
  static const userAgentPackage = 'pl.czyprzejade.czy_przejade';
  static const mapAttribution = '© OpenStreetMap contributors';

  static const krakowCenter = LatLng(50.0614, 19.9372);

  /// Przybliżony prostokąt Polski: pozycje GPS spoza niego są ignorowane podczas nawigacji.
  static final polandBounds = GeoBounds(const LatLng(49.0, 14.1), const LatLng(54.9, 24.2));

  static final krakowBounds = GeoBounds(const LatLng(49.967, 19.792), const LatLng(50.126, 20.217));

  static const defaultZoom = 16.0;
  static const userLocationZoom = 17.0;
  static const navigationZoom = 18.0;

  /// Punkt startu używany, gdy lokalizacja użytkownika jest niedostępna lub poza Krakowem.
  static const fallbackStart = LatLng(50.068056, 19.984806);
  static const fallbackStartLabel = 'TAURON Arena Kraków, ul. Stanisława Lema 7';

  /// Minimalny dystans między startem a celem.
  static const minRouteDistanceMeters = 10.0;
}

/// Prostokątny obszar geograficzny (południowy zachód - północny wschód).
class GeoBounds {
  const GeoBounds(this.southWest, this.northEast);
  final LatLng southWest;
  final LatLng northEast;

  bool contains(LatLng p) =>
      p.latitude >= southWest.latitude &&
      p.latitude <= northEast.latitude &&
      p.longitude >= southWest.longitude &&
      p.longitude <= northEast.longitude;
}
