import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/design_tokens.dart';
import '../map_strings.dart';
import 'report_dialogs.dart';

const _menuWidth = 256.0;
const _photoQuality = 85;

/// Przycisk aparatu do zgłaszania przeszkód: menu -> zdjęcie -> "analiza" -> podziękowanie.
class ReportObstacleButton extends StatefulWidget {
  const ReportObstacleButton({super.key});

  @override
  State<ReportObstacleButton> createState() => _ReportObstacleButtonState();
}

class _ReportObstacleButtonState extends State<ReportObstacleButton> {
  final _picker = ImagePicker();
  bool _menuOpen = false;
  bool _busy = false;

  Future<XFile?> _pickPhoto() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera, imageQuality: _photoQuality);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(MapStrings.reportCameraFailed)));
      }
      return null;
    }
  }

  Future<void> _report() async {
    setState(() => _menuOpen = false);
    final photo = await _pickPhoto();
    if (photo == null || !mounted) return;

    setState(() => _busy = true);
    unawaited(showPhotoProcessingDialog(context));
    await Future<void>.delayed(AppDurations.photoProcessing);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _busy = false);
    await showReportThanksDialog(context, photo.path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_menuOpen) _Menu(onReport: _report),
        FloatingActionButton(
          heroTag: 'report-obstacle',
          tooltip: MapStrings.reportTooltip,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onPressed: _busy ? null : () => setState(() => _menuOpen = !_menuOpen),
          child: const Icon(Icons.photo_camera_outlined),
        ),
      ],
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.onReport});
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: _menuWidth,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: scheme.outline),
        boxShadow: const [
          BoxShadow(color: AppShadows.overlay, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.md,
        children: [
          const Text(MapStrings.reportMenuText, style: TextStyle(fontWeight: FontWeight.w600)),
          FilledButton(onPressed: onReport, child: const Text(MapStrings.reportOpenCamera)),
        ],
      ),
    );
  }
}
