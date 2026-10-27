import 'package:flutter/material.dart';

import '../map_strings.dart';
import '../services/voice_input_service.dart';

/// Przycisk mikrofonu: dyktowanie tekstu; podczas nasłuchiwania jest wyróżniony.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key, required this.onResult, required this.onUnavailable});

  /// Rozpoznany tekst (częściowy lub końcowy).
  final void Function(String text, bool isFinal) onResult;
  final VoidCallback onUnavailable;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _voice = VoiceInputService();
  bool _listening = false;

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      await _voice.stop();
      return;
    }
    FocusScope.of(context).unfocus();
    final started = await _voice.start(
      onResult: widget.onResult,
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!mounted) return;
    if (started) {
      setState(() => _listening = true);
    } else {
      widget.onUnavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: _listening ? MapStrings.voiceStop : MapStrings.voiceStart,
      onPressed: _toggle,
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none,
        color: _listening ? scheme.error : scheme.onSurfaceVariant,
      ),
    );
  }
}
