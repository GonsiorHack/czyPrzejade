/// Wszystkie teksty UI ekranu mapy (po polsku).
abstract final class MapStrings {
  // Etykiety punktów
  static const mapPointLabel = 'Punkt na mapie';
  static const userLocationLabel = 'Twoja lokalizacja';

  // Komunikaty (toast)
  static const connectionLost = 'Utracono połączenie z serwerem';
  static const pointsTooClose = 'Punkt startu i celu są zbyt blisko siebie.';
  static const addressTooShort = 'Wpisz co najmniej 3 znaki adresu.';
  static const addressNotFound = 'Nie znaleziono adresu w Krakowie.';
  static const routeNotFound = 'Nie znaleziono trasy między wybranymi punktami.';
  static const offlineDemo = 'Brak połączenia z serwerem - pokazano zapisaną trasę demonstracyjną.';
  static const locationDisabled = 'Lokalizacja jest wyłączona na tym urządzeniu.';
  static const locationDenied = 'Brak zgody na dostęp do lokalizacji.';
  static const locationUnavailable = 'Nie udało się ustalić lokalizacji.';
  static const outsideKrakow = 'Jesteś poza Krakowem.';
  static const gpsLost = 'Utracono sygnał GPS.';
  static const serverNotConfigured = 'Nie skonfigurowano adresu serwera.';

  // Podpowiedzi nad mapą
  static const hintRouting = 'Wyznaczanie optymalnej trasy…';
  static const hintPickStart = 'Dotknij mapy, aby wybrać punkt startowy.';
  static const hintStartOnly = 'Wybierz punkt startowy.';
  static const hintPickDestination = 'Teraz wybierz cel podróży.';
  static String hintNavigating(String duration) => 'Nawigacja: $duration do celu.';

  // Panel planowania trasy
  static const fromHint = 'Skąd? (adres lub mapa)';
  static const toHint = 'Dokąd? (adres lub mapa)';
  static const useMyLocation = 'Użyj mojej lokalizacji';
  static const clearRoute = 'Wyczyść trasę';
  static const search = 'Szukaj';

  // Sterowanie mapą
  static const zoomIn = 'Przybliż';
  static const zoomOut = 'Oddal';
  static const showMyLocation = 'Pokaż moją lokalizację';

  // Arkusz trasy (bottomSheet)
  static const routeAccessible = 'Trasa dostępna';
  static const routeStandard = 'Trasa standardowa';
  static const showAlternative = 'Pokaż trasę alternatywną';
  static const hideAlternative = 'Ukryj trasę alternatywną';
  static const offlineRouteNote = 'Trasa demonstracyjna - brak połączenia z serwerem.';
  static const identicalRoutesNote = 'Trasa dostępna i standardowa są takie same.';
  static const startNavigation = 'Rozpocznij nawigację';
  static const stopNavigation = 'Zakończ nawigację';
  static const sameTime = 'ten sam czas';
  static const faster = 'szybciej';
  static const slower = 'dłużej';

  // Etykiety tras
  static const tagNoStairs = 'Bez schodów';
  static const tagNoCobblestones = 'Bez kostki brukowej';
  static const tagStairs = 'Schody';
  static const tagCobblestones = 'Kostka brukowa';

  // Zgłaszanie przeszkód
  static const reportMenuText = 'Zgłoś przeszkodę na trasie.';
  static const reportCommunityText =
      'Dzięki Tobie ktoś inny bezpiecznie dotrze do celu.\nRazem tworzymy Kraków bez barier.';
  static const reportTooltip = 'Zgłoś przeszkodę zdjęciem';
  static const reportOpenCamera = 'Uruchom aparat';
  static const reportCameraFailed = 'Nie udało się uruchomić aparatu.';
  static const reportAnalyzing = 'Analizujemy zdjęcie…';
  static const reportThanks = 'Dziękujemy!';
  static const ok = 'OK';
}
