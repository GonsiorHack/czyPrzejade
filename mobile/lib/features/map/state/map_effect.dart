import 'package:latlong2/latlong.dart';

/// Jednorazowe zdarzenia, które [MapViewModel] wysyła do widoku
/// (widok wykonuje je na `MapController` i w `ScaffoldMessenger`).
sealed class MapEffect {
  const MapEffect();
}

/// Krótki komunikat dla użytkownika (snackBar).
class ShowMessage extends MapEffect {
  const ShowMessage(this.text);
  final String text;
}

/// Przesunięcie kamery.
///
/// [keepHigherZoom] nie pozwala zmniejszyć obecnego zoomu,
/// a [animated] = false wykonuje skok bez animacji (np. śledzenie GPS).
class MoveCamera extends MapEffect {
  const MoveCamera(
    this.target, {
    this.zoom,
    this.keepHigherZoom = false,
    this.animated = true,
  });
  final LatLng target;
  final double? zoom;
  final bool keepHigherZoom;
  final bool animated;
}

/// Dopasowanie kamery do wszystkich wyznaczonych tras.
class FitRoutes extends MapEffect {
  const FitRoutes();
}
