import 'package:flutter/material.dart';

/// Warm paper-and-ink, tuned for a current-generation consumer app.
abstract final class AppColors {
  static const paper = Color(0xFFF7F1E8);
  static const paperDeep = Color(0xFFE8DCCB);
  static const linen = Color(0xFFFFFBF6);
  static const ink = Color(0xFF17120E);
  static const inkSoft = Color(0xFF6A5E54);
  static const copper = Color(0xFFE85D04);
  static const copperSoft = Color(0xFFFF8A3D);
  static const sage = Color(0xFF5C7A62);
  static const blush = Color(0xFFE06C75);
  static const wax = Color(0xFF9B2C2C);
  static const adSlate = Color(0xFF1E2430);
  static const adMint = Color(0xFF7CFFCB);

  static const darkEspresso = Color(0xFF12100E);
  static const darkPanel = Color(0xFF1E1A17);
  static const darkCard = Color(0xFF2A241F);
  static const cream = Color(0xFFF6EBDD);
}

abstract final class AppRadii {
  static const sm = 14.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const xl = 36.0;
  static const pill = 999.0;
}

abstract final class AppInsets {
  static const screen = EdgeInsets.fromLTRB(20, 8, 20, 12);
  static const card = EdgeInsets.fromLTRB(18, 16, 18, 18);
}
