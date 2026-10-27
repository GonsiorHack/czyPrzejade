import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../map_constants.dart';
import '../map_strings.dart';
import '../models/waypoint.dart';
import 'map_markers.dart';

/// Górna nakładka z polami adresu "Skąd" / "Dokąd".
class RoutePlannerPanel extends StatelessWidget {
  const RoutePlannerPanel({
    super.key,
    required this.startController,
    required this.destinationController,
    required this.busy,
    required this.onSubmit,
    required this.onUseLocation,
    required this.onReset,
  });

  final TextEditingController startController;
  final TextEditingController destinationController;
  final bool busy;
  final void Function(WaypointKind kind, String text) onSubmit;
  final VoidCallback onUseLocation;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
      elevation: 4,
      shadowColor: AppShadows.overlay,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.md, 10, Spacing.sm, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            _AddressRow(
              kind: WaypointKind.start,
              controller: startController,
              hint: MapStrings.fromHint,
              onSubmit: onSubmit,
              actionIcon: Icons.my_location,
              actionTooltip: MapStrings.useMyLocation,
              onAction: busy ? null : onUseLocation,
            ),
            _AddressRow(
              kind: WaypointKind.destination,
              controller: destinationController,
              hint: MapStrings.toHint,
              onSubmit: onSubmit,
              actionIcon: Icons.close,
              actionTooltip: MapStrings.clearRoute,
              onAction: onReset,
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.only(top: 6, right: Spacing.xs),
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.kind,
    required this.controller,
    required this.hint,
    required this.onSubmit,
    required this.actionIcon,
    required this.actionTooltip,
    required this.onAction,
  });

  final WaypointKind kind;
  final TextEditingController controller;
  final String hint;
  final void Function(WaypointKind kind, String text) onSubmit;
  final IconData actionIcon;
  final String actionTooltip;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Spacing.sm,
      children: [
        MapMarkerBadge(kind: kind, size: MapConstants.plannerBadgeSize),
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (text) => onSubmit(kind, text),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              suffixIcon: IconButton(
                tooltip: MapStrings.search,
                icon: const Icon(Icons.search, size: 20),
                onPressed: () => onSubmit(kind, controller.text),
              ),
            ),
          ),
        ),
        IconButton(tooltip: actionTooltip, onPressed: onAction, icon: Icon(actionIcon)),
      ],
    );
  }
}
