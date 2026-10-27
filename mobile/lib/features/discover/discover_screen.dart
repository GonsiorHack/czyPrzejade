import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import 'data/facilities_data.dart';
import 'discover_strings.dart';
import 'models/facility.dart';
import 'widgets/facility_card.dart';
import 'widgets/facility_details_sheet.dart';

/// Zakładka "Odkrywaj": lista obiektów z filtrami kategorii i weryfikacji.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  FacilityCategory? _category;
  bool _verifiedOnly = false;

  List<Facility> get _visible => facilities
      .where((f) => _category == null || f.category == _category)
      .where((f) => !_verifiedOnly || f.verified)
      .toList();

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          DiscoverStrings.title,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          DiscoverStrings.subtitle,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: Spacing.md),
        _CategoryFilter(selected: _category, onChanged: (c) => setState(() => _category = c)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(DiscoverStrings.verifiedOnly),
          value: _verifiedOnly,
          onChanged: (value) => setState(() => _verifiedOnly = value),
        ),
        if (visible.isEmpty) const _EmptyState(),
        for (final facility in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: FacilityCard(
              facility: facility,
              onTap: () => showFacilityDetails(context, facility),
            ),
          ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onChanged});
  final FacilityCategory? selected;
  final ValueChanged<FacilityCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      children: [
        ChoiceChip(
          label: const Text(DiscoverStrings.allCategories),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final category in FacilityCategory.values)
          ChoiceChip(
            label: Text(category.label),
            selected: selected == category,
            onSelected: (_) => onChanged(category),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: Column(
        spacing: Spacing.sm,
        children: [
          const Icon(Icons.search_off, size: 40),
          Text(DiscoverStrings.emptyTitle, style: Theme.of(context).textTheme.titleMedium),
          const Text(DiscoverStrings.emptyHint),
        ],
      ),
    );
  }
}
