import 'package:latlong2/latlong.dart';

import '../map_strings.dart';

/// Typ trasy: standardowa lub dostępna dla wózka.
enum RouteType { standard, wheelchair }

/// Ton etykiety trasy (kolorystyka chipa).
enum TagTone { positive, caution }

class RouteTag {
  const RouteTag(this.label, this.tone);
  final String label;
  final TagTone tone;
}

class RouteInfo {
  const RouteInfo({
    required this.id,
    required this.name,
    required this.routeType,
    required this.type,
    required this.isWheelchairSafe,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.tags,
    required this.coordinates,
    this.offline = false,
  });

  final String id;
  final String name;

  /// Surowa wartość `route_type` zwracana przez backend.
  final String routeType;
  final RouteType type;
  final bool isWheelchairSafe;
  final double distanceMeters;
  final double durationMinutes;
  final List<RouteTag> tags;
  final List<LatLng> coordinates;

  /// Zapisana trasa demo pokazywana, gdy serwer routingu jest niedostępny.
  final bool offline;

  RouteInfo copyWith({String? id, bool? offline}) => RouteInfo(
    id: id ?? this.id,
    name: name,
    routeType: routeType,
    type: type,
    isWheelchairSafe: isWheelchairSafe,
    distanceMeters: distanceMeters,
    durationMinutes: durationMinutes,
    tags: tags,
    coordinates: coordinates,
    offline: offline ?? this.offline,
  );
}

/// Domyślne etykiety tras dostępnej i standardowej.
abstract final class RouteTags {
  static const accessible = [
    RouteTag(MapStrings.tagNoStairs, TagTone.positive),
    RouteTag(MapStrings.tagNoCobblestones, TagTone.positive),
  ];
  static const standard = [
    RouteTag(MapStrings.tagStairs, TagTone.caution),
    RouteTag(MapStrings.tagCobblestones, TagTone.caution),
  ];
}
