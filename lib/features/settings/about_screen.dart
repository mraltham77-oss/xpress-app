import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('عن التطبيق'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.xl),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: Shadows.floating,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: Gap.lg),
                const Text(
                  'XPRESS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xxl),
          const Text(
            'XPRESS منصة تسوّق متعددة البائعين تجمع آلاف المتاجر الموثوقة في مكان واحد. نوفّر تجربة تسوّق آمنة مع نظام دفع محمي (الحجز) لا يصل فيه المبلغ للبائع إلا بعد تأكيد استلامك، مع تتبع دقيق لكل شحنة.',
            style: TextStyle(
              fontSize: 14,
              height: 2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Gap.xl),
          _tile(context, Icons.star_rounded, 'قيّم التطبيق'),
          _tile(context, Icons.share_rounded, 'شارك التطبيق'),
          _tile(context, Icons.privacy_tip_outlined, 'سياسة الخصوصية'),
          _tile(context, Icons.description_outlined, 'الشروط والأحكام'),
          const SizedBox(height: Gap.xl),
          const Center(
            child: Text(
              'صُنع بـ ❤️ في المملكة العربية السعودية',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: Shadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textHint,
          ),
          onTap: () {
            if (label == 'شارك التطبيق') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ رابط التطبيق www.xpress.app'),
                ),
              );
              return;
            }
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                content: Text(
                  _dialogBody(label),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.9,
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('حسنًا'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _dialogBody(String label) {
    switch (label) {
      case 'قيّم التطبيق':
        return 'يسعدنا تقييمك! تجربتك تساعدنا على تحسين XPRESS. اضغط 5 نجوم إذا أعجبك التطبيق ⭐⭐⭐⭐⭐';
      case 'سياسة الخصوصية':
        return 'نحترم خصوصيتك. نجمع الحد الأدنى من البيانات اللازمة لإتمام الطلبات وتأمين الحساب، ولا نشاركها مع أي طرف ثالث لأغراض تجارية. يمكنك طلب حذف بياناتك في أي وقت من إعدادات الحساب.';
      default:
        return 'باستخدامك تطبيق XPRESS فإنك توافق على شروط الاستخدام: الالتزام بالأنظمة، عدم إساءة استخدام المنصة، ومسؤولية صحة بيانات الطلب. تحتفظ المنصة بحق تعليق الحسابات المخالفة.';
    }
  }
}
