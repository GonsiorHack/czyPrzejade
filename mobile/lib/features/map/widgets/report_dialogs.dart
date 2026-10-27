import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../app/theme.dart';
import '../map_strings.dart';

/// Dialog z paskiem postępu pokazywany podczas "analizy" zdjęcia (blokuje cofanie).
Future<void> showPhotoProcessingDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: Spacing.lg),
            Expanded(child: Text(MapStrings.reportAnalyzing)),
          ],
        ),
      ),
    ),
  );
}

/// Dialog z podziękowaniem i miniaturą wysłanego zdjęcia.
Future<void> showReportThanksDialog(BuildContext context, String photoPath) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        spacing: Spacing.sm,
        children: [
          Icon(Icons.check_circle, color: ctx.appColors.success),
          const Text(MapStrings.reportThanks),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.md,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: Image.file(
              File(photoPath),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const Text(MapStrings.reportCommunityText, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text(MapStrings.ok)),
      ],
    ),
  );
}
