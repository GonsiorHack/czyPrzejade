import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/design_tokens.dart';
import '../../core/settings.dart';
import 'settings_strings.dart';
import 'widgets/city_picker_sheet.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_group.dart';

const _labelStyle = TextStyle(fontWeight: FontWeight.w600);

/// Strona "Ustawienia": motyw, dostępność, profil mobilności i powiadomienia.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.lg,
          Spacing.lg,
          Spacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const ProfileHeader(),
          const SizedBox(height: Spacing.lg),
          Text(
            SettingsStrings.subtitle,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: Spacing.lg),
          _LocationGroup(settings: settings),
          const SizedBox(height: Spacing.lg),
          _AppearanceGroup(settings: settings),
          const SizedBox(height: Spacing.lg),
          _AccessibilityGroup(settings: settings),
          const SizedBox(height: Spacing.lg),
          _MobilityGroup(settings: settings),
          const SizedBox(height: Spacing.lg),
          _NotificationsGroup(settings: settings),
        ],
      ),
    );
  }
}

class _LocationGroup extends StatelessWidget {
  const _LocationGroup({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.location,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.location_city_outlined),
          title: const Text(SettingsStrings.defaultCity, style: _labelStyle),
          subtitle: Text(settings.city.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              showCityPicker(context, selected: settings.city, onSelected: settings.setCity),
        ),
      ],
    );
  }
}

class _AppearanceGroup extends StatelessWidget {
  const _AppearanceGroup({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.appearance,
      children: [
        const Text(SettingsStrings.appTheme, style: _labelStyle),
        const SizedBox(height: Spacing.sm),
        SegmentedButton<AppTheme>(
          segments: const [
            ButtonSegment(
              value: AppTheme.light,
              label: Text(SettingsStrings.themeLight),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: AppTheme.dark,
              label: Text(SettingsStrings.themeDark),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {settings.theme},
          onSelectionChanged: (selection) => settings.setTheme(selection.first),
        ),
      ],
    );
  }
}

class _AccessibilityGroup extends StatelessWidget {
  const _AccessibilityGroup({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.accessibility,
      children: [
        const Text(SettingsStrings.textSize, style: _labelStyle),
        const SizedBox(height: Spacing.sm),
        SegmentedButton<TextSizeOption>(
          segments: [
            for (final option in TextSizeOption.values)
              ButtonSegment(value: option, label: Text(option.label)),
          ],
          selected: {settings.textSize},
          onSelectionChanged: (selection) => settings.setTextSize(selection.first),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(SettingsStrings.highContrast, style: _labelStyle),
          subtitle: const Text(SettingsStrings.highContrastHint),
          value: settings.highContrast,
          onChanged: settings.setHighContrast,
        ),
      ],
    );
  }
}

class _MobilityGroup extends StatelessWidget {
  const _MobilityGroup({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.mobilityProfile,
      children: [
        RadioGroup<MobilityProfile>(
          groupValue: settings.mobilityProfile,
          onChanged: (profile) {
            if (profile != null) settings.setMobilityProfile(profile);
          },
          child: Column(
            children: [
              for (final profile in MobilityProfile.values)
                RadioListTile<MobilityProfile>(
                  contentPadding: EdgeInsets.zero,
                  value: profile,
                  title: Text(profile.label),
                  subtitle: Text(profile.description),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsGroup extends StatelessWidget {
  const _NotificationsGroup({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.notifications,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(SettingsStrings.transitAlerts, style: _labelStyle),
          subtitle: const Text(SettingsStrings.transitAlertsHint),
          value: settings.visualTransitAlerts,
          onChanged: settings.setVisualTransitAlerts,
        ),
        Text(
          SettingsStrings.transitAlertsNote,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}
