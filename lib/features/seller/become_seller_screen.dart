import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _store = TextEditingController();
  final _phone = TextEditingController();
  final _cr = TextEditingController();
  String? _category;
  bool _submitting = false;

  static const _cats = [
    'إلكترونيات',
    'أزياء',
    'المنزل',
    'جمال',
    'رياضة',
    'أطفال',
  ];

  @override
  void dispose() {
    _store.dispose();
    _phone.dispose();
    _cr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_store.text.isEmpty || _category == null) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _submitting = false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppColors.tealGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: Gap.lg),
            const Text(
              'تم استلام طلبك!',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: Gap.sm),
            const Text(
              'سيتواصل فريقنا معك خلال 24 ساعة لاستكمال بيانات المتجر والتحقق (KYC).',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.8,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: Gap.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('حسنًا'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('كن بائعًا'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.xl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                SizedBox(height: Gap.md),
                Text(
                  'ابدأ البيع على XPRESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'صِل إلى ملايين العملاء، وعمولة تنافسية تبدأ من 8%، وتحويلات أسبوعية.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          _label('اسم المتجر'),
          TextField(
            controller: _store,
            decoration: const InputDecoration(hintText: 'مثال: متجر النخبة'),
          ),
          const SizedBox(height: Gap.lg),
          _label('رقم الجوال'),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+966 5X XXX XXXX'),
          ),
          const SizedBox(height: Gap.lg),
          _label('السجل التجاري (اختياري)'),
          TextField(
            controller: _cr,
            decoration: const InputDecoration(hintText: 'رقم السجل التجاري'),
          ),
          const SizedBox(height: Gap.lg),
          _label('الفئة الرئيسية'),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: _cats.map((c) {
              final sel = _category == c;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: Motion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: sel ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Gap.xxl),
          ElevatedButton(
            onPressed: _store.text.isEmpty || _category == null || _submitting
                ? null
                : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text('إرسال الطلب'),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.sm),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  );
}
