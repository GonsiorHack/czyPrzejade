import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../app/theme.dart';
import '../models/route_info.dart';

/// Buduje polilinie: nieaktywne trasy kropkowane, aktywna pełna i na wierzchu.
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
    if (active != null)
      Polyline<String>(
        points: active.coordinates,
        strokeWidth: colors.activeRouteWidth,
        color: active.type == RouteType.wheelchair ? colors.routeAccessible : colors.routeStandard,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
        hitValue: active.id,
      ),
  ];
}
