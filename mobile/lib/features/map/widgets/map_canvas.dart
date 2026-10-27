import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/config.dart';
import '../../../app/theme.dart';
import '../map_constants.dart';
import '../models/route_info.dart';
import '../models/waypoint.dart';
import 'map_markers.dart';
import 'route_polylines.dart';

/// Sama mapa (`FlutterMap`): kafelki, trasy i znaczniki. Bez logiki biznesowej.
class MapCanvas extends StatefulWidget {
  const MapCanvas({
    super.key,
    required this.controller,
    required this.routes,
    required this.activeRoute,
    required this.start,
    required this.destination,
    required this.userLocation,
    required this.onReady,
    required this.onTap,
    required this.onLongPress,
    required this.onRouteSelected,
  });

  final MapController controller;
  final List<RouteInfo> routes;
  final RouteInfo? activeRoute;
  final Waypoint? start;
  final Waypoint? destination;
  final LatLng? userLocation;
  final VoidCallback onReady;
  final ValueChanged<LatLng> onTap;
  final ValueChanged<LatLng> onLongPress;
  final ValueChanged<String> onRouteSelected;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final LayerHitNotifier<String> _routeHit = ValueNotifier(null);

  @override
  void dispose() {
    _routeHit.dispose();
    super.dispose();
  }

  /// Dotknięcie trasy ją wybiera; dotknięcie reszty mapy ustawia punkt.
  void _handleTap(LatLng point) {
    final hits = _routeHit.value?.hitValues;
    if (hits != null && hits.isNotEmpty) {
      widget.onRouteSelected(hits.first);
      return;
    }
    widget.onTap(point);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final start = widget.start;
    final destination = widget.destination;
    final user = widget.userLocation;

    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: AppConfig.krakowCenter,
        initialZoom: AppConfig.defaultZoom,
        minZoom: MapConstants.minZoom,
        maxZoom: MapConstants.maxZoom,
        backgroundColor: MapConstants.backgroundColor,
        onMapReady: widget.onReady,
        onTap: (_, point) => _handleTap(point),
        onLongPress: (_, point) => widget.onLongPress(point),
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.tileUrl,
          subdomains: AppConfig.tileSubdomains,
          userAgentPackageName: AppConfig.userAgentPackage,
          maxNativeZoom: MapConstants.maxZoom.toInt(),
        ),
        PolylineLayer<String>(
          hitNotifier: _routeHit,
          minimumHitbox: MapConstants.routeHitbox,
          polylines: buildRoutePolylines(
            routes: widget.routes,
            active: widget.activeRoute,
            colors: colors,
          ),
        ),
        MarkerLayer(
          markers: [
            if (user != null)
              Marker(
                point: user,
                width: MapConstants.userMarkerSize,
                height: MapConstants.userMarkerSize,
                child: const UserLocationDot(),
              ),
            if (start != null) _badgeMarker(start, WaypointKind.start),
            if (destination != null) _badgeMarker(destination, WaypointKind.destination),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text(
            AppConfig.mapAttribution,
            style: TextStyle(fontSize: MapConstants.attributionFontSize),
          ),
        ),
      ],
    );
  }

  Marker _badgeMarker(Waypoint waypoint, WaypointKind kind) => Marker(
        point: waypoint.point,
        width: MapConstants.waypointMarkerSize,
        height: MapConstants.waypointMarkerSize,
        child: MapMarkerBadge(kind: kind),
      );
}
