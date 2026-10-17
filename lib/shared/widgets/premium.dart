import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// زجاج ضبابي (glassmorphism) بحواف متوهجة — عنصر بصري أساسي في XPRESS.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.color,
    this.gradient,
    this.onTap,
    this.shadow,
    this.blur = 16,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? AppColors.surface.withValues(alpha: 0.72))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        boxShadow: shadow ?? Shadows.card,
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: onTap == null
            ? content
            : Stack(
                children: [
                  content,
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        hoverColor: AppColors.primary.withValues(alpha: 0.06),
                        splashColor: AppColors.primary.withValues(alpha: 0.10),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// نص بتدرّج لوني (gradient text) للعناوين المميزة.
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Gradient gradient;
  final double letterSpacing;

  const GradientText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.fontWeight = FontWeight.w900,
    this.gradient = AppColors.brandGradient,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// زر بحواف متوهجة وخلفية متدرجة (الزر الأساسي للـ CTA).
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final bool expanded;
  final double height;
  final List<BoxShadow> shadow;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.brandGradient,
    this.expanded = true,
    this.height = 52,
    this.shadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? (shadow.isEmpty ? Shadows.glow : shadow) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// شارة أيقونة بإطار متدرج متوهج.
class GlowIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GlowIconBadge({
    super.key,
    required this.icon,
    this.size = 52,
    this.gradient = AppColors.brandGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: Shadows.glowSoft,
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// حاوية بإطار متدرّج متوهج حول المحتوى (glowing border).
class GlowBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Gradient gradient;
  final double width;

  const GlowBorder({
    super.key,
    required this.child,
    this.radius = 18,
    this.gradient = AppColors.brandGradient,
    this.width = 1.4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius + width),
        boxShadow: Shadows.glowSoft,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// شعار XPRESS الرسمي: حرف X بتدرّج (برتقالي → ماجنتا → بنفسجي) مع توهّج نيون،
/// وكلمة XPRESS بجانبه. عند `showWord = false` يُعرض حرف X فقط (كما في شاشة الدخول).
class XpressLogo extends StatelessWidget {
  final double size;
  final double fontSize;
  final bool showWord;

  const XpressLogo({
    super.key,
    this.size = 44,
    this.fontSize = 20,
    this.showWord = true,
  });

  @override
  Widget build(BuildContext context) {
    final glyph = _XGlyph(size: size);
    if (!showWord) return glyph;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        glyph,
        SizedBox(width: size * 0.16),
        GradientText(
          'XPRESS',
          fontSize: fontSize,
          letterSpacing: fontSize * 0.08,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFBCA8FF)],
          ),
        ),
      ],
    );
  }
}

/// حرف X الرسمي (مسار حادّ الزوايا) مرسوم بتدرّج لوني وتوهّج نيون.
class _XGlyph extends StatelessWidget {
  final double size;
  const _XGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: const _XGlyphPainter());
  }
}

class _XGlyphPainter extends CustomPainter {
  const _XGlyphPainter();

  /// مسار الحرف X داخل مساحة 512×512 — مستخرج من أصول الهوية الرسمية.
  static final Path _path = Path()
    ..moveTo(105, 115)
    ..lineTo(190, 115)
    ..lineTo(256, 195)
    ..lineTo(322, 115)
    ..lineTo(407, 115)
    ..lineTo(302, 256)
    ..lineTo(411, 397)
    ..lineTo(325, 397)
    ..lineTo(256, 315)
    ..lineTo(187, 397)
    ..lineTo(101, 397)
    ..lineTo(210, 256)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512;
    canvas.save();
    canvas.scale(scale);
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF8A00), Color(0xFFFF2E93), Color(0xFF7A2CFF)],
      stops: [0, 0.48, 1],
    ).createShader(const Rect.fromLTWH(0, 0, 512, 512));

    final glow = Paint()
      ..shader = shader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawPath(_path, glow);

    final paint = Paint()..shader = shader;
    canvas.drawPath(_path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _XGlyphPainter oldDelegate) => false;
}

/// خطوط مائلة نيون (بنفسجي/أورانج) — لمسة العلامة في الخلفيات.
class DiagonalStripes extends StatelessWidget {
  const DiagonalStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.center,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: SizedBox(
            width: 1400,
            height: 1400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.7,
                  child: Column(
                    children: [
                      _stripe(AppColors.accent, 10, 520),
                      const SizedBox(height: 30),
                      _stripe(AppColors.primary, 7, 620),
                      const SizedBox(height: 46),
                      _stripe(const Color(0xFFFF2D55), 5, 460),
                      const SizedBox(height: 60),
                      _stripe(const Color(0xFFB14CFF), 12, 700),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stripe(Color color, double width, double length) {
    return Container(
      width: length,
      height: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.7),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
