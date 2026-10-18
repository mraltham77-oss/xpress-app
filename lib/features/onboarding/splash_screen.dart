import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/premium.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _autoStart();
  }

  Future<void> _autoStart() async {
    final seen = await _seenOnboarding();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _navigating) return;
    _go(seen ? '/home' : '/onboarding');
  }

  Future<void> _start() async {
    _navigating = true;
    final seen = await _seenOnboarding();
    if (!mounted) return;
    _go(seen ? '/home' : '/onboarding');
  }

  Future<bool> _seenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      return prefs.getBool('seen_onboarding') ?? false;
    } catch (_) {
      return false;
    }
  }

  void _go(String location) {
    if (!mounted) return;
    try {
      context.go(location);
    } catch (e) {
      debugPrint('[XPRESS] navigation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.splashGradient),
            ),
          ),
          PositionedDirectional(
            top: -130,
            end: -120,
            child: _orb(AppColors.primary.withValues(alpha: 0.55), 430),
          ),
          PositionedDirectional(
            bottom: -170,
            start: -150,
            child: _orb(AppColors.neon.withValues(alpha: 0.32), 470),
          ),

          // الشعار الرسمي مرسوم بالكود (X بتدرّج + كلمة XPRESS)
          Center(
            child:
                Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Gap.md),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 90,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const XpressLogo(showWord: false, size: 108),
                        ),
                        const SizedBox(height: Gap.md),
                        const Text(
                          'XPRESS',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 9,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: Gap.lg),
                        Text(
                          AppStrings.brandTagline,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutCubic,
                    ),
          ),

          // الطبقة السفلية: زر البدء + تخطّ
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                Gap.xl,
                Gap.xl,
                Gap.xl,
                Gap.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.85),
                    AppColors.background,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Gap.lg),
                    SizedBox(width: 240, child: _StartButton(onPressed: _start))
                        .animate(delay: 500.ms)
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: Gap.sm),
                    TextButton(
                      onPressed: _start,
                      child: const Text(
                        'تخطّ',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ).animate(delay: 650.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

/// زر "ابدأ التسوّق" بتدرّج شعار X (برتقالي → ماجنتا → بنفسجي).
class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.xGradient,
          borderRadius: BorderRadius.circular(27),
          boxShadow: Shadows.glow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'ابدأ التسوّق',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
