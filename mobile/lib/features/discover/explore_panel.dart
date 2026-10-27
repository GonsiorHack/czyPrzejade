import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/design_tokens.dart';
import '../../core/navigation_state.dart';
import '../../core/settings.dart';
import 'data/facilities_data.dart';
import 'discover_strings.dart';
import 'models/facility.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/facility_card.dart';
import 'widgets/facility_details_dialog.dart';

/// Pełnoekranowy panel "Odkrywaj" (`exploreSlidePanel`): nagłówek, kategorie i karty miejsc.
class ExplorePanel extends StatefulWidget {
  const ExplorePanel({super.key});

  @override
  State<ExplorePanel> createState() => _ExplorePanelState();
}

class _ExplorePanelState extends State<ExplorePanel> {
  FacilityCategory? _category;
  bool _verifiedOnly = false;

  /// Obiekty z wybranego miasta: lista organiczna i opcjonalnie karta sponsorowana.
  List<Facility> _organic(PolishCity city) => facilitiesNear(city.center);

  List<Facility> _visible(PolishCity city, List<Facility> organic) {
    final shown = organic
        .where((f) => _category == null || f.category == _category)
        .where((f) => !_verifiedOnly || f.verified)
        .toList();
    final sponsored = facilitiesNear(city.center, source: const [sponsoredFacility]);
    // Sponsorowana karta zawsze na górze, tylko przy widoku wszystkich kategorii.
    if (_category == null && sponsored.isNotEmpty) return [...sponsored, ...shown];
    return shown;
  }

  void _navigateTo(Facility facility) {
    context.read<NavigationState>().navigateTo(
      NavigationTarget(name: facility.name, point: facility.coordinates),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final city = context.select<AppSettings, PolishCity>((s) => s.city);
    final organic = _organic(city);
    final categories = FacilityCategory.values
        .where((c) => organic.any((f) => f.category == c))
        .toList();
    final visible = _visible(city, organic);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscoverStrings.title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  DiscoverStrings.subtitle,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          CategoryFilterBar(
            categories: categories,
            category: _category,
            verifiedOnly: _verifiedOnly,
            onCategoryChanged: (value) => setState(() => _category = value),
            onVerifiedChanged: (value) => setState(() => _verifiedOnly = value),
          ),
          Expanded(
            child: visible.isEmpty
                ? _EmptyState(city: city.name)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.md,
                      Spacing.lg,
                      bottomInset + Spacing.lg,
                    ),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
                    itemBuilder: (context, index) {
                      final facility = visible[index];
                      return FacilityCard(
                        facility: facility,
                        onTap: () => showFacilityDetails(context, facility),
                        onNavigate: () => _navigateTo(facility),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.sm,
        children: [
          const Icon(Icons.search_off, size: 40),
          Text(
            DiscoverStrings.noPlacesInCity(city),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text(DiscoverStrings.noPlacesHint, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
