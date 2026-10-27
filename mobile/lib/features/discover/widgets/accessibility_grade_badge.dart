import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../discover_strings.dart';
import '../models/facility.dart';

/// Kompaktowa, stonowana plakietka oceny dostępności A-F: półprzezroczyste tło,
/// delikatna ramka i kolor oceny tylko na ikonie oraz literze.
class AccessibilityGradeBadge extends StatelessWidget {
  const AccessibilityGradeBadge({super.key, required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final grade = facility.accessibilityGrade;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: DiscoverStrings.accessibilityGradeSemantics(grade.letter),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(Spacing.sm, 2, 2, 2),
        decoration: BoxDecoration(
          color: grade.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: grade.color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.xs,
          children: [
            Icon(Icons.accessible, size: 16, color: grade.color),
            Text(
              DiscoverStrings.accessibilityLabel,
              style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: grade.color, shape: BoxShape.circle),
              child: Text(
                grade.letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
