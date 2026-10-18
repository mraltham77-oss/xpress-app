import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/vendor.dart';
import '../../data/providers/providers.dart';

class BecomeSellerScreen extends ConsumerStatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  ConsumerState<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends ConsumerState<BecomeSellerScreen> {
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
    if (_store.text.trim().isEmpty || _category == null) return;
    final auth = ref.read(authProvider.notifier);
    final user = ref.read(authProvider);
    setState(() => _submitting = true);

    if (auth.serverMode) {
      if (user == null) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سجّل الدخول أولًا لفتح متجر')),
        );
        return;
      }
      try {
        await ref
            .read(myStoreProvider.notifier)
            .createStore(
              name: _store.text.trim(),
              category: _category!,
              phone: _phone.text.trim(),
            );
        if (!mounted) return;
        setState(() => _submitting = false);
        _showSuccess(real: true);
      } catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر فتح المتجر: $e')));
      }
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _submitting = false);
    _showSuccess(real: false);
  }

  void _showSuccess({required bool real}) {
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
            Text(
              real ? 'تم إرسال طلب فتح المتجر! ⏳' : 'تم استلام طلبك!',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              real
                  ? 'طلبك الآن بانتظار موافقة الإدارة. ستظهر لوحة متجرك بعد الاعتماد.'
                  : 'سيتواصل فريقنا معك خلال 24 ساعة لاستكمال بيانات المتجر والتحقق (KYC).',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                child: Text(real ? 'حسنًا' : 'حسنًا'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(myStoreProvider).asData?.value;
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
          if (store != null) _StoreStatusBanner(store: store),
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
                  'صِل إلى ملايين العملاء، وأضف منتجاتك واستقبل الطلبات مباشرة.',
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
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Gap.lg),
          _label('رقم الجوال'),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+20 1X XXX XXXX'),
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
                : const Text('إرسال طلب فتح المتجر'),
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

class _StoreStatusBanner extends StatelessWidget {
  final Vendor store;
  const _StoreStatusBanner({required this.store});

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, body) = switch (store.status) {
      StoreStatus.pending => (
        AppColors.warning,
        Icons.hourglass_top_rounded,
        'طلبك بانتظار الموافقة',
        'متجر "${store.name}" قيد المراجعة من الإدارة.',
      ),
      StoreStatus.rejected => (
        AppColors.danger,
        Icons.cancel_outlined,
        'تم رفض طلب المتجر',
        store.rejectionReason.isEmpty
            ? 'تواصل مع الدعم لمعرفة السبب.'
            : 'السبب: ${store.rejectionReason}',
      ),
      StoreStatus.approved => (
        AppColors.success,
        Icons.verified_rounded,
        'متجرك معتمد',
        'متجر "${store.name}" يعمل الآن. أدر منتجاتك من لوحة متجري.',
      ),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.lg),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
