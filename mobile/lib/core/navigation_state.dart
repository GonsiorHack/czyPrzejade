import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../app/design_tokens.dart';

/// Główne sekcje aplikacji w kolejności dolnego paska nawigacji (lewo - środek - prawo).
enum AppTab { explore, map, settings }

/// Cel nawigacji wybrany w panelu "Odkrywaj".
class NavigationTarget {
  const NavigationTarget({required this.name, required this.point});
  final String name;
  final LatLng point;
}

/// Stan nawigacji powłoki: aktywna sekcja oraz przekazanie celu ("Wyznacz trasę")
/// z panelu "Odkrywaj" do mapy.
class NavigationState extends ChangeNotifier {
  AppTab _tab = AppTab.map;
  NavigationTarget? _pendingTarget;

  AppTab get tab => _tab;
  NavigationTarget? get pendingTarget => _pendingTarget;

  bool _disposed = false;

  /// Numer ostatniego przejścia; opóźnione etapy ze starszych przejść są pomijane.
  int _transition = 0;

  /// Natychmiastowa zmiana sekcji (przerywa trwające przejście dwuetapowe).
  void selectTab(AppTab tab) {
    _transition++;
    _setTab(tab);
  }

  /// Zmiana sekcji z dolnego paska. Przejście Odkrywaj <-> Ustawienia jest dwuetapowe:
  /// najpierw mapa, po krótkiej pauzie docelowy panel.
  void goTo(AppTab target) {
    final crossing =
        (_tab == AppTab.explore && target == AppTab.settings) ||
        (_tab == AppTab.settings && target == AppTab.explore);
    if (!crossing) {
      selectTab(target);
      return;
    }
    final token = ++_transition;
    _setTab(AppTab.map);
    Future<void>.delayed(AppDurations.stagedTransitionDelay, () {
      if (!_disposed && token == _transition) _setTab(target);
    });
  }

  void _setTab(AppTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Powrót do mapy (np. gest przesunięcia w prawo na panelu).
  void showMap() => selectTab(AppTab.map);

  /// Zapisuje cel, który mapa odbierze przez [takeTarget], i przełącza na mapę.
  void navigateTo(NavigationTarget target) {
    _pendingTarget = target;
    _transition++;
    _tab = AppTab.map;
    notifyListeners();
  }

  /// Zwraca oczekujący cel i czyści go (jednorazowe użycie).
  NavigationTarget? takeTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
