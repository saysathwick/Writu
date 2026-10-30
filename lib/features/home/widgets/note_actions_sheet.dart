import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/platform/home_widget_gateway.dart';
import '../../../core/theme/app_colors.dart';
import '../../editor/editor_screen.dart';
import '../../editor/widgets/style_picker.dart';
import '../../editor/widgets/theme_browser.dart';
import '../../notes/domain/note_models.dart';
import '../../notes/state/notes_controller.dart';

Future<void> showNoteActions(
  BuildContext context,
  WidgetRef ref,
  Note note, {
  VoidCallback? onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Text(
                      'Restyle this note',
                      style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                StylePreviewStrip(
                  note: note,
                  liveText: note.body,
                  height: 168,
                  onSelect: (preset) async {
                    preset.applyTo(note);
                    await ref.read(notesProvider.notifier).upsert(note);
                    onChanged?.call();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Action(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorScreen(existing: note),
                          ),
                        );
                      },
                    ),
                    _Action(
                      icon: Icons.copy_outlined,
                      label: 'Duplicate',
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(notesProvider.notifier).duplicate(note);
                      },
                    ),
                    _Action(
                      icon: note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      label: note.isPinned ? 'Unpin' : 'Pin',
                      onTap: () async {
                        note.isPinned = !note.isPinned;
                        await ref.read(notesProvider.notifier).upsert(note);
                        onChanged?.call();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    _Action(
                      icon: note.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: note.isFavorite ? 'Unfavorite' : 'Favorite',
                      onTap: () async {
                        note.isFavorite = !note.isFavorite;
                        await ref.read(notesProvider.notifier).upsert(note);
                        onChanged?.call();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    _Action(
                      icon: Icons.inventory_2_outlined,
                      label: note.isArchived ? 'Unarchive' : 'Archive',
                      onTap: () async {
                        note.isArchived = !note.isArchived;
                        await ref.read(notesProvider.notifier).upsert(note);
                        onChanged?.call();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    _Action(
                      icon: Icons.ios_share_rounded,
                      label: 'Share',
                      onTap: () async {
                        Navigator.pop(context);
                        await SharePlus.instance.share(
                          ShareParams(text: '${note.previewTitle}\n\n${note.body}'),
                        );
                      },
                    ),
                    _Action(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Style',
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          builder: (_) => Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: StylePicker(
                              note: note,
                              liveText: note.body,
                              onSelect: (preset) async {
                                preset.applyTo(note);
                                await ref.read(notesProvider.notifier).upsert(note);
                                onChanged?.call();
                                if (context.mounted) Navigator.pop(context);
                              },
                              onDismiss: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                    _Action(
                      icon: Icons.palette_outlined,
                      label: 'Theme',
                      onTap: () {
                        Navigator.pop(context);
                        showThemeBrowser(
                          context,
                          selected: note.themeId,
                          onSelect: (id) async {
                            note.themeId = id;
                            await ref.read(notesProvider.notifier).upsert(note);
                            onChanged?.call();
                          },
                        );
                      },
                    ),
                    _Action(
                      icon: Icons.add_to_home_screen_rounded,
                      label: 'Home screen',
                      onTap: () async {
                        Navigator.pop(context);
                        note.homeWidgetEnabled = true;
                        await ref.read(notesProvider.notifier).upsert(note);
                        final result =
                            await ref.read(homeWidgetGatewayProvider).placeNote(note);
                        if (context.mounted) {
                          await showHomeWidgetResult(context, result);
                        }
                      },
                    ),
                    _Action(
                      icon: Icons.sell_outlined,
                      label: 'Tag',
                      onTap: () async {
                        Navigator.pop(context);
                        await _editTags(context, ref, note);
                        onChanged?.call();
                      },
                    ),
                    _Action(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      danger: true,
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(notesProvider.notifier).delete(note.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showHomeWidgetResult(BuildContext context, HomeWidgetResult result) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          result.capability == HomeWidgetCapability.publishSnapshot
              ? 'Add it from the gallery'
              : result.ok
                  ? 'Home screen'
                  : 'Couldn’t place the note',
          style: GoogleFonts.fraunces(fontWeight: FontWeight.w600),
        ),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> _editTags(BuildContext context, WidgetRef ref, Note note) async {
  final controller = TextEditingController(text: note.tags.join(', '));
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Tags', style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ideas, home, friday',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (result == null) return;
  note.tags = result
      .split(',')
      .map((t) => t.trim().toLowerCase())
      .where((t) => t.isNotEmpty)
      .toList();
  await ref.read(notesProvider.notifier).upsert(note);
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.wax : Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: 96,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
