import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../models/route_info.dart';

/// Chip z cechą trasy (np. "Bez schodów"); kolor zależy od [TagTone].
class RouteTagChip extends StatelessWidget {
  const RouteTagChip({super.key, required this.tag});
  final RouteTag tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final positive = tag.tone == TagTone.positive;
    final foreground = positive ? colors.success : colors.caution;
    final background = positive ? colors.successBg : colors.cautionBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: foreground.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.xs,
        children: [
          Icon(
            positive ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 14,
            color: foreground,
          ),
          Text(
            tag.label,
            style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
