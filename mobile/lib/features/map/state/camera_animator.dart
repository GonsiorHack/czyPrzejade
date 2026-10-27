import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/design_tokens.dart';
import '../map_constants.dart';

/// Animuje kamerę mapy (zamiennik `flyTo` z Leaflet) i dopasowuje ją do tras.
class CameraAnimator {
  CameraAnimator({required this.controller, required TickerProvider vsync})
      : _animation = AnimationController(vsync: vsync, duration: AppDurations.cameraMove);

  final MapController controller;
  final AnimationController _animation;
  VoidCallback? _tick;

  /// Ustawiane po `onMapReady`; wcześniej `MapController` nie ma kamery.
  bool ready = false;

  MapCamera get camera => controller.camera;

  void animateTo(LatLng target, double zoom) {
    if (!ready) return;
    final cam = controller.camera;
    final lat = Tween(begin: cam.center.latitude, end: target.latitude);
    final lng = Tween(begin: cam.center.longitude, end: target.longitude);
    final zoomTween = Tween(begin: cam.zoom, end: zoom);
    final curve = CurvedAnimation(parent: _animation, curve: Curves.easeInOut);

    _removeTick();
    void tick() => controller.move(
          LatLng(lat.evaluate(curve), lng.evaluate(curve)),
          zoomTween.evaluate(curve),
        );
    _tick = tick;
    _animation
      ..reset()
      ..addListener(tick);
    _animation.forward().whenCompleteOrCancel(() {
      if (_tick == tick) _removeTick();
    });
  }

  /// Natychmiastowe przesunięcie bez animacji (np. śledzenie GPS).
  void jumpTo(LatLng target, double zoom) {
    if (ready) controller.move(target, zoom);
  }

  void zoomBy(double delta) => animateTo(camera.center, camera.zoom + delta);

  void fitToRoutes(Iterable<LatLng> points) {
    if (!ready || points.isEmpty) return;
    controller.fitCamera(
      CameraFit.coordinates(
        coordinates: points.toList(),
        padding: MapConstants.fitPadding,
        maxZoom: MapConstants.fitMaxZoom,
      ),
    );
  }

  void dispose() {
    _removeTick();
    _animation.dispose();
  }

  void _removeTick() {
    final tick = _tick;
    if (tick != null) _animation.removeListener(tick);
    _tick = null;
  }
}
