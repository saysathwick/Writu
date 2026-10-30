import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/branding/uwrite_mark.dart';
import '../../core/theme/app_colors.dart';
import '../notes/domain/note_fonts.dart';
import '../notes/domain/note_models.dart';
import '../notes/domain/note_styles.dart';
import '../notes/domain/note_themes.dart';
import '../notes/state/notes_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notes = ref.watch(notesProvider).notes;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text(
                  'Settings',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Card(
              title: 'Appearance',
              child: RadioGroup<AppThemeMode>(
                groupValue: settings.themeMode,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsProvider.notifier).patch(themeMode: v);
                  }
                },
                child: Column(
                  children: [
                    for (final mode in AppThemeMode.values)
                      RadioListTile<AppThemeMode>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          mode.name[0].toUpperCase() + mode.name.substring(1),
                        ),
                        value: mode,
                      ),
                  ],
                ),
              ),
            ),
            _Card(
              title: 'Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Default style', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final preset in NoteStyles.presets)
                        ChoiceChip(
                          label: Text(preset.label),
                          selected: settings.defaultStyle == preset.kind,
                          onSelected: (_) => ref
                              .read(settingsProvider.notifier)
                              .patch(defaultStyle: preset.kind),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Default font', style: Theme.of(context).textTheme.labelLarge),
                  DropdownButton<String>(
                    value: settings.defaultFontId,
                    isExpanded: true,
                    items: [
                      for (final font in NoteFonts.all)
                        DropdownMenuItem(
                          value: font.id,
                          child: Text(font.name, style: font.style(fontSize: 16)),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        ref.read(settingsProvider.notifier).patch(defaultFontId: id);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Default theme', style: Theme.of(context).textTheme.labelLarge),
                  DropdownButton<NoteThemeId>(
                    value: settings.defaultTheme,
                    isExpanded: true,
                    items: [
                      for (final theme in NoteThemes.all)
                        DropdownMenuItem(
                          value: theme.id,
                          child: Text(theme.name),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        ref.read(settingsProvider.notifier).patch(defaultTheme: id);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Default view', style: Theme.of(context).textTheme.labelLarge),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final view in HomeViewMode.values)
                        ChoiceChip(
                          label: Text(view.name),
                          selected: settings.defaultView == view,
                          onSelected: (_) {
                            ref.read(settingsProvider.notifier).patch(defaultView: view);
                            ref.read(notesProvider.notifier).setViewMode(view);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _Card(
              title: 'Storage',
              child: FutureBuilder(
                future: ref.read(noteRepositoryProvider).storageBytes(),
                builder: (context, snap) {
                  final bytes = snap.data ?? 0;
                  final kb = (bytes / 1024).toStringAsFixed(1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${notes.length} notes · $kb KB on this device'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () async {
                              final bundle =
                                  await ref.read(noteRepositoryProvider).exportAll();
                              await SharePlus.instance.share(ShareParams(text: bundle));
                            },
                            child: const Text('Export backup'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['json'],
                                withData: true,
                              );
                              final bytes = result?.files.single.bytes;
                              if (bytes == null) return;
                              await ref
                                  .read(noteRepositoryProvider)
                                  .importAll(String.fromCharCodes(bytes));
                              await ref.read(notesProvider.notifier).reload();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Imported notes')),
                                );
                              }
                            },
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            _Card(
              title: 'Notifications',
              child: Text(
                'Reminders will live here when they arrive. For now, U-write stays quiet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _Card(
              title: 'U-write+',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A quieter home.',
                    style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium will unlock extra fonts, themes, and a home without ads. Purchases are not available in this build.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show ads'),
                    value: settings.adsEnabled,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).patch(adsEnabled: v),
                  ),
                ],
              ),
            ),
            _Card(
              title: 'About',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UwriteMark(size: 20),
                  const SizedBox(height: 10),
                  const Text('U-write 1.0.1'),
                  const SizedBox(height: 8),
                  Text(
                    'Write it. Style it. Make it yours.',
                    style: GoogleFonts.fraunces(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text('Privacy · Terms · Feedback'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.figtree(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.copper,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
