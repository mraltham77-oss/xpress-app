import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _slides = const [
    _Slide(
      icon: Icons.storefront_rounded,
      emoji: '🛍️',
      title: 'آلاف المتاجر في مكان واحد',
      body: 'تصفّح منتجات من مئات البائعين الموثوقين وقارن الأسعار بسهولة.',
      gradient: AppColors.brandGradient,
    ),
    _Slide(
      icon: Icons.shield_rounded,
      emoji: '🛡️',
      title: 'دفع آمن ومضمون',
      body: 'أموالك محفوظة لدينا ولا تصل للبائع إلا بعد تأكيد استلامك للطلب.',
      gradient: AppColors.tealGradient,
    ),
    _Slide(
      icon: Icons.local_shipping_rounded,
      emoji: '🚚',
      title: 'توصيل سريع وتتبع مباشر',
      body: 'تابع شحنتك لحظة بلحظة من أكثر من متجر في نفس الطلب.',
      gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)]),
    ),
  ];

  Future<void> _finish() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      await prefs.setBool('seen_onboarding', true);
    } catch (_) {}
    if (mounted) {
      try {
        context.go('/home');
      } catch (e) {
        debugPrint('[XPRESS] navigation failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'تخطٍ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) =>
                    _SlideView(slide: _slides[i], index: i),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.xl),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: Motion.base,
                              curve: Motion.ease,
                            ),
                      child: Text(isLast ? 'ابدأ التسوق' : 'التالي'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: Motion.base,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
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

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final int index;

  const _SlideView({required this.slide, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: slide.gradient,
                  borderRadius: BorderRadius.circular(44),
                  boxShadow: Shadows.floating,
                ),
                child: Center(
                  child: Text(
                    slide.emoji,
                    style: const TextStyle(fontSize: 92),
                  ),
                ),
              )
              .animate(key: ValueKey(index))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 48),
          Text(
                slide.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              )
              .animate(key: ValueKey('t$index'))
              .fadeIn(delay: 120.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 14),
          Text(
                slide.body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.8,
                ),
              )
              .animate(key: ValueKey('b$index'))
              .fadeIn(delay: 220.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String emoji;
  final String title;
  final String body;
  final Gradient gradient;

  const _Slide({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.body,
    required this.gradient,
  });
}
