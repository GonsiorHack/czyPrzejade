import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../map_constants.dart';
import '../map_strings.dart';
import '../models/waypoint.dart';
import 'voice_input_button.dart';

/// Wysokość jednego wiersza paska (kompaktowa pigułka w stylu Google Maps).
const _rowHeight = 50.0;
const _barRadius = 26.0;

/// Górny pasek wyszukiwania (`topSearchBar`).
/// Stan początkowy: tylko jedna pływająca, półprzezroczysta pigułka "Dokąd?" z mikrofonem.
/// Po wybraniu celu pasek płynnie się rozwija i pokazuje pole "Skąd" (domyślnie GPS).
class TopSearchBar extends StatelessWidget {
  const TopSearchBar({
    super.key,
    required this.startController,
    required this.destinationController,
    required this.expanded,
    required this.busy,
    required this.onSubmit,
    required this.onClear,
    required this.onVoiceUnavailable,
  });

  final TextEditingController startController;
  final TextEditingController destinationController;

  /// Czy pokazać pole "Skąd" (tylko po wybraniu celu).
  final bool expanded;
  final bool busy;
  final void Function(WaypointKind kind, String text) onSubmit;
  final ValueChanged<WaypointKind> onClear;
  final VoidCallback onVoiceUnavailable;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.md, topInset + Spacing.sm, Spacing.md, 0),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(_barRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: AppDurations.sheetResize,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _SearchRow(
                      kind: WaypointKind.start,
                      controller: startController,
                      hint: MapStrings.fromHint,
                      badge: 'A',
                      onSubmit: onSubmit,
                      onClear: onClear,
                    )
                  : const SizedBox(width: double.infinity),
            ),
            _SearchRow(
              kind: WaypointKind.destination,
              controller: destinationController,
              hint: MapStrings.toHint,
              badge: expanded ? 'B' : null,
              onSubmit: onSubmit,
              onClear: onClear,
              onVoiceUnavailable: onVoiceUnavailable,
            ),
            if (busy) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}

/// Jeden wiersz paska: ikona lupy lub odznaka A/B, pole, X (gdy jest tekst) i opcjonalny mikrofon.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.kind,
    required this.controller,
    required this.hint,
    required this.onSubmit,
    required this.onClear,
    this.badge,
    this.onVoiceUnavailable,
  });

  final WaypointKind kind;
  final TextEditingController controller;
  final String hint;
  final String? badge;
  final void Function(WaypointKind kind, String text) onSubmit;
  final ValueChanged<WaypointKind> onClear;
  final VoidCallback? onVoiceUnavailable;

  void _onVoice(String text, bool isFinal) {
    controller.text = text;
    if (isFinal && text.trim().isNotEmpty) onSubmit(kind, text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final voiceUnavailable = onVoiceUnavailable;
    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          const SizedBox(width: Spacing.md),
          badge == null
              ? Icon(Icons.search, color: scheme.onSurfaceVariant)
              : _PlannerBadge(label: badge!),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (text) => onSubmit(kind, text),
                      decoration: InputDecoration(
                        hintText: hint,
                        filled: false,
                        isCollapsed: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                      ),
                    ),
                  ),
                  if (value.text.isNotEmpty)
                    IconButton(
                      tooltip: MapStrings.clearField,
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => onClear(kind),
                    ),
                ],
              ),
            ),
          ),
          if (voiceUnavailable != null)
            VoiceInputButton(onResult: _onVoice, onUnavailable: voiceUnavailable)
          else
            const SizedBox(width: Spacing.sm),
        ],
      ),
    );
  }
}

/// Odznaka "A" / "B" w kolorze marki; oba punkty wyglądają tak samo.
class _PlannerBadge extends StatelessWidget {
  const _PlannerBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MapConstants.plannerBadgeSize,
      height: MapConstants.plannerBadgeSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.brand),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: MapConstants.plannerBadgeSize * 0.45,
        ),
      ),
    );
  }
}
