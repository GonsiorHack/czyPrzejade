import 'package:flutter/material.dart';

import '../models/facility.dart';

/// Kompaktowy chip z udogodnieniem (ikona + etykieta).
class FacilityBadgeChip extends StatelessWidget {
  const FacilityBadgeChip({super.key, required this.badge});
  final FacilityBadge badge;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(badge.icon.icon, size: 16),
      label: Text(badge.label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
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
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final badge in shown) FacilityBadgeChip(badge: badge),
        if (extra > 0) Chip(label: Text('+$extra'), visualDensity: VisualDensity.compact),
      ],
    );
  }
}
