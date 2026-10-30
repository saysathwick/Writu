import 'package:flutter/material.dart';

import 'note_models.dart';

enum NotePattern {
  none,
  grid,
  ruled,
  dots,
  grain,
  newspaper,
  film,
  doodle,
  paint,
  kraft,
}

enum NoteFrame { none, torn, polaroid, tape, notebook }

class NoteThemeSpec {
  const NoteThemeSpec({
    required this.id,
    required this.name,
    required this.group,
    required this.background,
    required this.ink,
    required this.muted,
    this.secondary = const Color(0x00000000),
    this.pattern = NotePattern.none,
    this.frame = NoteFrame.none,
    this.gradient,
    this.premium = false,
  });

  final NoteThemeId id;
  final String name;
  final String group;
  final Color background;
  final Color ink;
  final Color muted;
  final Color secondary;
  final NotePattern pattern;
  final NoteFrame frame;
  final Gradient? gradient;
  final bool premium;
}

abstract final class NoteThemes {
  static const groups = ['Paper', 'Color', 'Artistic'];

  static final List<NoteThemeSpec> all = [
    const NoteThemeSpec(
      id: NoteThemeId.whitePaper,
      name: 'White paper',
      group: 'Paper',
      background: Color(0xFFFEFCF8),
      ink: Color(0xFF1A1714),
      muted: Color(0xFF6B6258),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.creamPaper,
      name: 'Cream paper',
      group: 'Paper',
      background: Color(0xFFF6EBD8),
      ink: Color(0xFF3A2F24),
      muted: Color(0xFF7A6A58),
      pattern: NotePattern.grain,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.gridPaper,
      name: 'Grid paper',
      group: 'Paper',
      background: Color(0xFFF8F4EC),
      ink: Color(0xFF243848),
      muted: Color(0xFF5C7180),
      pattern: NotePattern.grid,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.ruledPaper,
      name: 'Ruled paper',
      group: 'Paper',
      background: Color(0xFFFFF9F0),
      ink: Color(0xFF1F2933),
      muted: Color(0xFF66788A),
      pattern: NotePattern.ruled,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.notebook,
      name: 'Notebook',
      group: 'Paper',
      background: Color(0xFFF4F0E6),
      ink: Color(0xFF222222),
      muted: Color(0xFF6A655C),
      pattern: NotePattern.ruled,
      frame: NoteFrame.notebook,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.tornPaper,
      name: 'Torn paper',
      group: 'Paper',
      background: Color(0xFFF3E6C8),
      ink: Color(0xFF3D2B1F),
      muted: Color(0xFF8A7058),
      pattern: NotePattern.grain,
      frame: NoteFrame.torn,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.kraftPaper,
      name: 'Kraft paper',
      group: 'Paper',
      background: Color(0xFFC4A574),
      ink: Color(0xFF2A1810),
      muted: Color(0xFF5C4030),
      pattern: NotePattern.kraft,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.softYellow,
      name: 'Soft yellow',
      group: 'Color',
      background: Color(0xFFF5E28A),
      ink: Color(0xFF3D3415),
      muted: Color(0xFF7A6A28),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.pink,
      name: 'Pink',
      group: 'Color',
      background: Color(0xFFF4C4D0),
      ink: Color(0xFF5C2438),
      muted: Color(0xFF8A4A60),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.blue,
      name: 'Blue',
      group: 'Color',
      background: Color(0xFFC5D8F0),
      ink: Color(0xFF1B3358),
      muted: Color(0xFF4A6A90),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.green,
      name: 'Green',
      group: 'Color',
      background: Color(0xFFCDE5C8),
      ink: Color(0xFF1E3B22),
      muted: Color(0xFF4A7048),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.lavender,
      name: 'Lavender',
      group: 'Color',
      background: Color(0xFFDCC9F0),
      ink: Color(0xFF3A2458),
      muted: Color(0xFF6A5090),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.orange,
      name: 'Orange',
      group: 'Color',
      background: Color(0xFFF5C18A),
      ink: Color(0xFF5C2E10),
      muted: Color(0xFF8A5830),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.black,
      name: 'Black',
      group: 'Color',
      background: Color(0xFF141414),
      ink: Color(0xFFF0E6D8),
      muted: Color(0xFFB8A898),
    ),
    NoteThemeSpec(
      id: NoteThemeId.paint,
      name: 'Paint',
      group: 'Artistic',
      background: const Color(0xFFE8D5C4),
      ink: const Color(0xFF2A1810),
      muted: const Color(0xFF7A5848),
      pattern: NotePattern.paint,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.grain,
      name: 'Grain',
      group: 'Artistic',
      background: Color(0xFFEDE4D4),
      ink: Color(0xFF2C2418),
      muted: Color(0xFF6A6050),
      pattern: NotePattern.grain,
    ),
    NoteThemeSpec(
      id: NoteThemeId.gradient,
      name: 'Gradient',
      group: 'Artistic',
      background: const Color(0xFFF3D5C4),
      ink: const Color(0xFF3A2048),
      muted: const Color(0xFF6A4870),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF6C9A8), Color(0xFFE0B8F0), Color(0xFFB8D4F0)],
      ),
    ),
    const NoteThemeSpec(
      id: NoteThemeId.doodle,
      name: 'Doodle',
      group: 'Artistic',
      background: Color(0xFFF7EFE2),
      ink: Color(0xFF2A2218),
      muted: Color(0xFF6A5C48),
      pattern: NotePattern.doodle,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.vintage,
      name: 'Vintage',
      group: 'Artistic',
      background: Color(0xFFE8D5B5),
      ink: Color(0xFF4A3018),
      muted: Color(0xFF8A6A40),
      pattern: NotePattern.grain,
      premium: true,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.newspaper,
      name: 'Newspaper',
      group: 'Artistic',
      background: Color(0xFFE7E1D4),
      ink: Color(0xFF1A1A1A),
      muted: Color(0xFF5A5A52),
      pattern: NotePattern.newspaper,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.film,
      name: 'Film',
      group: 'Artistic',
      background: Color(0xFF1A1A1A),
      ink: Color(0xFFF2E6C8),
      muted: Color(0xFFB8A878),
      pattern: NotePattern.film,
      premium: true,
    ),
    const NoteThemeSpec(
      id: NoteThemeId.polaroid,
      name: 'Polaroid',
      group: 'Artistic',
      background: Color(0xFFF2F0EA),
      ink: Color(0xFF2A241C),
      muted: Color(0xFF6A6058),
      frame: NoteFrame.polaroid,
    ),
  ];

  static NoteThemeSpec byId(NoteThemeId id) {
    return all.firstWhere((t) => t.id == id);
  }

  static List<NoteThemeSpec> ofGroup(String group) {
    return all.where((t) => t.group == group).toList();
  }
}
