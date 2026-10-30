import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/note_models.dart';
import '../domain/note_styles.dart';
import '../domain/note_themes.dart';
import 'note_backdrop.dart';

class NoteSurface extends StatelessWidget {
  const NoteSurface({
    super.key,
    required this.note,
    this.interactive = false,
    this.drawMode = false,
    this.textController,
    this.focusNode,
    this.onTextChanged,
    this.currentStroke,
    this.onDrawStart,
    this.onDrawUpdate,
    this.onDrawEnd,
    this.placeholder = "What's on your mind?",
    this.padding,
    this.onRemoveImage,
  });

  final Note note;
  final bool interactive;
  final bool drawMode;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onTextChanged;
  final Stroke? currentStroke;
  final ValueChanged<Offset>? onDrawStart;
  final ValueChanged<Offset>? onDrawUpdate;
  final VoidCallback? onDrawEnd;
  final String placeholder;
  final EdgeInsets? padding;
  final ValueChanged<String>? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final spec = NoteThemes.byId(note.themeId);
    final inner = padding ?? _paddingFor(spec);
    final text = note.primaryText;
    final drawing = note.elements.whereType<DrawingElement>().firstOrNull;
    final stickers = note.elements.whereType<StickerElement>();

    Widget stack = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: NoteBackdrop(
            spec: spec,
            seed: note.id.hashCode,
            borderRadius: BorderRadius.circular(spec.frame == NoteFrame.polaroid ? 6 : 22),
          ),
        ),
        if (text != null)
          Positioned(
            left: text.x,
            top: text.y,
            width: text.width,
            height: text.height,
            child: _textLayer(text, inner),
          ),
        for (final image in note.elements.whereType<ImageElement>())
          Positioned(
            left: image.x,
            top: image.y,
            width: image.width,
            height: image.height,
            child: _NotePhoto(
              image: image,
              canRemove: interactive && onRemoveImage != null,
              onRemove: () => onRemoveImage?.call(image.id),
            ),
          ),
        if (drawing != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !drawMode,
              child: _DrawingLayer(
                drawing: drawing,
                current: currentStroke,
                enabled: drawMode && interactive,
                onStart: onDrawStart,
                onUpdate: onDrawUpdate,
                onEnd: onDrawEnd,
              ),
            ),
          ),
        for (final sticker in stickers)
          Positioned(
            left: sticker.x,
            top: sticker.y,
            width: sticker.width,
            height: sticker.height,
            child: IgnorePointer(
              child: FittedBox(
                child: Text(
                  sticker.glyph,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ),
      ],
    );

    return AspectRatio(
      aspectRatio: note.canvasWidth / note.canvasHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sx = constraints.maxWidth / note.canvasWidth;
          final sy = constraints.maxHeight / note.canvasHeight;
          return ClipRRect(
            borderRadius: BorderRadius.circular(
              spec.frame == NoteFrame.torn ? 0 : 22,
            ),
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: note.canvasWidth,
                height: note.canvasHeight,
                child: Transform.scale(
                  scaleX: 1,
                  scaleY: sy / sx > 0 ? 1 : 1,
                  child: stack,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _paddingFor(NoteThemeSpec spec) {
    if (spec.frame == NoteFrame.polaroid) {
      return const EdgeInsets.fromLTRB(28, 28, 28, 64);
    }
    if (spec.frame == NoteFrame.notebook) {
      return const EdgeInsets.fromLTRB(36, 32, 22, 24);
    }
    return const EdgeInsets.fromLTRB(24, 28, 24, 24);
  }

  Widget _textLayer(TextElement text, EdgeInsets inner) {
    final style = text.textStyle;
    if (!interactive) {
      final content = text.content.trim().isEmpty ? placeholder : text.content;
      return Padding(
        padding: inner,
        child: Text(
          content,
          textAlign: textAlignFrom(text.align),
          style: style.copyWith(
            color: text.content.trim().isEmpty
                ? argbToColor(text.color).withValues(alpha: 0.35)
                : style.color,
          ),
        ),
      );
    }

    return Padding(
      padding: inner,
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        enabled: !drawMode,
        maxLines: null,
        expands: true,
        textAlign: textAlignFrom(text.align),
        style: style,
        cursorColor: argbToColor(text.color),
        onChanged: onTextChanged,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: style.copyWith(
            color: argbToColor(text.color).withValues(alpha: 0.35),
          ),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _NotePhoto extends StatelessWidget {
  const _NotePhoto({
    required this.image,
    required this.canRemove,
    required this.onRemove,
  });

  final ImageElement image;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    Widget picture;
    if (!kIsWeb && File(image.assetPath).existsSync()) {
      picture = Image.file(
        File(image.assetPath),
        fit: BoxFit.cover,
        width: image.width,
        height: image.height,
      );
    } else {
      picture = ColoredBox(
        color: Colors.black.withValues(alpha: 0.06),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 36),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(child: picture),
            if (canRemove)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawingLayer extends StatelessWidget {
  const _DrawingLayer({
    required this.drawing,
    required this.enabled,
    this.current,
    this.onStart,
    this.onUpdate,
    this.onEnd,
  });

  final DrawingElement drawing;
  final Stroke? current;
  final bool enabled;
  final ValueChanged<Offset>? onStart;
  final ValueChanged<Offset>? onUpdate;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final painter = DrawingPainter(
      strokes: drawing.strokes.map(_toView).toList(),
      current: current == null ? null : _toView(current!),
    );
    final paint = CustomPaint(painter: painter, size: Size.infinite);
    if (!enabled) return paint;
    return Listener(
      onPointerDown: (e) => onStart?.call(e.localPosition),
      onPointerMove: (e) => onUpdate?.call(e.localPosition),
      onPointerUp: (_) => onEnd?.call(),
      onPointerCancel: (_) => onEnd?.call(),
      child: paint,
    );
  }

  StrokeView _toView(Stroke stroke) {
    return StrokeView(
      points: stroke.points.map((p) => p.offset).toList(),
      color: argbToColor(stroke.color),
      width: stroke.width,
      opacity: stroke.opacity,
      highlighter: stroke.tool == DrawTool.highlighter,
    );
  }
}

class MiniNoteCard extends StatelessWidget {
  const MiniNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.height,
    this.sticky = false,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? height;
  final bool sticky;

  @override
  Widget build(BuildContext context) {
    final tilt = sticky ? ((note.id.hashCode % 7) - 3) * 0.012 : 0.0;
    return Semantics(
      button: true,
      label: 'Note: ${note.previewTitle}',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Hero(
          tag: 'note-${note.id}',
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: Transform.rotate(
              angle: tilt,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: height,
                      child: NoteSurface(note: note, placeholder: 'A quiet page'),
                    ),
                  ),
                  if (sticky)
                    Positioned(
                      top: -8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Transform.rotate(
                          angle: 0.08,
                          child: Container(
                            width: 42,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0x66F3E6B0),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

