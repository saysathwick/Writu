import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../notes/domain/note_models.dart';
import '../../notes/domain/note_themes.dart';
import '../../notes/presentation/note_backdrop.dart';

Future<void> showThemeBrowser(
  BuildContext context, {
  required NoteThemeId selected,
  required ValueChanged<NoteThemeId> onSelect,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (context, controller) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                const SizedBox(height: 16),
                Text(
                  'Theme',
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The whole page changes — not just a background tint.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                for (final group in NoteThemes.groups) ...[
                  const SizedBox(height: 22),
                  Text(
                    group,
                    style: GoogleFonts.figtree(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                    children: [
                      for (final spec in NoteThemes.ofGroup(group))
                        _ThemeTile(
                          spec: spec,
                          selected: spec.id == selected,
                          onTap: () {
                            onSelect(spec.id);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final NoteThemeSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.copper : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: NoteBackdrop(
                spec: spec,
                seed: spec.id.index,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    'Aa',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      color: spec.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.figtree(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
