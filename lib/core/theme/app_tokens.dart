import 'package:flutter/material.dart';

/// Spacing scale (8pt grid) — استخدمه بدل الأرقام العشوائية.
class Gap {
  Gap._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const Widget h4 = SizedBox(height: 4);
  static const Widget h8 = SizedBox(height: 8);
  static const Widget h12 = SizedBox(height: 12);
  static const Widget h16 = SizedBox(height: 16);
  static const Widget h24 = SizedBox(height: 24);
}

/// Radius scale.
class Radii {
  Radii._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 100;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xl));
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

/// Animation durations.
class Motion {
  Motion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve ease = Curves.easeOutCubic;
  static const Curve emphasize = Curves.easeOutExpo;
}

/// Soft, layered elevations + neon glows (dark theme).
class Shadows {
  Shadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.45),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.55),
      blurRadius: 30,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Electric violet glow for primary CTAs and highlighted cards.
  static List<BoxShadow> get glow => [
    BoxShadow(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
      blurRadius: 26,
      spreadRadius: -2,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glowSoft => [
    BoxShadow(
      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
      blurRadius: 18,
      spreadRadius: -4,
      offset: const Offset(0, 6),
    ),
  ];

  /// Selective orange glow for flash / accent elements.
  static List<BoxShadow> get glowOrange => [
    BoxShadow(
      color: const Color(0xFFFF7A1A).withValues(alpha: 0.40),
      blurRadius: 22,
      spreadRadius: -3,
      offset: const Offset(0, 8),
    ),
  ];
}
