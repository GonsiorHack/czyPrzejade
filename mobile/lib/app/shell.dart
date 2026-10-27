import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation_state.dart';
import '../core/widgets/slide_panel.dart';
import '../features/discover/explore_panel.dart';
import '../features/map/map_screen.dart';
import '../features/settings/settings_screen.dart';
import 'bottom_nav.dart';
import 'explore_edge_handle.dart';

/// Powłoka aplikacji: mapa zawsze pod spodem, "Odkrywaj" i "Ustawienia" jako
/// pełnoekranowe panele wsuwane z lewej, dolny pasek nawigacji na wierzchu.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationState>();
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: AppBottomNav(selected: nav.tab, onSelected: nav.goTo),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapScreen(),
          ExploreEdgeHandle(
            visible: nav.tab == AppTab.map,
            onOpen: () => nav.selectTab(AppTab.explore),
          ),
          SlidePanel(
            visible: nav.tab == AppTab.explore,
            onDismiss: nav.showMap,
            child: const ExplorePanel(),
          ),
          SlidePanel(
            visible: nav.tab == AppTab.settings,
            edge: SlideEdge.right,
            onDismiss: nav.showMap,
            child: const SettingsScreen(),
          ),
        ],
      ),
    );
  }
}
