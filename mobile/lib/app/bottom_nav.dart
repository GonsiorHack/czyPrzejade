import 'package:flutter/material.dart';

import '../core/navigation_state.dart';
import '../core/widgets/glass_surface.dart';
import 'shell_strings.dart';

const _navHeight = 64.0;

/// Dolny pasek nawigacji (`bottomNav`): półprzezroczysty, z rozmyciem tła.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selected, required this.onSelected});

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.zero,
      elevated: false,
      child: NavigationBar(
        height: _navHeight,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        selectedIndex: selected.index,
        onDestinationSelected: (index) => onSelected(AppTab.values[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: ShellStrings.exploreTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: ShellStrings.mapTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: ShellStrings.settingsTab,
          ),
        ],
      ),
    );
  }
}
