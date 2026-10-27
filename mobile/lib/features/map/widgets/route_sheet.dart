import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/sheet_surface.dart';
import '../map_strings.dart';
import '../models/route_info.dart';
import '../utils/formatters.dart';
import 'route_alternatives.dart';
import 'route_tag_chip.dart';

/// Próg prędkości przeciągnięcia (px/s) rozwijający lub zwijający arkusz.
const _dragVelocityThreshold = 200.0;

/// Dolny arkusz (bottomSheet) z aktywną trasą; przeciągnięcie lub dotknięcie
/// uchwytu pokazuje trasę alternatywną.
class RouteSheet extends StatefulWidget {
  const RouteSheet({
    super.key,
    required this.routes,
    required this.activeRouteId,
    required this.identical,
    required this.navigating,
    required this.onSelect,
    required this.onToggleNavigation,
  });

  final List<RouteInfo> routes;
  final String? activeRouteId;
  final bool identical;
  final bool navigating;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleNavigation;

  @override
  State<RouteSheet> createState() => _RouteSheetState();
}

class _RouteSheetState extends State<RouteSheet> {
  bool _expanded = false;

  RouteInfo get _active => widget.routes.firstWhere(
    (r) => r.id == widget.activeRouteId,
    orElse: () => widget.routes.first,
  );

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -_dragVelocityThreshold) setState(() => _expanded = true);
    if (velocity > _dragVelocityThreshold) setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routes.isEmpty) return const SizedBox.shrink();
    final active = _active;
    final alternatives = widget.routes.where((r) => r.id != active.id).toList();
    final hasAlternative = alternatives.isNotEmpty;

    return GestureDetector(
      onVerticalDragEnd: hasAlternative ? _onDragEnd : null,
      child: SheetSurface(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DragHandle(
                  enabled: hasAlternative,
                  expanded: _expanded,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                _RouteSummary(route: active, identical: widget.identical),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.xs,
                  children: [for (final tag in active.tags) RouteTagChip(tag: tag)],
                ),
                AnimatedSize(
                  duration: AppDurations.sheetResize,
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _expanded && hasAlternative
                      ? Padding(
                          padding: const EdgeInsets.only(top: Spacing.md),
                          child: RouteAlternatives(
                            alternatives: alternatives,
                            active: active,
                            onSelect: widget.onSelect,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: Spacing.md),
                FilledButton.icon(
                  onPressed: widget.onToggleNavigation,
                  icon: Icon(widget.navigating ? Icons.stop : Icons.navigation),
                  label: Text(
                    widget.navigating ? MapStrings.stopNavigation : MapStrings.startNavigation,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.enabled, required this.expanded, required this.onTap});
  final bool enabled;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: enabled,
      label: expanded ? MapStrings.hideAlternative : MapStrings.showAlternative,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(Spacing.xxs),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.route, required this.identical});
  final RouteInfo route;
  final bool identical;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: routeColor(colors, route), shape: BoxShape.circle),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                route.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            Text(
              formatDuration(route.durationMinutes),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          formatDistance(route.distanceMeters),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        if (route.offline) _Note(text: MapStrings.offlineRouteNote, color: colors.caution),
        if (identical) _Note(text: MapStrings.identicalRoutesNote, color: scheme.onSurfaceVariant),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.xs),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );
}
