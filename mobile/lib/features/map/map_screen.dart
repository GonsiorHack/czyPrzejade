import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../app/config.dart';
import '../../app/design_tokens.dart';
import '../../core/navigation_state.dart';
import 'services/location_service.dart';
import 'services/map_api.dart';
import 'state/camera_animator.dart';
import 'state/map_effect.dart';
import 'state/map_view_model.dart';
import 'widgets/map_canvas.dart';
import 'widgets/map_controls.dart';
import 'widgets/map_hint_banner.dart';
import 'widgets/report_obstacle_button.dart';
import 'widgets/route_planner_panel.dart';
import 'widgets/route_sheet.dart';

/// Ekran mapy: składa widgety i wykonuje efekty z [MapViewModel] (kamera, snackBar).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final _mapController = MapController();
  late final CameraAnimator _camera = CameraAnimator(controller: _mapController, vsync: this);
  late final MapViewModel _viewModel = MapViewModel(api: MapApi(), location: LocationService());
  late final StreamSubscription<MapEffect> _effectsSub;

  bool _mapReady = false;
  bool _consumingTarget = false;

  @override
  void initState() {
    super.initState();
    _effectsSub = _viewModel.effects.listen(_onEffect);
  }

  @override
  void dispose() {
    _effectsSub.cancel();
    _viewModel.dispose();
    _camera.dispose();
    super.dispose();
  }

  void _onEffect(MapEffect effect) {
    if (!mounted) return;
    switch (effect) {
      case ShowMessage(:final text):
        _showMessage(text);
      case MoveCamera():
        _moveCamera(effect);
      case FitRoutes():
        _camera.fitToRoutes([for (final r in _viewModel.routes) ...r.coordinates]);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  void _moveCamera(MoveCamera effect) {
    final currentZoom = _mapReady ? _camera.camera.zoom : AppConfig.defaultZoom;
    final requested = effect.zoom ?? currentZoom;
    final zoom = effect.keepHigherZoom && currentZoom > requested ? currentZoom : requested;
    if (effect.animated) {
      _camera.animateTo(effect.target, zoom);
    } else {
      _camera.jumpTo(effect.target, zoom);
    }
  }

  void _onMapReady() {
    _camera.ready = true;
    setState(() => _mapReady = true);
  }

  /// Obsługa celu wybranego w zakładce "Odkrywaj" (jednorazowo, po zbudowaniu mapy).
  void _consumePendingTarget(NavigationState nav) {
    if (_consumingTarget || !_mapReady || nav.pendingTarget == null) return;
    _consumingTarget = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final target = nav.takeTarget();
      if (target != null && mounted) await _viewModel.navigateTo(target);
      _consumingTarget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _consumePendingTarget(context.watch<NavigationState>());
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => _buildContent(),
    );
  }

  Widget _buildContent() {
    final vm = _viewModel;
    final hint = vm.hint;

    return Stack(
      children: [
        MapCanvas(
          controller: _mapController,
          routes: vm.routes,
          activeRoute: vm.activeRoute,
          start: vm.start,
          destination: vm.destination,
          userLocation: vm.userLocation,
          onReady: _onMapReady,
          onTap: vm.onMapTap,
          onLongPress: vm.onMapLongPress,
          onRouteSelected: vm.selectRoute,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.sm,
              children: [
                RoutePlannerPanel(
                  startController: vm.startController,
                  destinationController: vm.destinationController,
                  busy: vm.loading || vm.locating,
                  onSubmit: vm.submitAddress,
                  onUseLocation: vm.useLocationAsStart,
                  onReset: vm.reset,
                ),
                if (hint.isNotEmpty) MapHintBanner(text: hint),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ReportObstacleButton(),
                    const Spacer(),
                    MapControls(
                      locating: vm.locating,
                      onZoomIn: () => _camera.zoomBy(1),
                      onZoomOut: () => _camera.zoomBy(-1),
                      onLocate: vm.centerOnUser,
                    ),
                  ],
                ),
              ),
              if (vm.routes.isNotEmpty)
                RouteSheet(
                  routes: vm.routes,
                  activeRouteId: vm.activeRouteId,
                  identical: vm.identicalRoutes,
                  navigating: vm.navigating,
                  onSelect: vm.selectRoute,
                  onToggleNavigation: vm.toggleNavigation,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
