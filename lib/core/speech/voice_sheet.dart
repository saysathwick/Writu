import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'note_speech.dart';

enum VoiceSheetMode { speak, recording }

Future<String?> showVoiceSheet(
  BuildContext context, {
  required VoiceSheetMode mode,
  String existingText = '',
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _VoiceSheet(
      mode: mode,
      existingText: existingText,
    ),
  );
}

class _VoiceSheet extends StatefulWidget {
  const _VoiceSheet({
    required this.mode,
    required this.existingText,
  });

  final VoiceSheetMode mode;
  final String existingText;

  @override
  State<_VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends State<_VoiceSheet> {
  final _speech = NoteSpeech();
  String _live = '';
  bool _listening = false;
  String _status = '';

  bool get _isSpeak => widget.mode == VoiceSheetMode.speak;

  @override
  void initState() {
    super.initState();
    if (_isSpeak) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startListen());
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _startListen({String? prompt}) async {
    setState(() {
      _listening = true;
      _status = prompt ?? 'Listening…';
    });
    await _speech.start(
      existingText: widget.existingText,
      onLive: (text) {
        if (!mounted) return;
        setState(() {
          _live = text;
          _status = 'Listening…';
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _status = message;
        });
      },
    );
  }

  Future<void> _stopListen() async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _pickRecording() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (picked == null || !mounted) return;
    await _startListen(
      prompt: 'Play that recording near the microphone.',
    );
  }

  void _useText() {
    final text = _live.trim();
    Navigator.pop(context, text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isSpeak ? 'Speak a note' : 'From a recording';
    final blurb = _isSpeak
        ? 'Talk. The words land on the page.'
        : 'Record by talking, or play a voice memo into the mic.';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(blurb, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: _listening ? _stopListen : () => _startListen(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _listening
                            ? AppColors.blush
                            : AppColors.copper.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _listening ? Icons.stop_rounded : Icons.mic_none_rounded,
                        size: 36,
                        color: _listening ? Colors.white : AppColors.copper,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _listening ? 'Listening… tap to stop' : 'Tap to record',
                    style: GoogleFonts.figtree(fontWeight: FontWeight.w600),
                  ),
                ),
                if (!_isSpeak) ...[
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(Icons.audio_file_outlined),
                      title: const Text('Choose a recording'),
                      subtitle: const Text('Then play it near the microphone'),
                      onTap: _listening ? null : _pickRecording,
                    ),
                  ),
                ],
                if (_live.isNotEmpty || _status.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                    child: Text(
                      _live.isNotEmpty ? _live : _status,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _useText,
                      child: const Text('Use text'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
