import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../settings_strings.dart';

/// Wyśrodkowany nagłówek profilu: awatar, imię i dyskretna plakietka statusu.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      spacing: Spacing.xs,
      children: [
        Semantics(
          label: SettingsStrings.profileAvatar,
          child: CircleAvatar(
            radius: 44,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.person, size: 48, color: scheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          SettingsStrings.profileName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(SettingsStrings.profileTitle, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: Spacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Text(
            SettingsStrings.profileStatus,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
