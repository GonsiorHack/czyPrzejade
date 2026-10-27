import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/config.dart';
import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../map_constants.dart';
import '../../discover/models/facility.dart';
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
    required this.facilities,
    required this.onFacilityTap,
    required this.initialCenter,
    this.heading,
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
  final List<Facility> facilities;
  final ValueChanged<Facility> onFacilityTap;
  final LatLng initialCenter;

  /// Kierunek ruchu (stopnie od północy) w trakcie nawigacji; null = brak wachlarza.
  final double? heading;

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  final LayerHitNotifier<String> _routeHit = ValueNotifier(null);
  bool _facilitiesVisible = AppConfig.defaultZoom >= MapConstants.facilityMinZoom;

  /// Przebudowa tylko przy przekroczeniu progu zoomu, nie przy każdym ruchu kamery.
  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    final visible = camera.zoom >= MapConstants.facilityMinZoom;
    if (visible != _facilitiesVisible) setState(() => _facilitiesVisible = visible);
  }

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
    final heading = widget.heading;

    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        onPositionChanged: _onPositionChanged,
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
          retinaMode: RetinaMode.isHighDensity(context),
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
        // Obiekty widoczne dopiero od zoomu facilityMinZoom (płynne zanikanie).
        AnimatedOpacity(
          opacity: _facilitiesVisible ? 1 : 0,
          duration: AppDurations.facilityFade,
          child: IgnorePointer(
            ignoring: !_facilitiesVisible,
            child: MarkerLayer(
              markers: [
                for (final facility in widget.facilities)
                  Marker(
                    point: facility.coordinates,
                    width: MapConstants.facilityMarkerSize,
                    height: MapConstants.facilityMarkerSize,
                    rotate: true,
                    child: FacilityMarker(
                      facility: facility,
                      onTap: () => widget.onFacilityTap(facility),
                    ),
                  ),
              ],
            ),
          ),
        ),
        MarkerLayer(
          markers: [
            ...buildRouteDots(widget.activeRoute, colors),
            if (user != null)
              Marker(
                point: user,
                width: heading == null
                    ? MapConstants.userMarkerSize
                    : MapConstants.userHeadingMarkerSize,
                height: heading == null
                    ? MapConstants.userMarkerSize
                    : MapConstants.userHeadingMarkerSize,
                // Bez kontr-rotacji: wachlarz obraca się razem z mapą, zgodnie z kierunkiem geograficznym.
                child: UserLocationDot(heading: heading),
              ),
            if (start != null) _badgeMarker(start, WaypointKind.start),
            if (destination != null) _badgeMarker(destination, WaypointKind.destination),
          ],
        ),
      ],
    );
  }

  Marker _badgeMarker(Waypoint waypoint, WaypointKind kind) => Marker(
    point: waypoint.point,
    width: MapConstants.waypointMarkerSize,
    height: MapConstants.waypointMarkerSize,
    rotate: true,
    child: MapMarkerBadge(kind: kind),
  );
}
