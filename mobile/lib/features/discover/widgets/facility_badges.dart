import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../models/facility.dart';

/// Chip z udogodnieniem (ikona + etykieta) w wysokim kontraście.
class FacilityBadgeChip extends StatelessWidget {
  const FacilityBadgeChip({super.key, required this.badge});
  final FacilityBadge badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: colors.successBg,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: colors.success.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.xs,
        children: [
          Icon(badge.icon.icon, size: 16, color: colors.success),
          Flexible(
            child: Text(
              badge.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.success, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrap z chipami; odstęp zgodny z tokenami.
class FacilityBadgeWrap extends StatelessWidget {
  const FacilityBadgeWrap({super.key, required this.badges, this.limit});
  final List<FacilityBadge> badges;

  /// Maksymalna liczba chipów; reszta jest zwinięta do "+N".
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final shown = limit == null ? badges : badges.take(limit!).toList();
    final extra = badges.length - shown.length;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final badge in shown) FacilityBadgeChip(badge: badge),
        if (extra > 0) _MoreChip(count: extra),
      ],
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: scheme.outline),
      ),
      child: Text('+$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
