import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UwriteMark extends StatelessWidget {
  const UwriteMark({
    super.key,
    this.size = 22,
    this.showWordmark = true,
  });

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/branding/uwrite_mark.png',
        width: size * 1.2,
        height: size * 1.2,
        filterQuality: FilterQuality.medium,
      ),
    );
    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        Text(
          'U-write',
          style: GoogleFonts.fraunces(
            fontSize: size,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
