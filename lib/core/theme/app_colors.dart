import 'package:flutter/material.dart';

/// XPRESS brand palette — deep-space black, electric violet, magenta & orange.
/// Official identity colors per the XPRESS design assets:
/// Background #090812 · Surface #111322 · Purple #7A2CFF · Magenta #FF2E93
/// Orange #FF8A00 · Text #FFFFFF · Secondary text #D8CCFF
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF7A2CFF);
  static const Color primaryDark = Color(0xFF5B19B7);
  static const Color primarySoft = Color(0xFF241046);
  static const Color accent = Color(0xFFFF8A00);
  static const Color neon = Color(0xFFFF2E93);
  static const Color magenta = Color(0xFFFF2E93);
  static const Color violet = Color(0xFF7A2CFF);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFF12291E);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSoft = Color(0xFF2E2410);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFF2E1518);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFF12203A);
  static const Color gold = Color(0xFFF5B301);

  // Surfaces
  static const Color background = Color(0xFF090812);
  static const Color surface = Color(0xFF111322);
  static const Color surfaceVariant = Color(0xFF1A1B2E);
  static const Color ink = Color(0xFF050409);

  // Glassmorphism
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x24FFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD8CCFF);
  static const Color textHint = Color(0xFF8A7EB8);
  static const Color divider = Color(0xFF262145);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF7A2CFF), Color(0xFFB14CFF)],
  );

  /// تدرّج شعار X (برتقالي → ماجنتا → بنفسجي) كما في أصول الهوية.
  static const LinearGradient xGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFFF8A00), Color(0xFFFF2E93), Color(0xFF7A2CFF)],
  );

  static const LinearGradient auroraGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF7A2CFF), Color(0xFFB14CFF), Color(0xFFFF2E93)],
  );

  /// تدرّج بانر العروض الرسمي (#160B30 → #5B19B7 → #FF5A20).
  static const LinearGradient bannerGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF160B30), Color(0xFF5B19B7), Color(0xFFFF5A20)],
  );

  /// تدرّج شاشة البداية الرسمي (#05050A → #130925 → #25084B).
  static const LinearGradient splashGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF05050A), Color(0xFF130925), Color(0xFF25084B)],
  );

  static const LinearGradient flashGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [Color(0xFFFF8A00), Color(0xFFFFB300)],
  );

  static const LinearGradient walletGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF1B1430), Color(0xFF3B1E6E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFFFD86F), Color(0xFFF5B301)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF14B8A6), Color(0xFF0E9488)],
  );

  static const LinearGradient glassOverlay = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
  );

  /// خلفية الفئات الرسمية (#251047 → #742BDF).
  static const LinearGradient categoryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF251047), Color(0xFF742BDF)],
  );
}
