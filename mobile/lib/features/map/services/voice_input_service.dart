import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Język rozpoznawania mowy.
const _voiceLocale = 'pl_PL';

/// Cienka nakładka na `speech_to_text`: dyktowanie adresu głosem.
class VoiceInputService {
  final _speech = SpeechToText();
  bool _ready = false;
  VoidCallback? _onDone;

  bool get listening => _speech.isListening;

  /// Rozpoczyna nasłuchiwanie; zwraca `false`, gdy rozpoznawanie mowy jest niedostępne.
  Future<bool> start({
    required void Function(String text, bool isFinal) onResult,
    required VoidCallback onDone,
  }) async {
    _onDone = onDone;
    if (!_ready) {
      _ready = await _speech.initialize(
        onError: (_) => _onDone?.call(),
        onStatus: (status) {
          if (status == SpeechToText.doneStatus || status == SpeechToText.notListeningStatus) {
            _onDone?.call();
          }
        },
      );
    }
    if (!_ready) return false;
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.search,
        localeId: _voiceLocale,
      ),
    );
    return true;
  }

  Future<void> stop() => _speech.stop();

  void dispose() => _speech.cancel();
}
