import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ads/sponsored_card.dart';
import '../../core/branding/uwrite_mark.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/motion.dart';
import '../editor/editor_screen.dart';
import '../notes/domain/note_models.dart';
import '../notes/presentation/note_surface.dart';
import '../notes/state/notes_controller.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/create_note_sheet.dart';
import 'widgets/note_actions_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final ads = ref.watch(adServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            _Filters(
              filter: state.filter,
              tags: state.allTags,
              selectedTag: state.selectedTag,
            ),
            Expanded(
              child: state.loading
                  ? const Center(child: _LoadingMark())
                  : state.visible.isEmpty
                      ? _EmptyGallery(showAd: ads.adsEnabled)
                      : _Gallery(
                          notes: state.visible,
                          viewMode: state.viewMode,
                          insertAfter: (i) =>
                              ads.shouldInsertAfterNote(i, state.visible.length),
                        ),
            ),
            if (ads.adsEnabled)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(height: 72, child: SponsoredCard(compact: true)),
              ),
            const _ThumbDock(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 10, 22, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: UwriteMark(size: 32),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({
    required this.filter,
    required this.tags,
    required this.selectedTag,
  });

  final NoteFilter filter;
  final List<String> tags;
  final String? selectedTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
        scrollDirection: Axis.horizontal,
        children: [
          for (final f in NoteFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_filterLabel(f)),
                selected: filter == f,
                onSelected: (_) => ref.read(notesProvider.notifier).setFilter(f),
              ),
            ),
          for (final tag in tags)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('#$tag'),
                selected: selectedTag == tag,
                onSelected: (v) =>
                    ref.read(notesProvider.notifier).setTag(v ? tag : null),
              ),
            ),
        ],
      ),
    );
  }

  String _filterLabel(NoteFilter f) {
    return switch (f) {
      NoteFilter.all => 'All',
      NoteFilter.pinned => 'Pinned',
      NoteFilter.favorites => 'Loved',
      NoteFilter.archived => 'Archive',
    };
  }
}

class _Gallery extends ConsumerWidget {
  const _Gallery({
    required this.notes,
    required this.viewMode,
    required this.insertAfter,
  });

  final List<Note> notes;
  final HomeViewMode viewMode;
  final bool Function(int noteIndex) insertAfter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <Object>[];
    for (var i = 0; i < notes.length; i++) {
      items.add(notes[i]);
      if (insertAfter(i)) {
        items.add('ad-$i');
      }
    }

    if (viewMode == HomeViewMode.list) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) => _tile(context, ref, items[i], 176),
      );
    }

    if (viewMode == HomeViewMode.large) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 18),
        itemBuilder: (context, i) => _tile(context, ref, items[i], 380),
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 12,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final height = item is Note ? 200.0 + (item.id.hashCode.abs() % 80) : 168.0;
        return _tile(context, ref, item, height);
      },
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, Object item, double height) {
    if (item is String) {
      return SizedBox(height: height, child: const SponsoredCard());
    }
    final note = item as Note;
    return SizedBox(
      height: height,
      child: MiniNoteCard(
        note: note,
        sticky: true,
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Motion.of(context, Motion.slow),
              pageBuilder: (_, animation, _) {
                return FadeTransition(
                  opacity: animation,
                  child: EditorScreen(existing: note),
                );
              },
            ),
          );
        },
        onLongPress: () => showNoteActions(context, ref, note),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.showAd});

  final bool showAd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
      children: [
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 180,
            height: 140,
            child: CustomPaint(painter: _EmptyPainter()),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your thoughts are waiting.',
          textAlign: TextAlign.center,
          style: GoogleFonts.fraunces(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Write it. Style it. Make it yours.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 22),
        Center(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => showCreateNoteSheet(context),
            child: const Text('Create your first note'),
          ),
        ),
        if (showAd) ...[
          const SizedBox(height: 28),
          const SizedBox(height: 160, child: SponsoredCard()),
        ],
      ],
    );
  }
}

class _EmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void card(Rect rect, Color color, double rot) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(rot);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      final r = RRect.fromRectAndRadius(rect, const Radius.circular(16));
      canvas.drawRRect(
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.08),
      );
      canvas.drawRRect(r.shift(const Offset(-2, -3)), Paint()..color = color);
      canvas.restore();
    }

    card(const Rect.fromLTWH(18, 28, 90, 110), const Color(0xFFF5E28A), -0.12);
    card(const Rect.fromLTWH(70, 10, 100, 120), const Color(0xFFF4C4D0), 0.08);
    card(const Rect.fromLTWH(40, 40, 96, 92), const Color(0xFFF6EBD8), -0.02);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThumbDock extends ConsumerWidget {
  const _ThumbDock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(notesProvider).viewMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              _DockIcon(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, _) => FadeTransition(
                        opacity: animation,
                        child: const SearchScreen(),
                      ),
                    ),
                  );
                },
              ),
              _DockIcon(
                icon: switch (mode) {
                  HomeViewMode.grid => Icons.grid_view_rounded,
                  HomeViewMode.list => Icons.view_agenda_rounded,
                  HomeViewMode.large => Icons.crop_portrait_rounded,
                },
                label: 'View',
                onTap: () {
                  const order = HomeViewMode.values;
                  final next = order[(mode.index + 1) % order.length];
                  ref.read(notesProvider.notifier).setViewMode(next);
                },
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Create a note',
                child: GestureDetector(
                  onTap: () => showCreateNoteSheet(context),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.copper,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.copper.withValues(alpha: 0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                  ),
                ),
              ),
              const Spacer(),
              _DockIcon(
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 24),
    );
  }
}

class _LoadingMark extends StatelessWidget {
  const _LoadingMark();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UwriteMark(),
        SizedBox(height: 16),
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}
