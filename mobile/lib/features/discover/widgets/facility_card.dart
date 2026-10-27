import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../discover_strings.dart';
import '../models/facility.dart';
import 'accessibility_grade_badge.dart';
import 'facility_thumbnail.dart';
import 'rating_row.dart';

/// Odstęp na plakietkę "Sponsorowane" nad treścią karty.
const _sponsoredHeaderHeight = 26.0;

/// Czysta karta miejsca: zdjęcie, nazwa, ocena, adres, plakietka A-F i "Wyznacz trasę".
/// Pełna lista udogodnień jest tylko w oknie szczegółów (`placePopup`).
/// Karta z `facility.sponsored` dostaje plakietkę "Sponsorowane" w rogu.
class FacilityCard extends StatelessWidget {
  const FacilityCard({
    super.key,
    required this.facility,
    required this.onTap,
    required this.onNavigate,
  });

  final Facility facility;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final sponsored = facility.sponsored;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.md,
                sponsored ? _sponsoredHeaderHeight + Spacing.xs : Spacing.md,
                Spacing.md,
                Spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.md,
                children: [
                  _Header(facility: facility),
                  Center(child: AccessibilityGradeBadge(facility: facility)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text(DiscoverStrings.routeTo),
                      onPressed: onNavigate,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (sponsored) const Positioned(top: 0, right: 0, child: _SponsoredBadge()),
        ],
      ),
    );
  }
}

class _SponsoredBadge extends StatelessWidget {
  const _SponsoredBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: _sponsoredHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Radii.sm)),
      ),
      child: Text(
        DiscoverStrings.sponsored,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = TextStyle(color: scheme.onSurfaceVariant, fontSize: 13);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.md,
      children: [
        FacilityThumbnail(facility: facility),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.xs,
            children: [
              Text(
                facility.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              RatingRow(rating: facility.rating, count: facility.ratingCount),
              Text('${facility.category.label} · ${facility.distance}', style: secondary),
              Text(facility.address, style: secondary),
            ],
          ),
        ),
      ],
    );
  }
}
