import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../core/navigation_state.dart';
import '../core/settings.dart';
import '../features/discover/discover_screen.dart';
import '../features/map/map_screen.dart';
import '../features/settings/settings_screen.dart';
import 'config.dart';
import 'design_tokens.dart';

const _logoDark = 'assets/branding/logo-dark.svg';
const _logoLight = 'assets/branding/logo-light.svg';
const _topBarHeight = 56.0;
const _logoHeight = 32.0;

/// Opis jednej zakładki dolnego nav.
class _TabSpec {
  const _TabSpec(this.tab, this.label, this.icon, this.selectedIcon);
  final AppTab tab;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _tabs = [
  _TabSpec(AppTab.map, 'Trasa', Icons.map_outlined, Icons.map),
  _TabSpec(AppTab.discover, 'Odkrywaj', Icons.explore_outlined, Icons.explore),
  _TabSpec(AppTab.settings, 'Ustawienia', Icons.tune_outlined, Icons.tune),
];

/// Powłoka z dolnym nav: Trasa (mapa), Odkrywaj, Ustawienia.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationState>();
    final isDark = context.select<AppSettings, bool>((s) => s.theme == AppTheme.dark);

    return Scaffold(
      // Mapa zajmuje cały ekran, dlatego górny pasek jest tylko w pozostałych zakładkach.
      appBar: nav.tab == AppTab.map ? null : _BrandAppBar(logoAsset: isDark ? _logoDark : _logoLight),
      // IndexedStack zachowuje stan mapy przy przełączaniu zakładek.
      body: IndexedStack(
        index: nav.tab.index,
        children: const [MapScreen(), DiscoverScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.tab.index,
        onDestinationSelected: (i) => nav.selectTab(AppTab.values[i]),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _BrandAppBar({required this.logoAsset});
  final String logoAsset;

  @override
  Size get preferredSize => const Size.fromHeight(_topBarHeight);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AppBar(
      toolbarHeight: _topBarHeight,
      title: Row(
        spacing: Spacing.sm,
        children: [
          SvgPicture.asset(logoAsset, height: _logoHeight, semanticsLabel: AppConfig.title),
          Text.rich(
            TextSpan(
              text: AppConfig.name,
              children: [TextSpan(text: '?', style: TextStyle(color: primary))],
            ),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
