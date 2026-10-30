import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/media/note_image.dart';
import '../../../core/ocr/image_text_reader.dart';
import '../../../core/speech/voice_sheet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/motion.dart';
import '../../editor/editor_screen.dart';
import '../../notes/domain/note_models.dart';
import '../../notes/domain/note_styles.dart';
import '../../notes/state/notes_controller.dart';

Future<void> showCreateNoteSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return const _CreateSheet();
    },
  );
}

class _CreateSheet extends ConsumerWidget {
  const _CreateSheet();

  void _openEditor(
    BuildContext context, {
    CreateIntent intent = CreateIntent.blank,
    Note? existing,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Motion.of(context, Motion.slow),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: EditorScreen(intent: intent, existing: existing),
          );
        },
      ),
    );
  }

  Future<void> _fromPhoto(
    BuildContext context,
    WidgetRef ref, {
    required bool readText,
  }) async {
    final store = ref.read(noteImageStoreProvider);
    final settings = ref.read(settingsProvider);
    final picked = await pickNoteImage(
      context,
      store,
      intent: readText ? ImagePickIntent.readText : ImagePickIntent.attach,
    );
    if (picked == null || !context.mounted) return;

    var scanned = '';
    if (readText) {
      final reader = ImageTextReader();
      if (!reader.isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reading text from photos works on Android and iPhone.'),
          ),
        );
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        try {
          scanned = await reader.read(picked.path);
        } catch (_) {
          scanned = '';
        }
        if (context.mounted) Navigator.pop(context);
        if (context.mounted && scanned.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No words found. Photo added anyway.')),
          );
        }
      }
    }
    if (!context.mounted) return;

    final note = NoteStyles.create(
      id: const Uuid().v4(),
      intent: CreateIntent.blank,
      style: settings.defaultStyle,
      theme: settings.defaultTheme,
      fontId: settings.defaultFontId,
    );
    if (scanned.isNotEmpty) {
      note.primaryText?.content = scanned;
      note.title = scanned.split('\n').first.trim();
      if (note.title.length > 42) {
        note.title = note.title.substring(0, 42);
      }
    }
    note.elements.add(
      ImageElement(
        id: const Uuid().v4(),
        assetPath: picked.path,
        x: 40,
        y: scanned.isEmpty ? 80 : 220,
        width: 280,
        height: 190,
      ),
    );

    Navigator.pop(context);
    _openEditor(context, existing: note);
  }

  Note _noteWithBody(WidgetRef ref, String body) {
    final settings = ref.read(settingsProvider);
    final note = NoteStyles.create(
      id: const Uuid().v4(),
      intent: CreateIntent.blank,
      style: settings.defaultStyle,
      theme: settings.defaultTheme,
      fontId: settings.defaultFontId,
    );
    final trimmed = body.trim();
    if (trimmed.isNotEmpty) {
      note.primaryText?.content = trimmed;
      var title = trimmed.split('\n').first.trim();
      if (title.length > 42) title = title.substring(0, 42);
      note.title = title;
    }
    return note;
  }

  Future<void> _fromVoice(
    BuildContext context,
    WidgetRef ref, {
    required VoiceSheetMode mode,
  }) async {
    final text = await showVoiceSheet(context, mode: mode);
    if (text == null || text.trim().isEmpty || !context.mounted) return;
    Navigator.pop(context);
    _openEditor(context, existing: _noteWithBody(ref, text));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Make something',
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start simple. Style it when the words arrive.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _CreateRow(
                intent: CreateIntent.blank,
                onTap: () {
                  Navigator.pop(context);
                  _openEditor(context, intent: CreateIntent.blank);
                },
              ),
              _SimpleRow(
                icon: Icons.mic_none_rounded,
                title: 'Speak a note',
                subtitle: 'Talk. The words land on the page.',
                onTap: () => _fromVoice(context, ref, mode: VoiceSheetMode.speak),
              ),
              _SimpleRow(
                icon: Icons.graphic_eq_rounded,
                title: 'From a recording',
                subtitle: 'Record now, or pick a voice memo.',
                onTap: () => _fromVoice(context, ref, mode: VoiceSheetMode.recording),
              ),
              _SimpleRow(
                icon: Icons.document_scanner_outlined,
                title: 'From a photo',
                subtitle: 'Read the words on a page into a note.',
                onTap: () => _fromPhoto(context, ref, readText: true),
              ),
              _SimpleRow(
                icon: Icons.add_photo_alternate_outlined,
                title: 'Photo note',
                subtitle: 'Put a picture on the page.',
                onTap: () => _fromPhoto(context, ref, readText: false),
              ),
              for (final intent in CreateIntent.values.where((i) => i != CreateIntent.blank))
                _CreateRow(
                  intent: intent,
                  onTap: () {
                    Navigator.pop(context);
                    _openEditor(context, intent: intent);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateRow extends StatelessWidget {
  const _CreateRow({required this.intent, required this.onTap});

  final CreateIntent intent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = switch (intent) {
      CreateIntent.blank => (
          Icons.crop_portrait_rounded,
          'Blank note',
          'A quiet page. Just you and the words.',
        ),
      CreateIntent.styled => (
          Icons.auto_awesome_outlined,
          'Styled note',
          'Pick a feeling, then write into it.',
        ),
      CreateIntent.handwritten => (
          Icons.gesture_rounded,
          'Handwritten',
          'Ink on yellow paper. Imperfect on purpose.',
        ),
      CreateIntent.drawing => (
          Icons.brush_outlined,
          'Drawing canvas',
          'Start with a line. Words can wait.',
        ),
      CreateIntent.quick => (
          Icons.flash_on_outlined,
          'Quick note',
          'Capture it before it disappears.',
        ),
    };
    return _SimpleRow(
      icon: data.$1,
      title: data.$2,
      subtitle: data.$3,
      onTap: onTap,
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: CircleAvatar(
            backgroundColor: AppColors.copper.withValues(alpha: 0.12),
            foregroundColor: AppColors.copper,
            child: Icon(icon),
          ),
          title: Text(
            title,
            style: GoogleFonts.figtree(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        ),
      ),
    );
  }
}
