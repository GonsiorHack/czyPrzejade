import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../../../core/navigation_state.dart';
import '../discover_strings.dart';
import '../models/facility.dart';
import 'accessibility_grade_badge.dart';
import 'facility_badges.dart';
import 'facility_verification_row.dart';
import 'facility_thumbnail.dart';
import 'rating_row.dart';

const _maxDialogWidth = 520.0;
const _photoHeight = 170.0;

/// Otwiera wyśrodkowane okno (`placePopup`) ze szczegółami obiektu i przyciskiem X.
Future<void> showFacilityDetails(BuildContext context, Facility facility) {
  return showDialog<void>(
    context: context,
    builder: (_) => FacilityDetailsDialog(facility: facility),
  );
}

/// Jedna sekcja szczegółów: tytuł, ikona i akapity tekstu.
class _Section {
  const _Section(this.title, this.icon, this.paragraphs);
  final String title;
  final IconData icon;
  final List<String?> paragraphs;
}

class FacilityDetailsDialog extends StatelessWidget {
  const FacilityDetailsDialog({super.key, required this.facility});
  final Facility facility;

  List<_Section> get _sections {
    final d = facility.details;
    return [
      _Section(DiscoverStrings.sectionParking, Icons.local_parking, [d.parking]),
      _Section(DiscoverStrings.sectionEntrance, Icons.door_front_door_outlined, [d.entrance]),
      _Section(DiscoverStrings.sectionVertical, Icons.elevator_outlined, [d.verticalTransport]),
      _Section(DiscoverStrings.sectionCloakroom, Icons.checkroom_outlined, [d.cloakroom]),
      _Section(DiscoverStrings.sectionRestrooms, Icons.wc, [d.restrooms]),
      _Section(DiscoverStrings.sectionEquipment, Icons.headphones_outlined, [
        d.equipmentRental,
        d.digitalAccess,
      ]),
    ].where((s) => s.paragraphs.any((p) => p != null)).toList();
  }

  void _navigate(BuildContext context) {
    final nav = context.read<NavigationState>();
    Navigator.of(context).pop();
    nav.navigateTo(NavigationTarget(name: facility.name, point: facility.coordinates));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notes = facility.details.notes;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxDialogWidth),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FacilityThumbnail(
                          facility: facility,
                          size: _photoHeight,
                          width: double.infinity,
                          rounded: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                facility.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                '${facility.address} · ${facility.distance}',
                                style: TextStyle(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: Spacing.sm),
                              RatingRow(rating: facility.rating, count: facility.ratingCount),
                              const SizedBox(height: Spacing.md),
                              AccessibilityGradeBadge(facility: facility),
                              const SizedBox(height: Spacing.md),
                              FacilityBadgeWrap(badges: facility.badges),
                              const SizedBox(height: Spacing.sm),
                              FacilityVerificationRow(facility: facility),
                              const SizedBox(height: Spacing.sm),
                              for (final section in _sections) _SectionView(section: section),
                              if (notes != null) _NotesBox(text: notes),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.sm,
                    Spacing.lg,
                    Spacing.lg,
                  ),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text(DiscoverStrings.routeTo),
                    onPressed: () => _navigate(context),
                  ),
                ),
              ],
            ),
            Positioned(
              top: Spacing.sm,
              right: Spacing.sm,
              child: IconButton.filledTonal(
                tooltip: DiscoverStrings.close,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});
  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.xs,
        children: [
          Row(
            spacing: Spacing.sm,
            children: [
              Icon(section.icon, size: 20, color: Theme.of(context).colorScheme.primary),
              Expanded(
                child: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          for (final text in section.paragraphs.whereType<String>()) Text(text),
        ],
      ),
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.lg),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colors.cautionBg,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.xs,
          children: [
            Text(
              DiscoverStrings.importantNotes,
              style: TextStyle(fontWeight: FontWeight.w700, color: colors.caution),
            ),
            Text(text, style: TextStyle(color: colors.caution)),
          ],
        ),
      ),
    );
  }
}
