import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

enum AppTab { map, discover, settings }

/// Cel nawigacji wybrany w zakładce "Odkrywaj".
class NavigationTarget {
  const NavigationTarget({required this.name, required this.point});
  final String name;
  final LatLng point;
}

/// Stan nawigacji głównego nav (aktywna zakładka) oraz przekazanie celu
/// ("Nawiguj") z "Odkrywaj" do mapy.
class NavigationState extends ChangeNotifier {
  AppTab _tab = AppTab.map;
  NavigationTarget? _pendingTarget;

  AppTab get tab => _tab;
  NavigationTarget? get pendingTarget => _pendingTarget;

  void selectTab(AppTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Zapisuje cel i przełącza na mapę, która go odbierze przez [takeTarget].
  void navigateTo(NavigationTarget target) {
    _pendingTarget = target;
    _tab = AppTab.map;
    notifyListeners();
  }

  /// Zwraca oczekujący cel i czyści go (jednorazowe użycie).
  NavigationTarget? takeTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }
}
