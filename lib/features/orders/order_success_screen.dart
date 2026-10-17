import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/premium.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text('حساب'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // حقيبة متوهجة + شيك
              Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: Shadows.glow,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 62,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 650.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
              const SizedBox(height: Gap.xl),
              const Text(
                'تم تأكيد طلبك بنجاح!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.25, end: 0),
              const SizedBox(height: Gap.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder, width: 0.8),
                ),
                child: Text(
                  'رقم الطلب: #${order?.id ?? orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.25, end: 0),
              const SizedBox(height: Gap.md),
              Text(
                'شكرًا لثقتك! ستصلك رسالة تأكيد على بريدك الإلكتروني مع تفاصيل الشحن قريبًا.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 420.ms).fadeIn(),

              const SizedBox(height: Gap.xl),
              SizedBox(
                width: 230,
                child: NeonButton(
                  label: 'عرض الطلب',
                  icon: Icons.receipt_long_rounded,
                  onPressed: () => context.go('/order/$orderId'),
                ),
              ).animate(delay: 520.ms).fadeIn().slideY(begin: 0.3, end: 0),
              const SizedBox(height: Gap.sm),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
