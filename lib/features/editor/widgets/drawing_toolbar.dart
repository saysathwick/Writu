import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../notes/domain/note_models.dart';

class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    super.key,
    required this.tool,
    required this.color,
    required this.thickness,
    required this.canUndo,
    required this.canRedo,
    required this.onTool,
    required this.onColor,
    required this.onThickness,
    required this.onUndo,
    required this.onRedo,
  });

  final DrawTool tool;
  final Color color;
  final double thickness;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<DrawTool> onTool;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onThickness;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final t in DrawTool.values)
                            _Tool(
                              tool: t,
                              selected: tool == t,
                              onTap: () => onTool(t),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Undo',
                      onPressed: canUndo ? onUndo : null,
                      icon: const Icon(Icons.undo_rounded, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Redo',
                      onPressed: canRedo ? onRedo : null,
                      icon: const Icon(Icons.redo_rounded, size: 20),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text('Stroke', style: GoogleFonts.figtree(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: thickness,
                      min: 1,
                      max: 16,
                      onChanged: onThickness,
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in _palette)
                            GestureDetector(
                              onTap: () => onColor(c),
                              child: Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color == c
                                        ? AppColors.copper
                                        : Colors.black12,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
}

class _Tool extends StatelessWidget {
  const _Tool({required this.tool, required this.selected, required this.onTap});

  final DrawTool tool;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tool) {
      DrawTool.pen => Icons.edit_rounded,
      DrawTool.pencil => Icons.draw_rounded,
      DrawTool.marker => Icons.brush_rounded,
      DrawTool.highlighter => Icons.highlight_rounded,
      DrawTool.eraser => Icons.auto_fix_off_rounded,
    };
    return IconButton(
      tooltip: tool.name,
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
            : null,
      ),
    );
  }
}

const _palette = [
  Color(0xFF1C1410),
  Color(0xFFC45C26),
  Color(0xFF1B3358),
  Color(0xFF1E3B22),
  Color(0xFF8B3A2A),
  Color(0xFFF5E28A),
  Color(0xFFF0E6D8),
];
