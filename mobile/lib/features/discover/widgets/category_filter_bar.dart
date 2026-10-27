import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../discover_strings.dart';
import '../models/facility.dart';

/// Poziomy pasek chipów: kategorie (wybór pojedynczy) i filtr "Zweryfikowane".
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.category,
    required this.verifiedOnly,
    required this.onCategoryChanged,
    required this.onVerifiedChanged,
  });

  /// Kategorie, dla których istnieją obiekty (puste kategorie nie dostają chipa).
  final List<FacilityCategory> categories;
  final FacilityCategory? category;
  final bool verifiedOnly;
  final ValueChanged<FacilityCategory?> onCategoryChanged;
  final ValueChanged<bool> onVerifiedChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TouchTargets.min + Spacing.sm,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        children: [
          FilterChip(
            avatar: const Icon(Icons.verified_outlined, size: 18),
            label: const Text(DiscoverStrings.verifiedOnly),
            selected: verifiedOnly,
            onSelected: onVerifiedChanged,
          ),
          const SizedBox(width: Spacing.sm),
          ChoiceChip(
            label: const Text(DiscoverStrings.allCategories),
            selected: category == null,
            showCheckmark: false,
            onSelected: (_) => onCategoryChanged(null),
          ),
          for (final item in categories) ...[
            const SizedBox(width: Spacing.sm),
            ChoiceChip(
              avatar: Icon(item.icon, size: 18),
              label: Text(item.label),
              selected: category == item,
              showCheckmark: false,
              onSelected: (_) => onCategoryChanged(item),
            ),
          ],
        ],
      ),
    );
  }
}
