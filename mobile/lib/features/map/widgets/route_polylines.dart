import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../app/theme.dart';
import '../map_constants.dart';
import '../models/route_info.dart';
import 'map_markers.dart';

/// Kolor aktywnej trasy zależny od jej typu.
Color activeRouteColor(RouteInfo route, AppColors colors) =>
    route.type == RouteType.wheelchair ? colors.routeAccessible : colors.routeStandard;

/// Ciemniejszy wariant koloru do obrysu (casing) trasy.
Color _casingColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();
}

/// Buduje polilinie: nieaktywne trasy kropkowane, aktywna z ciemnym obrysem i jasnym wnętrzem.
List<Polyline<String>> buildRoutePolylines({
  required List<RouteInfo> routes,
  required RouteInfo? active,
  required AppColors colors,
}) {
  return [
    for (final route in routes)
      if (route.id != active?.id)
        Polyline<String>(
          points: route.coordinates,
          strokeWidth: colors.inactiveRouteWidth,
          color: colors.routeInactive,
          pattern: const StrokePattern.dotted(),
          strokeCap: StrokeCap.round,
          hitValue: route.id,
        ),
    if (active != null) ...[
      Polyline<String>(
        points: active.coordinates,
        strokeWidth: colors.activeRouteWidth + 5,
        color: _casingColor(activeRouteColor(active, colors)),
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
        hitValue: active.id,
      ),
      Polyline<String>(
        points: active.coordinates,
        strokeWidth: colors.activeRouteWidth,
        color: activeRouteColor(active, colors),
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
        hitValue: active.id,
      ),
    ],
  ];
}

/// Kilka równomiernie rozmieszczonych kropek na wnętrzu aktywnej trasy (bez końców A/B).
List<Marker> buildRouteDots(RouteInfo? active, AppColors colors) {
  if (active == null) return const [];
  const dotCount = 4;
  final points = active.coordinates;
  if (points.length < dotCount + 2) return const [];
  final color = activeRouteColor(active, colors);
  return [
    for (var i = 1; i <= dotCount; i++)
      Marker(
        point: points[(points.length - 1) * i ~/ (dotCount + 1)],
        width: MapConstants.routeDotSize,
        height: MapConstants.routeDotSize,
        rotate: true,
        child: RouteDotMarker(color: color),
      ),
  ];
}
