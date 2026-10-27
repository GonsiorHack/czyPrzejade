import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../app/config.dart';
import '../../app/design_tokens.dart';
import '../../core/navigation_state.dart';
import '../../core/settings.dart';
import '../discover/data/facilities_data.dart';
import '../discover/widgets/facility_details_dialog.dart';
import 'services/location_service.dart';
import 'services/map_api.dart';
import 'state/camera_animator.dart';
import 'state/map_effect.dart';
import 'map_strings.dart';
import 'state/map_view_model.dart';
import 'widgets/map_canvas.dart';
import 'widgets/map_controls.dart';
import 'widgets/map_floating_layer.dart';
import 'widgets/map_hint_banner.dart';
import 'widgets/route_sheet.dart';
import 'widgets/top_search_bar.dart';

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

  PolishCity? _city;
  bool _mapReady = false;
  bool _consumingTarget = false;

  @override
  void initState() {
    super.initState();
    _effectsSub = _viewModel.effects.listen(_onEffect);
    unawaited(_viewModel.initLocation());
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
      case RotateCamera(:final degrees):
        _camera.rotateTo(degrees);
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
    final city = _city;
    if (city != null && city.name != defaultCity.name) {
      _camera.jumpTo(city.center, AppConfig.defaultZoom);
    }
    setState(() => _mapReady = true);
  }

  /// Obsługa celu wybranego w zakładce "Odkrywaj" (jednorazowo, po zbudowaniu mapy).
  void _consumePendingTarget(NavigationState nav) {
    if (_consumingTarget || !_mapReady || nav.pendingTarget == null) return;
    _consumingTarget = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final target = nav.takeTarget();
      if (target != null && mounted) {
        await _viewModel.navigateTo(target);
      }
      _consumingTarget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _consumePendingTarget(context.watch<NavigationState>());
    final city = context.select<AppSettings, PolishCity>((s) => s.city);
    final previousCity = _city;
    _city = city;
    if (previousCity != null && previousCity.name != city.name && _mapReady) {
      // Zmiana domyślnego miasta w ustawieniach przenosi mapę do nowego miasta.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _camera.animateTo(city.center, AppConfig.defaultZoom - 3);
      });
    }
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Panel wyszukiwania sięga pod pasek statusu: ikony systemowe dopasowane do motywu.
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => LayoutBuilder(builder: _buildContent),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints box) {
    final vm = _viewModel;
    final hint = vm.hint;
    final idle = vm.routes.isEmpty;
    // Dolny margines obejmuje pasek nawigacji (Scaffold z extendBody).
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
          facilities: facilitiesNear(_city?.center ?? defaultCity.center),
          initialCenter: _city?.center ?? defaultCity.center,
          heading: vm.heading,
          onFacilityTap: (facility) => showFacilityDetails(context, facility),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.sm,
            children: [
              TopSearchBar(
                startController: vm.startController,
                destinationController: vm.destinationController,
                expanded: vm.showOrigin,
                busy: vm.loading || vm.locating,
                onSubmit: vm.submitAddress,
                onClear: vm.clearField,
                onVoiceUnavailable: () => _showMessage(MapStrings.voiceUnavailable),
              ),
              if (hint.isNotEmpty) MapHintBanner(text: hint),
            ],
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
              MapFloatingLayer(
                controls: MapControls(
                  locating: vm.locating,
                  onZoomIn: () => _camera.zoomBy(1),
                  onZoomOut: () => _camera.zoomBy(-1),
                  onLocate: vm.centerOnUser,
                ),
              ),
              if (idle)
                SizedBox(height: bottomInset)
              else
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
