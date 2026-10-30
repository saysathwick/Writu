import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'note_models.dart';

class AtelierFont {
  const AtelierFont({
    required this.id,
    required this.name,
    required this.category,
    this.premium = false,
  });

  final String id;
  final String name;
  final FontCategory category;
  final bool premium;

  TextStyle style({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w400,
    bool italic = false,
    double letterSpacing = 0,
    double height = 1.35,
    Color color = const Color(0xFF1C1410),
    bool underline = false,
    bool strikethrough = false,
  }) {
    TextDecoration? decoration;
    if (underline && strikethrough) {
      decoration = TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    } else if (underline) {
      decoration = TextDecoration.underline;
    } else if (strikethrough) {
      decoration = TextDecoration.lineThrough;
    }
    return _google(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      decoration: decoration,
    );
  }

  TextStyle _google({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return switch (id) {
      'caveat' => GoogleFonts.caveat(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            height: height,
            color: color,
            decoration: decoration,
          ),
      'dancing' => GoogleFonts.dancingScript(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'patrick' => GoogleFonts.patrickHand(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'satisfy' => GoogleFonts.satisfy(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'playfair' => GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'cormorant' => GoogleFonts.cormorantGaramond(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'libre' => GoogleFonts.libreBaskerville(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'specialElite' => GoogleFonts.specialElite(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'courierPrime' => GoogleFonts.courierPrime(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'ibmPlex' => GoogleFonts.ibmPlexMono(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'outfit' => GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'figtree' => GoogleFonts.figtree(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'dmSans' => GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'manrope' => GoogleFonts.manrope(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'fredoka' => GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'comfortaa' => GoogleFonts.comfortaa(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'pacifico' => GoogleFonts.pacifico(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'lora' => GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'merriweather' => GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'fraunces' => GoogleFonts.fraunces(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      'sourceSerif' => GoogleFonts.sourceSerif4(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
      _ => GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          color: color,
          decoration: decoration,
        ),
    };
  }
}

abstract final class NoteFonts {
  static const List<AtelierFont> all = [
    AtelierFont(id: 'caveat', name: 'Caveat', category: FontCategory.handwritten),
    AtelierFont(id: 'dancing', name: 'Dancing Script', category: FontCategory.handwritten),
    AtelierFont(id: 'patrick', name: 'Patrick Hand', category: FontCategory.handwritten),
    AtelierFont(id: 'satisfy', name: 'Satisfy', category: FontCategory.handwritten),
    AtelierFont(id: 'playfair', name: 'Playfair', category: FontCategory.editorial),
    AtelierFont(id: 'cormorant', name: 'Cormorant', category: FontCategory.editorial),
    AtelierFont(id: 'libre', name: 'Libre Baskerville', category: FontCategory.editorial),
    AtelierFont(id: 'specialElite', name: 'Special Elite', category: FontCategory.typewriter),
    AtelierFont(id: 'courierPrime', name: 'Courier Prime', category: FontCategory.typewriter),
    AtelierFont(id: 'ibmPlex', name: 'IBM Plex Mono', category: FontCategory.typewriter),
    AtelierFont(id: 'outfit', name: 'Outfit', category: FontCategory.modern),
    AtelierFont(id: 'figtree', name: 'Figtree', category: FontCategory.modern),
    AtelierFont(id: 'dmSans', name: 'DM Sans', category: FontCategory.modern),
    AtelierFont(id: 'manrope', name: 'Manrope', category: FontCategory.modern),
    AtelierFont(id: 'fredoka', name: 'Fredoka', category: FontCategory.playful),
    AtelierFont(id: 'comfortaa', name: 'Comfortaa', category: FontCategory.playful),
    AtelierFont(id: 'pacifico', name: 'Pacifico', category: FontCategory.playful, premium: true),
    AtelierFont(id: 'lora', name: 'Lora', category: FontCategory.classic),
    AtelierFont(id: 'merriweather', name: 'Merriweather', category: FontCategory.classic),
    AtelierFont(id: 'fraunces', name: 'Fraunces', category: FontCategory.classic),
    AtelierFont(id: 'sourceSerif', name: 'Source Serif', category: FontCategory.classic, premium: true),
  ];

  static AtelierFont byId(String id) {
    return all.firstWhere(
      (f) => f.id == id,
      orElse: () => all.firstWhere((f) => f.id == 'outfit'),
    );
  }

  static List<AtelierFont> of(FontCategory category) {
    return all.where((f) => f.category == category).toList();
  }
}
