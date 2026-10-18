import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    (
      'كيف أتتبع طلبي؟',
      'افتح "طلباتي"، اختر الطلب، وستجد قسم التتبع لكل شحنة على حدة مع رقم التتبع واسم شركة الشحن.',
    ),
    (
      'متى يُفرَج عن المبلغ للبائع؟',
      'نحتفظ بالمبلغ في حساب وسيط (الحجز) ولا يصل للبائع إلا بعد تأكيدك استلام الطلب، أو تلقائيًا بعد 7 أيام من التوصيل.',
    ),
    (
      'ما هو طلب متعدد المتاجر؟',
      'إذا احتوى طلبك على منتجات من متاجر مختلفة، نقسّمه تلقائيًا إلى شحنات منفصلة، كل منها بتتبع خاص.',
    ),
    (
      'كيف أطلب استرجاع؟',
      'من تفاصيل الطلب اضغط "فتح نزاع" خلال 7 أيام من الاستلام، وسيتواصل معك فريق الدعم لحل المشكلة.',
    ),
    (
      'كيف أستخدم كوبون الخصم؟',
      'في صفحة إتمام الشراء، اكتب كود الكوبون واضغط "تطبيق". سيطبّق الخصم مباشرة على إجمالي طلبك.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('مركز المساعدة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.xl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(width: Gap.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نحن هنا لمساعدتك',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'استجابة سريعة خلال دقائق',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 4, bottom: Gap.sm),
            child: Text(
              'الأسئلة الشائعة',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: Shadows.card,
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: _faqs
                    .map(
                      (f) => Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            f.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            Gap.lg,
                            0,
                            Gap.lg,
                            Gap.lg,
                          ),
                          children: [
                            Text(
                              f.$2,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: _contact(
                  context,
                  Icons.chat_bubble_outline_rounded,
                  'محادثة',
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(child: _contact(context, Icons.call_outlined, 'اتصال')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contact(BuildContext context, IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('جارٍ الاتصال بـ $label...'))),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
    );
  }
}
