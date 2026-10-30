import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/note_themes.dart';

class NoteBackdrop extends StatelessWidget {
  const NoteBackdrop({
    super.key,
    required this.spec,
    required this.seed,
    this.child,
    this.borderRadius,
  });

  final NoteThemeSpec spec;
  final int seed;
  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(22);
    Widget painted = CustomPaint(
      painter: _BackdropPainter(spec: spec, seed: seed),
      child: child,
    );
    if (spec.frame == NoteFrame.torn) {
      painted = ClipPath(
        clipper: _TornClipper(seed),
        child: painted,
      );
    } else {
      painted = ClipRRect(borderRadius: radius, child: painted);
    }
    return painted;
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.spec, required this.seed});

  final NoteThemeSpec spec;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (spec.gradient != null) {
      canvas.drawRect(rect, Paint()..shader = spec.gradient!.createShader(rect));
    } else {
      canvas.drawRect(rect, Paint()..color = spec.background);
    }

    switch (spec.pattern) {
      case NotePattern.none:
        break;
      case NotePattern.grid:
        _grid(canvas, size);
      case NotePattern.ruled:
        _ruled(canvas, size, margin: spec.frame == NoteFrame.notebook);
      case NotePattern.dots:
        _dots(canvas, size);
      case NotePattern.grain:
        _grain(canvas, size, density: 0.08);
      case NotePattern.newspaper:
        _newspaper(canvas, size);
      case NotePattern.film:
        _film(canvas, size);
      case NotePattern.doodle:
        _doodle(canvas, size);
      case NotePattern.paint:
        _paintSplat(canvas, size);
      case NotePattern.kraft:
        _kraft(canvas, size);
    }

    if (spec.frame == NoteFrame.polaroid) {
      _polaroid(canvas, size);
    }
    if (spec.frame == NoteFrame.notebook) {
      _notebookMargin(canvas, size);
    }
    if (spec.frame == NoteFrame.tape) {
      _tape(canvas, size);
    }
  }

  void _grid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = spec.ink.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 18.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _ruled(Canvas canvas, Size size, {required bool margin}) {
    final paint = Paint()
      ..color = spec.ink.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    const start = 36.0;
    const gap = 22.0;
    for (double y = start; y < size.height - 8; y += gap) {
      canvas.drawLine(Offset(margin ? 28 : 12, y), Offset(size.width - 12, y), paint);
    }
  }

  void _notebookMargin(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD96A6A).withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(26, 8), Offset(26, size.height - 8), paint);
  }

  void _dots(Canvas canvas, Size size) {
    final paint = Paint()..color = spec.ink.withValues(alpha: 0.12);
    const step = 16.0;
    for (double x = 8; x < size.width; x += step) {
      for (double y = 8; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  void _grain(Canvas canvas, Size size, {required double density}) {
    final rng = math.Random(seed);
    final count = (size.width * size.height * density / 40).round();
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      paint.color = spec.ink.withValues(alpha: rng.nextDouble() * 0.08);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.2,
        paint,
      );
    }
  }

  void _kraft(Canvas canvas, Size size) {
    _grain(canvas, size, density: 0.16);
    final rng = math.Random(seed + 7);
    final fiber = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 18; i++) {
      fiber.color = spec.ink.withValues(alpha: 0.05 + rng.nextDouble() * 0.05);
      final y = rng.nextDouble() * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (rng.nextDouble() - 0.5) * 8),
        fiber,
      );
    }
  }

  void _newspaper(Canvas canvas, Size size) {
    final col = Paint()
      ..color = spec.ink.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.5, 16),
      Offset(size.width * 0.5, size.height - 16),
      col,
    );
    final header = Paint()..color = spec.ink.withValues(alpha: 0.08);
    canvas.drawRect(Rect.fromLTWH(12, 10, size.width - 24, 10), header);
  }

  void _film(Canvas canvas, Size size) {
    final black = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawRect(Rect.fromLTWH(0, 0, 22, size.height), black);
    canvas.drawRect(Rect.fromLTWH(size.width - 22, 0, 22, size.height), black);
    final hole = Paint()..color = const Color(0xFFE8D9A8);
    for (double y = 10; y < size.height; y += 18) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(6, y, 10, 8),
          const Radius.circular(1.5),
        ),
        hole,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - 16, y, 10, 8),
          const Radius.circular(1.5),
        ),
        hole,
      );
    }
  }

  void _doodle(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()
      ..color = spec.ink.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    void scribble(Offset o) {
      final path = Path()..moveTo(o.dx, o.dy);
      for (var i = 0; i < 4; i++) {
        path.relativeQuadraticBezierTo(
          rng.nextDouble() * 12 - 6,
          rng.nextDouble() * 12 - 6,
          rng.nextDouble() * 16 - 4,
          rng.nextDouble() * 10 - 4,
        );
      }
      canvas.drawPath(path, paint);
    }

    scribble(Offset(size.width - 48, 22));
    scribble(Offset(18, size.height - 40));
    canvas.drawCircle(Offset(size.width - 28, size.height - 28), 10, paint);
    canvas.drawLine(
      Offset(22, 18),
      Offset(40, 34),
      paint,
    );
  }

  void _paintSplat(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    const colors = [
      Color(0x66C45C26),
      Color(0x55C4786A),
      Color(0x446E8570),
      Color(0x55E08A4F),
    ];
    for (var i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            rng.nextDouble() * size.width,
            rng.nextDouble() * size.height,
          ),
          width: 40 + rng.nextDouble() * 90,
          height: 30 + rng.nextDouble() * 70,
        ),
        paint,
      );
    }
  }

  void _polaroid(Canvas canvas, Size size) {
    final frame = Paint()..color = const Color(0xFFF7F4EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 14), frame);
    canvas.drawRect(Rect.fromLTWH(0, 0, 14, size.height), frame);
    canvas.drawRect(Rect.fromLTWH(size.width - 14, 0, 14, size.height), frame);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 46, size.width, 46),
      frame,
    );
  }

  void _tape(Canvas canvas, Size size) {
    final tape = Paint()..color = const Color(0x66F3E6B0);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, 8),
            width: 86,
            height: 18,
          ),
          const Radius.circular(2),
        ),
      );
    canvas.drawPath(path, tape);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.spec != spec || oldDelegate.seed != seed;
  }
}

class _TornClipper extends CustomClipper<Path> {
  _TornClipper(this.seed);

  final int seed;

  @override
  Path getClip(Size size) {
    final rng = math.Random(seed);
    final path = Path()..moveTo(0, 8);
    for (double x = 0; x <= size.width; x += 10) {
      path.lineTo(x, rng.nextDouble() * 10);
    }
    path.lineTo(size.width, size.height - 8);
    for (double x = size.width; x >= 0; x -= 10) {
      path.lineTo(x, size.height - rng.nextDouble() * 10);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TornClipper oldClipper) => oldClipper.seed != seed;
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.strokes, this.current});

  final List<StrokeView> strokes;
  final StrokeView? current;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, ?current]) {
      if (stroke.points.length < 2) {
        if (stroke.points.isNotEmpty) {
          canvas.drawCircle(
            stroke.points.first,
            stroke.width / 2,
            _paintFor(stroke),
          );
        }
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, _paintFor(stroke));
    }
  }

  Paint _paintFor(StrokeView stroke) {
    return Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = stroke.highlighter ? BlendMode.multiply : BlendMode.srcOver;
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class StrokeView {
  const StrokeView({
    required this.points,
    required this.color,
    required this.width,
    required this.opacity,
    this.highlighter = false,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final double opacity;
  final bool highlighter;
}
