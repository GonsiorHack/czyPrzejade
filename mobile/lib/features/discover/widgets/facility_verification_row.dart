import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../discover_strings.dart';
import '../models/facility.dart';

/// Informacja o źródle weryfikacji dostępności obiektu (pokazywana w oknie szczegółów).
class FacilityVerificationRow extends StatelessWidget {
  const FacilityVerificationRow({super.key, required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final verified = facility.verified;
    return Row(
      spacing: Spacing.sm,
      children: [
        Icon(
          verified ? Icons.verified : Icons.info_outline,
          size: 18,
          color: verified ? colors.success : colors.caution,
        ),
        Expanded(
          child: Text(
            verified
                ? DiscoverStrings.verifiedBy(facility.verifiedSource)
                : facility.verifiedSource,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
