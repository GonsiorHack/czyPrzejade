import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../../../core/navigation_state.dart';
import '../discover_strings.dart';
import '../models/facility.dart';
import 'facility_badges.dart';

const _initialSheetSize = 0.8;
const _maxSheetSize = 0.95;

/// Otwiera arkusz (bottomSheet) ze szczegółami dostępności obiektu.
void showFacilityDetails(BuildContext context, Facility facility) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: _initialSheetSize,
      maxChildSize: _maxSheetSize,
      builder: (_, controller) => FacilityDetailsSheet(facility: facility, controller: controller),
    ),
  );
}

/// Jedna sekcja szczegółów: tytuł, ikona i akapity tekstu.
class _Section {
  const _Section(this.title, this.icon, this.paragraphs);
  final String title;
  final IconData icon;
  final List<String?> paragraphs;
}

class FacilityDetailsSheet extends StatelessWidget {
  const FacilityDetailsSheet({super.key, required this.facility, required this.controller});
  final Facility facility;
  final ScrollController controller;

  List<_Section> get _sections {
    final d = facility.details;
    return [
      _Section(DiscoverStrings.sectionParking, Icons.local_parking, [d.parking]),
      _Section(DiscoverStrings.sectionEntrance, Icons.door_front_door_outlined, [d.entrance]),
      _Section(DiscoverStrings.sectionVertical, Icons.elevator_outlined, [d.verticalTransport]),
      _Section(DiscoverStrings.sectionCloakroom, Icons.checkroom_outlined, [d.cloakroom]),
      _Section(DiscoverStrings.sectionRestrooms, Icons.wc, [d.restrooms]),
      _Section(
        DiscoverStrings.sectionEquipment,
        Icons.headphones_outlined,
        [d.equipmentRental, d.digitalAccess],
      ),
    ].where((s) => s.paragraphs.any((p) => p != null)).toList();
  }

  void _navigate(BuildContext context) {
    Navigator.of(context).pop();
    context.read<NavigationState>().navigateTo(
          NavigationTarget(name: facility.name, point: facility.coordinates),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notes = facility.details.notes;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xl),
      children: [
        Text(
          facility.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '${facility.address} · ${facility.distance}',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Spacing.md),
        FacilityBadgeWrap(badges: facility.badges),
        const SizedBox(height: Spacing.sm),
        for (final section in _sections) _SectionView(section: section),
        if (notes != null) _NotesBox(text: notes),
        const SizedBox(height: 20),
        FilledButton.icon(
          icon: const Icon(Icons.navigation),
          label: const Text(DiscoverStrings.navigate),
          onPressed: () => _navigate(context),
        ),
      ],
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
