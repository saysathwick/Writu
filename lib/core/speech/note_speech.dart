import 'package:speech_to_text/speech_to_text.dart';

String mergeSpoken(String existing, String spoken) {
  final left = existing.trimRight();
  final right = spoken.trim();
  if (right.isEmpty) return existing;
  if (left.isEmpty) return right;
  if (left.endsWith('\n')) return '$left$right';
  return '$left $right';
}

class NoteSpeech {
  final SpeechToText _stt = SpeechToText();

  bool _initialized = false;
  bool _wantListening = false;
  String _sessionBase = '';
  void Function(String text)? _onLive;
  void Function(String message)? _onError;

  bool get isListening => _stt.isListening;

  Future<bool> prepare() async {
    if (_initialized) return _stt.isAvailable;
    _initialized = true;
    return _stt.initialize(
      onStatus: (status) {
        if (!_wantListening) return;
        if (status == 'done' || status == 'notListening') {
          _listen();
        }
      },
      onError: (error) {
        if (error.permanent) {
          _wantListening = false;
          _onError?.call('Could not hear that. Try again.');
        }
      },
    );
  }

  Future<void> start({
    required String existingText,
    required void Function(String text) onLive,
    void Function(String message)? onError,
  }) async {
    _sessionBase = existingText;
    _onLive = onLive;
    _onError = onError;
    final ready = await prepare();
    if (!ready) {
      onError?.call('Speech is not available on this device.');
      return;
    }
    _wantListening = true;
    await _listen();
  }

  Future<void> _listen() async {
    if (!_wantListening || _stt.isListening) return;
    await _stt.listen(
      onResult: (result) {
        final spoken = result.recognizedWords.trim();
        _onLive?.call(mergeSpoken(_sessionBase, spoken));
        if (result.finalResult && spoken.isNotEmpty) {
          _sessionBase = mergeSpoken(_sessionBase, spoken);
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        autoPunctuation: true,
        listenFor: const Duration(minutes: 3),
        pauseFor: const Duration(seconds: 8),
      ),
    );
  }

  Future<void> stop() async {
    _wantListening = false;
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  Future<void> cancel() async {
    _wantListening = false;
    if (_stt.isListening) {
      await _stt.cancel();
    }
  }
}
