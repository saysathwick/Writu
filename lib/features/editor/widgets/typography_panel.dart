import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../notes/domain/note_fonts.dart';
import '../../notes/domain/note_models.dart';

Future<void> showTypographyPanel(
  BuildContext context, {
  required TextElement text,
  required VoidCallback onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _TypographySheet(text: text, onChanged: onChanged);
    },
  );
}

class _TypographySheet extends StatefulWidget {
  const _TypographySheet({required this.text, required this.onChanged});

  final TextElement text;
  final VoidCallback onChanged;

  @override
  State<_TypographySheet> createState() => _TypographySheetState();
}

class _TypographySheetState extends State<_TypographySheet> {
  FontCategory _category = FontCategory.handwritten;

  TextElement get text => widget.text;

  @override
  void initState() {
    super.initState();
    _category = NoteFonts.byId(text.fontId).category;
  }

  void _touch() {
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fonts = NoteFonts.of(_category);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                'Typography',
                style: GoogleFonts.fraunces(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in FontCategory.values)
                    ChoiceChip(
                      label: Text(_label(cat)),
                      selected: _category == cat,
                      onSelected: (_) => setState(() => _category = cat),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...fonts.map((font) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  selected: text.fontId == font.id,
                  title: Text(
                    font.name,
                    style: font.style(fontSize: 20),
                  ),
                  subtitle: Text(
                    'The quick brown fox',
                    style: font.style(fontSize: 14),
                  ),
                  trailing: text.fontId == font.id
                      ? const Icon(Icons.check_rounded, color: AppColors.copper)
                      : null,
                  onTap: () {
                    text.fontId = font.id;
                    _touch();
                  },
                );
              }),
              const SizedBox(height: 8),
              Text('Size', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: text.fontSize.clamp(12, 48),
                min: 12,
                max: 48,
                onChanged: (v) {
                  text.fontSize = v;
                  _touch();
                },
              ),
              Text('Weight', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: text.fontWeight.clamp(100, 800).toDouble(),
                min: 100,
                max: 800,
                divisions: 7,
                label: '${text.fontWeight}',
                onChanged: (v) {
                  text.fontWeight = (v / 100).round() * 100;
                  _touch();
                },
              ),
              Text('Letter spacing', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: text.letterSpacing.clamp(-1, 4),
                min: -1,
                max: 4,
                onChanged: (v) {
                  text.letterSpacing = v;
                  _touch();
                },
              ),
              Text('Line spacing', style: Theme.of(context).textTheme.labelLarge),
              Slider(
                value: text.lineHeight.clamp(1.0, 2.2),
                min: 1.0,
                max: 2.2,
                onChanged: (v) {
                  text.lineHeight = v;
                  _touch();
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Toggle(
                    icon: Icons.format_italic_rounded,
                    selected: text.italic,
                    label: 'Italic',
                    onTap: () {
                      text.italic = !text.italic;
                      _touch();
                    },
                  ),
                  _Toggle(
                    icon: Icons.format_underline_rounded,
                    selected: text.underline,
                    label: 'Underline',
                    onTap: () {
                      text.underline = !text.underline;
                      _touch();
                    },
                  ),
                  _Toggle(
                    icon: Icons.format_strikethrough_rounded,
                    selected: text.strikethrough,
                    label: 'Strikethrough',
                    onTap: () {
                      text.strikethrough = !text.strikethrough;
                      _touch();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final align in TextAlignKind.values)
                    _Toggle(
                      icon: switch (align) {
                        TextAlignKind.left => Icons.format_align_left_rounded,
                        TextAlignKind.center => Icons.format_align_center_rounded,
                        TextAlignKind.right => Icons.format_align_right_rounded,
                        TextAlignKind.justify => Icons.format_align_justify_rounded,
                      },
                      selected: text.align == align,
                      label: align.name,
                      onTap: () {
                        text.align = align;
                        _touch();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Ink', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final color in _inks)
                    GestureDetector(
                      onTap: () {
                        text.color = colorToArgb(color);
                        _touch();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: argbToColor(text.color) == color
                                ? AppColors.copper
                                : Colors.black12,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(FontCategory cat) {
    return switch (cat) {
      FontCategory.handwritten => 'Handwritten',
      FontCategory.editorial => 'Editorial',
      FontCategory.typewriter => 'Typewriter',
      FontCategory.modern => 'Modern',
      FontCategory.playful => 'Playful',
      FontCategory.classic => 'Classic',
    };
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

const _inks = [
  Color(0xFF1C1410),
  Color(0xFF5C2438),
  Color(0xFF1B3358),
  Color(0xFF1E3B22),
  Color(0xFFC45C26),
  Color(0xFF8B3A2A),
  Color(0xFFF0E6D8),
  Color(0xFF2A1810),
  Color(0xFF3A2458),
  Color(0xFF1A1A1A),
];
