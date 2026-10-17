import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/coupon.dart';
import '../../data/models/payment_method.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _coupon = TextEditingController();
  String? _addressId;
  String? _paymentId;
  Coupon? _applied;
  String? _couponError;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _addressId = ref.read(defaultAddressProvider)?.id;
    final methods = ref.read(paymentMethodsProvider);
    final preferred = methods.firstWhere(
      (m) => m.isDefault && _isAvailable(m.type),
      orElse: () => methods.firstWhere(
        (m) => _isAvailable(m.type),
        orElse: () => methods.first,
      ),
    );
    _paymentId = preferred.id;
  }

  /// لا يوجد مزوّد دفع إلكتروني مُهيّأ في هذا المشروع، لذا الطرق الإلكترونية
  /// (بطاقة/محفظة) غير متاحة وتظهر كحالة "يتطلب إعداد". الدفع عند الاستلام متاح.
  bool _isAvailable(PaymentType type) => type == PaymentType.cod;

  void _showPaymentSetup(PaymentMethod method) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('طريقة دفع غير مُهيّأة'),
          ],
        ),
        content: Text(
          '«${method.label}» تتطلب ربط مزوّد دفع حقيقي (مفاتيح API) قبل الاستخدام.\n\n'
          'لتفعيلها: أضف مزوّد الدفع في إعدادات المشروع ومرّر المفاتيح عبر متغيّرات البيئة '
          '(لا تُكتب في الكود المصدري). حاليًا يمكنك إتمام الطلب بالدفع عند الاستلام.',
          style: const TextStyle(height: 1.7, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(cartProvider.notifier);
    final items = notifier.selectedItems;
    final groups = notifier.selectedGroups;
    final subtotal = notifier.selectedSubtotal;
    final shipping = subtotal >= 300 ? 0.0 : groups.length * 12.0;
    final discount = _applied?.discountFor(subtotal) ?? 0;
    final total = subtotal + shipping - discount;

    final addresses = ref.watch(addressesProvider);
    final methods = ref.watch(paymentMethodsProvider);
    final selectedAddress = addresses.where((a) => a.id == _addressId).isEmpty
        ? null
        : addresses.firstWhere((a) => a.id == _addressId);
    final selectedPayment = methods.firstWhere(
      (m) => m.id == _paymentId,
      orElse: () => methods.first,
    );

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.checkout)),
        body: const EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: AppStrings.emptyCart,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.checkout),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          const _StepsBar(activeStep: 2),
          const SizedBox(height: Gap.sm),
          Container(
            margin: const EdgeInsets.only(bottom: Gap.md),
            padding: const EdgeInsets.all(Gap.md),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'الدفع الإلكتروني غير مُفعّل حاليًا (لا يوجد مزوّد دفع مربوط). الطلب سيتم بالدفع عند الاستلام.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.warning,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'عنوان التوصيل',
            icon: Icons.location_on_rounded,
            action: TextButton(
              onPressed: () => _pickAddress(addresses),
              child: const Text('تغيير'),
            ),
            child: selectedAddress == null
                ? const Text(
                    'أضف عنوانًا للتوصيل',
                    style: TextStyle(color: AppColors.danger),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedAddress.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 8),
                          if (selectedAddress.isDefault)
                            const PillBadge(text: 'الافتراضي', fontSize: 10),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        selectedAddress.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
          ),
          _Section(
            title: 'طريقة الدفع',
            icon: Icons.credit_card_rounded,
            child: Column(
              children: [
                for (final m in methods) ...[
                  _PaymentRadio(
                    label: m.label,
                    subtitle: m.last4 != null ? '•••• ${m.last4}' : null,
                    icon: _paymentIcon(m.type),
                    selected: m.id == _paymentId,
                    available: _isAvailable(m.type),
                    onTap: () {
                      if (_isAvailable(m.type)) {
                        setState(() => _paymentId = m.id);
                      } else {
                        _showPaymentSetup(m);
                      }
                    },
                  ),
                  if (m != methods.last) const SizedBox(height: Gap.sm),
                ],
              ],
            ),
          ),
          _Section(
            title: 'كوبون الخصم',
            icon: Icons.local_offer_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _coupon,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'أدخل الكود',
                        ),
                        onChanged: (_) => setState(() => _couponError = null),
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    ElevatedButton(
                      onPressed: _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('تطبيق'),
                    ),
                  ],
                ),
                if (_couponError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _couponError!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (_applied != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'تم تطبيق ${_applied!.code} — ${_applied!.description}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _applied = null),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _Section(
            title: 'ملخص الطلب (${items.length} منتج)',
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                _summaryRow('المجموع الفرعي', subtotal),
                const SizedBox(height: 8),
                _summaryRow(
                  'الشحن (${groups.length} متجر)',
                  shipping,
                  freeLabel: shipping == 0,
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _summaryRow('الخصم', -discount, color: AppColors.success),
                ],
              ],
            ),
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(Gap.md),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.total,
                      style: TextStyle(fontSize: 11, color: AppColors.textHint),
                    ),
                    PriceTag(price: total, fontSize: 16),
                  ],
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _placing ||
                            selectedAddress == null ||
                            !_isAvailable(selectedPayment.type)
                        ? null
                        : () => _placeOrder(
                            selectedAddress,
                            selectedPayment,
                            shipping,
                            discount,
                            total,
                          ),
                    child: _placing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isAvailable(selectedPayment.type)
                                ? 'تأكيد الطلب'
                                : 'طريقة الدفع غير متاحة',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _paymentIcon(PaymentType t) {
    switch (t) {
      case PaymentType.card:
      case PaymentType.mada:
        return Icons.credit_card_rounded;
      case PaymentType.applePay:
        return Icons.phone_iphone_rounded;
      case PaymentType.wallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.cod:
        return Icons.payments_outlined;
    }
  }

  Widget _summaryRow(
    String label,
    double amount, {
    Color? color,
    bool freeLabel = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (freeLabel)
          const Text(
            'مجاني',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          )
        else
          Text(
            Money.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
            ),
          ),
      ],
    );
  }

  void _applyCoupon() {
    final c = ref.read(couponsProvider.notifier).findByCode(_coupon.text);
    if (c == null) {
      setState(() => _couponError = 'كود غير صحيح أو منتهي الصلاحية');
      return;
    }
    final subtotal = ref.read(cartProvider.notifier).selectedSubtotal;
    if (subtotal < c.minOrder) {
      setState(
        () => _couponError = 'الحد الأدنى للطلب ${Money.format(c.minOrder)}',
      );
      return;
    }
    setState(() {
      _applied = c;
      _couponError = null;
    });
  }

  void _pickAddress(List addresses) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(Gap.lg),
              child: Text(
                'اختر عنوان التوصيل',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            ...addresses.map<Widget>(
              (a) => ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  a.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  a.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: a.id == _addressId
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _addressId = a.id);
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_rounded, color: AppColors.primary),
              title: const Text(
                'إضافة عنوان جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/addresses');
              },
            ),
            const SizedBox(height: Gap.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    dynamic address,
    PaymentMethod payment,
    double shipping,
    double discount,
    double total,
  ) async {
    setState(() => _placing = true);
    final notifier = ref.read(cartProvider.notifier);
    final items = notifier.selectedItems;
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final order = ref
        .read(ordersProvider.notifier)
        .place(
          items: items,
          shipping: shipping,
          discount: discount,
          addressSummary: '${address.label} — ${address.summary}',
          paymentLabel: payment.label,
        );

    notifier.clearSelected();
    if (!mounted) return;
    setState(() => _placing = false);
    context.go('/order-success/${order.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إنشاء طلبك — ${payment.label}. لم تتم أي عملية دفع إلكتروني.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

/// شريط الخطوات (1 العنوان — 2 الدفع — 3 التأكيد) كما في تصميم XPRESS.
class _StepsBar extends StatelessWidget {
  final int activeStep;

  const _StepsBar({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['العنوان', 'الدفع', 'تأكيد الطلب'];
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(3, (i) {
            final done = i + 1 < activeStep;
            final active = i + 1 == activeStep;
            return Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(i + 1, done: done, active: active),
                      if (i != 2)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 2,
                            color: done ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      color: active
                          ? AppColors.primary
                          : (done ? AppColors.textPrimary : AppColors.textHint),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _dot(int n, {required bool done, required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: done || active ? AppColors.brandGradient : null,
        color: done || active ? null : AppColors.surfaceVariant,
        shape: BoxShape.circle,
        boxShadow: active ? Shadows.glowSoft : null,
        border: Border.all(
          color: !done && !active ? AppColors.glassBorder : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Icon(
        done ? Icons.check_rounded : Icons.lens_rounded,
        size: done ? 14 : 5,
        color: done || active ? Colors.white : AppColors.textHint,
      ),
    );
  }
}

/// خيار طريقة دفع اختياري (radio) بتصميم XPRESS.
class _PaymentRadio extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  const _PaymentRadio({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.selected,
    this.available = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dim = !available;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dim ? 0.6 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.09)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.glassBorder,
              width: selected ? 1.3 : 0.8,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.textHint,
                    width: 1.6,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(
                icon,
                size: 21,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (!available)
                      const Text(
                        'يتطلب إعداد مزوّد دفع',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
              if (!available)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.5),
                      width: 0.7,
                    ),
                  ),
                  child: const Text(
                    'غير متاح',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                )
              else if (subtitle == null)
                _brandChip(Icons.payments_rounded)
              else
                _brandChip(Icons.credit_card_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandChip(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder, width: 0.7),
      ),
      child: Icon(icon, size: 15, color: AppColors.textSecondary),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              ?action,
            ],
          ),
          const SizedBox(height: Gap.md),
          child,
        ],
      ),
    );
  }
}
