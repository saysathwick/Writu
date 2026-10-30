import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/branding/uwrite_mark.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/motion.dart';
import '../notes/state/notes_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      'Write it.',
      'A blank page that already feels like yours — not a form, not a document.',
    ),
    (
      'Style it.',
      'Handwritten, editorial, neon, vintage. The note becomes the object.',
    ),
    (
      'Make it yours.',
      'Draw on it. Pin it. Place it on your home screen, where the platform allows.',
    ),
  ];

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).patch(hasCompletedOnboarding: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              const UwriteMark(size: 28),
              const SizedBox(height: 8),
              Text(
                'Write it. Style it. Make it yours.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Column(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: Motion.of(context, Motion.med),
                            child: CustomPaint(
                              key: ValueKey(i),
                              size: const Size(220, 260),
                              painter: _OnboardPainter(i),
                            ),
                          ),
                        ),
                        Text(
                          page.$1,
                          style: GoogleFonts.fraunces(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page.$2,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: Motion.of(context, Motion.fast),
                      width: _page == i ? 18 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _page == i
                            ? AppColors.copper
                            : AppColors.ink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.copper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_page < _pages.length - 1) {
                      _controller.nextPage(
                        duration: Motion.of(context, Motion.med),
                        curve: Motion.ease,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_page == _pages.length - 1 ? 'Start writing' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPainter extends CustomPainter {
  _OnboardPainter(this.index);
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 150,
      height: 200,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    final colors = [
      const Color(0xFFF6EBD8),
      const Color(0xFFF4C4D0),
      const Color(0xFFC5D8F0),
    ];
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate([-0.06, 0.05, 0.0][index]);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRRect(
      rrect.shift(const Offset(6, 8)),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );
    canvas.drawRRect(rrect, Paint()..color = colors[index]);
    final ink = Paint()
      ..color = const Color(0xFF1C1410).withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (index == 0) {
      canvas.drawLine(Offset(rect.left + 24, rect.top + 48), Offset(rect.right - 28, rect.top + 48), ink);
      canvas.drawLine(Offset(rect.left + 24, rect.top + 72), Offset(rect.right - 48, rect.top + 72), ink);
    } else if (index == 1) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left + 20, rect.top + 30, 70, 18),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFC45C26).withValues(alpha: 0.3),
      );
    } else {
      final path = Path()
        ..moveTo(rect.left + 30, rect.bottom - 70)
        ..quadraticBezierTo(rect.center.dx, rect.top + 40, rect.right - 30, rect.bottom - 50);
      canvas.drawPath(path, ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OnboardPainter oldDelegate) => oldDelegate.index != index;
}
