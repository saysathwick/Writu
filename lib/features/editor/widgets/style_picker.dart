import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/motion.dart';
import '../../notes/domain/note_models.dart';
import '../../notes/domain/note_styles.dart';
import '../../notes/presentation/note_surface.dart';

class StylePicker extends StatelessWidget {
  const StylePicker({
    super.key,
    required this.note,
    required this.liveText,
    required this.onSelect,
    required this.onDismiss,
  });

  final Note note;
  final String liveText;
  final ValueChanged<StylePreset> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Motion.of(context, Motion.med),
      curve: Motion.ease,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'How should this feel?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fraunces(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(onPressed: onDismiss, child: const Text('Later')),
              ],
            ),
          ),
          StylePreviewStrip(
            note: note,
            liveText: liveText,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

class StylePreviewStrip extends StatelessWidget {
  const StylePreviewStrip({
    super.key,
    required this.note,
    required this.liveText,
    required this.onSelect,
    this.height = 176,
  });

  final Note note;
  final String liveText;
  final ValueChanged<StylePreset> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        scrollDirection: Axis.horizontal,
        itemCount: NoteStyles.presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final preset = NoteStyles.presets[i];
          final preview = Note.fromJson(note.toJson());
          preview.primaryText?.content =
              liveText.trim().isEmpty ? 'A small thought' : liveText;
          preset.applyTo(preview);
          final selected = note.style == preset.kind;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(preset);
            },
            child: SizedBox(
              width: 124,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: Motion.of(context, Motion.fast),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.copper : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: NoteSurface(
                          note: preview,
                          placeholder: 'A small thought',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${preset.emoji}  ${preset.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.figtree(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> showStylePeek(
  BuildContext context, {
  required Note note,
  required String liveText,
  required ValueChanged<StylePreset> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Try this note in another skin',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Long-press any time. Your words stay; the object changes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  StylePreviewStrip(
                    note: note,
                    liveText: liveText,
                    height: 200,
                    onSelect: (preset) {
                      onSelect(preset);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
