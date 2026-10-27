import 'package:latlong2/latlong.dart';

/// Wynik geokodowania zwrócony przez backend.
class GeocodeResult {
  const GeocodeResult({required this.name, required this.lat, required this.lng});
  final String name;
  final double lat;
  final double lng;

  LatLng get point => LatLng(lat, lng);
}
