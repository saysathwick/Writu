import 'package:flutter/material.dart';

import 'note_fonts.dart';
import 'note_models.dart';
import 'note_themes.dart';

class StylePreset {
  const StylePreset({
    required this.kind,
    required this.label,
    required this.emoji,
    required this.blurb,
    required this.themeId,
    required this.fontId,
    required this.fontSize,
    this.fontWeight = 400,
    this.letterSpacing = 0,
    this.lineHeight = 1.35,
    this.italic = false,
    this.sticker,
  });

  final NoteStyleKind kind;
  final String label;
  final String emoji;
  final String blurb;
  final NoteThemeId themeId;
  final String fontId;
  final double fontSize;
  final int fontWeight;
  final double letterSpacing;
  final double lineHeight;
  final bool italic;
  final String? sticker;

  void applyTo(Note note) {
    note.style = kind;
    note.themeId = themeId;
    final text = note.primaryText;
    if (text != null) {
      text.fontId = fontId;
      text.fontSize = fontSize;
      text.fontWeight = fontWeight;
      text.letterSpacing = letterSpacing;
      text.lineHeight = lineHeight;
      text.italic = italic;
      text.color = colorToArgb(NoteThemes.byId(themeId).ink);
    }
    if (sticker != null &&
        !note.elements.whereType<StickerElement>().any((s) => s.glyph == sticker)) {
      note.elements.add(
        StickerElement(
          id: 'sticker-${note.id}',
          glyph: sticker!,
          x: 310,
          y: 18,
          width: 56,
          height: 56,
        ),
      );
    }
  }
}

abstract final class NoteStyles {
  static const presets = [
    StylePreset(
      kind: NoteStyleKind.handwritten,
      label: 'Handwritten',
      emoji: '✍️',
      blurb: 'A sticky thought, dashed off in ink.',
      themeId: NoteThemeId.softYellow,
      fontId: 'caveat',
      fontSize: 26,
      lineHeight: 1.2,
      sticker: '☀',
    ),
    StylePreset(
      kind: NoteStyleKind.journal,
      label: 'Journal',
      emoji: '📖',
      blurb: 'Quiet pages. Ruled, personal.',
      themeId: NoteThemeId.ruledPaper,
      fontId: 'lora',
      fontSize: 18,
      italic: true,
      lineHeight: 1.55,
    ),
    StylePreset(
      kind: NoteStyleKind.editorial,
      label: 'Editorial',
      emoji: '📰',
      blurb: 'Magazine energy. A headline that lands.',
      themeId: NoteThemeId.whitePaper,
      fontId: 'playfair',
      fontSize: 22,
      fontWeight: 600,
      lineHeight: 1.3,
    ),
    StylePreset(
      kind: NoteStyleKind.typewriter,
      label: 'Typewriter',
      emoji: '⌨️',
      blurb: 'Clack. Ribbon. A page from another decade.',
      themeId: NoteThemeId.vintage,
      fontId: 'specialElite',
      fontSize: 17,
      letterSpacing: 0.4,
      lineHeight: 1.5,
    ),
    StylePreset(
      kind: NoteStyleKind.playful,
      label: 'Playful',
      emoji: '✨',
      blurb: 'Rounded, bright, a little mischievous.',
      themeId: NoteThemeId.pink,
      fontId: 'fredoka',
      fontSize: 20,
      sticker: '✦',
    ),
    StylePreset(
      kind: NoteStyleKind.minimal,
      label: 'Minimal',
      emoji: '🧊',
      blurb: 'Space to breathe. Nothing extra.',
      themeId: NoteThemeId.whitePaper,
      fontId: 'outfit',
      fontSize: 18,
      fontWeight: 400,
      lineHeight: 1.45,
    ),
    StylePreset(
      kind: NoteStyleKind.dark,
      label: 'Dark',
      emoji: '🌙',
      blurb: 'Night desk. Neon hush.',
      themeId: NoteThemeId.black,
      fontId: 'outfit',
      fontSize: 18,
      fontWeight: 500,
    ),
    StylePreset(
      kind: NoteStyleKind.colorful,
      label: 'Colorful',
      emoji: '🌈',
      blurb: 'A wash of color behind the words.',
      themeId: NoteThemeId.gradient,
      fontId: 'comfortaa',
      fontSize: 18,
    ),
    StylePreset(
      kind: NoteStyleKind.vintage,
      label: 'Vintage',
      emoji: '📜',
      blurb: 'Sun-faded kraft and serif type.',
      themeId: NoteThemeId.kraftPaper,
      fontId: 'libre',
      fontSize: 17,
      lineHeight: 1.5,
    ),
    StylePreset(
      kind: NoteStyleKind.artistic,
      label: 'Artistic',
      emoji: '🎨',
      blurb: 'A sketchbook page that still has paint on it.',
      themeId: NoteThemeId.paint,
      fontId: 'dancing',
      fontSize: 24,
      sticker: '✿',
    ),
  ];

  static StylePreset byKind(NoteStyleKind kind) {
    return presets.firstWhere((p) => p.kind == kind);
  }

  static Note create({
    required String id,
    required CreateIntent intent,
    NoteStyleKind? style,
    NoteThemeId? theme,
    String? fontId,
  }) {
    final now = DateTime.now();
    final preset = byKind(style ?? _styleForIntent(intent));
    final note = Note(
      id: id,
      createdAt: now,
      updatedAt: now,
      themeId: theme ?? preset.themeId,
      style: preset.kind,
      elements: [
        TextElement(
          id: 'text-$id',
          content: '',
          fontId: fontId ?? preset.fontId,
          fontSize: preset.fontSize,
          fontWeight: preset.fontWeight,
          italic: preset.italic,
          letterSpacing: preset.letterSpacing,
          lineHeight: preset.lineHeight,
          color: colorToArgb(NoteThemes.byId(theme ?? preset.themeId).ink),
        ),
        DrawingElement(id: 'drawing-$id'),
      ],
    );
    if (preset.sticker != null && intent != CreateIntent.blank) {
      note.elements.add(
        StickerElement(
          id: 'sticker-$id',
          glyph: preset.sticker!,
          x: 310,
          y: 18,
        ),
      );
    }
    if (intent == CreateIntent.blank) {
      note.themeId = theme ?? NoteThemeId.whitePaper;
      note.style = NoteStyleKind.minimal;
      final text = note.primaryText!;
      text.fontId = fontId ?? 'outfit';
      text.fontSize = 18;
      text.italic = false;
      text.color = colorToArgb(NoteThemes.byId(note.themeId).ink);
      note.elements.removeWhere((e) => e is StickerElement);
    }
    return note;
  }

  static NoteStyleKind _styleForIntent(CreateIntent intent) {
    return switch (intent) {
      CreateIntent.blank => NoteStyleKind.minimal,
      CreateIntent.styled => NoteStyleKind.journal,
      CreateIntent.handwritten => NoteStyleKind.handwritten,
      CreateIntent.drawing => NoteStyleKind.artistic,
      CreateIntent.quick => NoteStyleKind.handwritten,
    };
  }
}

extension NoteFontStyle on TextElement {
  TextStyle get textStyle {
    final font = NoteFonts.byId(fontId);
    return font.style(
      fontSize: fontSize,
      fontWeight: fontWeightFrom(fontWeight),
      italic: italic,
      letterSpacing: letterSpacing,
      height: lineHeight,
      color: argbToColor(color),
      underline: underline,
      strikethrough: strikethrough,
    );
  }
}
