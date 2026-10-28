import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../discover_strings.dart';
import '../utils/format.dart';

const _starCount = 5;
const _starSize = 16.0;

/// Ocena w stylu Google Maps: `4,7 ★★★★★ (18 432)`.
class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating, required this.count});
  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final star = context.appColors.ratingStar;
    final ratingText = formatRating(rating);
    final countText = formatCount(count);

    return Semantics(
      label: DiscoverStrings.ratingSemantics(ratingText, countText),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.xs,
        children: [
          Text(ratingText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          for (var i = 0; i < _starCount; i++) Icon(_iconFor(i), size: _starSize, color: star),
          Text('($countText)', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  IconData _iconFor(int index) {
    final filled = rating - index;
    if (filled >= 0.75) return Icons.star;
    if (filled >= 0.25) return Icons.star_half;
    return Icons.star_border;
  }
}
