import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../discover_strings.dart';
import '../models/facility.dart';
import 'facility_badges.dart';

const _maxVisibleBadges = 2;
const _iconBoxSize = 56.0;

/// Karta obiektu na liście; dotknięcie otwiera arkusz szczegółów.
class FacilityCard extends StatelessWidget {
  const FacilityCard({super.key, required this.facility, required this.onTap});
  final Facility facility;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.md,
                children: [
                  _CategoryIcon(category: facility.category),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.xxs,
                      children: [
                        Text(
                          facility.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          '${facility.address} · ${facility.distance}',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _VerificationRow(facility: facility),
              FacilityBadgeWrap(badges: facility.badges, limit: _maxVisibleBadges),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final FacilityCategory category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: _iconBoxSize,
      height: _iconBoxSize,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Icon(category.icon, color: scheme.primary, semanticLabel: category.label),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final verified = facility.verified;
    return Row(
      spacing: 6,
      children: [
        Icon(
          verified ? Icons.verified : Icons.info_outline,
          size: 18,
          color: verified ? colors.success : colors.caution,
        ),
        Expanded(
          child: Text(
            verified ? DiscoverStrings.verifiedBy(facility.verifiedSource) : facility.verifiedSource,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
