import 'package:latlong2/latlong.dart';

import '../map_strings.dart';
import '../models/route_info.dart';
import 'api_exception.dart';

/// Parsuje GeoJSON `Feature` lub `FeatureCollection` na listę tras (dostępna pierwsza).
List<RouteInfo> parseRouteResponse(dynamic data) {
  final List features;
  if (data is Map && data['type'] == 'FeatureCollection' && data['features'] is List) {
    features = data['features'] as List;
  } else if (data is Map && data['type'] == 'Feature') {
    features = [data];
  } else {
    throw ApiException(ApiErrorKind.server, 'Invalid routes response: expected GeoJSON');
  }

  final routes = <RouteInfo>[];
  for (var i = 0; i < features.length; i++) {
    final route = _toRouteInfo(features[i], i);
    if (route != null) routes.add(route);
  }
  sortAccessibleFirst(routes);
  return routes;
}

/// Sortuje listę w miejscu: trasy bezpieczne dla wózka na początku.
void sortAccessibleFirst(List<RouteInfo> routes) {
  routes.sort((a, b) => (b.isWheelchairSafe ? 1 : 0) - (a.isWheelchairSafe ? 1 : 0));
}

RouteInfo? _toRouteInfo(dynamic feature, int index) {
  if (feature is! Map) return null;
  final props = feature['properties'];
  final geometry = feature['geometry'];
  if (props is! Map || geometry is! Map) return null;

  final routeType = props['route_type'];
  final distance = props['distance_m'];
  final minutes = props['time_minutes'];
  final safe = props['is_wheelchair_safe'];
  final coords = geometry['coordinates'];
  final valid = routeType is String &&
      distance is num &&
      minutes is num &&
      safe is bool &&
      geometry['type'] == 'LineString' &&
      coords is List &&
      coords.length >= 2;
  if (!valid) return null;

  final points = _parseCoordinates(coords);
  if (points == null) return null;

  return RouteInfo(
    id: '$routeType-$index',
    name: safe ? MapStrings.routeAccessible : MapStrings.routeStandard,
    routeType: routeType,
    type: safe ? RouteType.wheelchair : RouteType.standard,
    isWheelchairSafe: safe,
    distanceMeters: distance.toDouble(),
    durationMinutes: minutes.toDouble(),
    tags: safe ? RouteTags.accessible : RouteTags.standard,
    coordinates: points,
  );
}

/// Kolejność w GeoJSON to `[lng, lat]`; zwraca `null` przy niepoprawnym punkcie.
List<LatLng>? _parseCoordinates(List coords) {
  final points = <LatLng>[];
  for (final c in coords) {
    if (c is! List || c.length < 2 || c[0] is! num || c[1] is! num) return null;
    points.add(LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()));
  }
  return points;
}

/// Usuwa trasy, których geometria powtarza wcześniejszą trasę.
({List<RouteInfo> routes, bool identical}) collapseIdenticalRoutes(List<RouteInfo> routes) {
  final unique = <RouteInfo>[];
  for (final route in routes) {
    if (!unique.any((known) => _sameGeometry(known, route))) unique.add(route);
  }
  return (routes: unique, identical: unique.length < routes.length);
}

bool _sameGeometry(RouteInfo a, RouteInfo b) {
  const epsilon = 1e-6;
  if (a.coordinates.length != b.coordinates.length) return false;
  for (var i = 0; i < a.coordinates.length; i++) {
    final p = a.coordinates[i];
    final q = b.coordinates[i];
    if ((p.latitude - q.latitude).abs() > epsilon || (p.longitude - q.longitude).abs() > epsilon) {
      return false;
    }
  }
  return true;
}
