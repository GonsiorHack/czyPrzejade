import 'package:latlong2/latlong.dart';

/// Który z dwóch punktów trasy jest edytowany.
enum WaypointKind { start, destination }

/// Punkt trasy wraz z etykietą pokazywaną w polu adresu.
class Waypoint {
  const Waypoint(this.point, this.label);
  final LatLng point;
  final String label;
}
