import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/coupon.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/mock/mock_data.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/premium.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null || !user.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Gap.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlowIconBadge(
                  icon: Icons.gpp_bad_rounded,
                  size: 72,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                const Text(
                  AppStrings.adminAccessDenied,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Gap.sm),
                const Text(
                  'سجّل الدخول بحساب مشرف للوصول إلى لوحة التحكم.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Gap.xl),
                NeonButton(
                  label: AppStrings.login,
                  icon: Icons.login_rounded,
                  expanded: false,
                  onPressed: () => context.push('/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: const Text(AppStrings.adminDashboard),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: AppStrings.adminOverview),
              Tab(text: AppStrings.adminProducts),
              Tab(text: AppStrings.adminInventory),
              Tab(text: AppStrings.adminPromotions),
              Tab(text: AppStrings.adminOrders),
            ],
          ),
        ),
        body: Column(
          children: [
            // توضيح: كل بيانات الإدارة (المنتجات/المخزون/الطلبات) تجريبية.
            Container(
              width: double.infinity,
              color: AppColors.warningSoft,
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.md,
                vertical: 8,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'بيانات تجريبية (وضع تجريبي) — التعديلات تُحفظ محليًا على هذا الجهاز فقط.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(),
                  _ProductsTab(),
                  _InventoryTab(),
                  _PromotionsTab(),
                  _OrdersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Overview ───────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(catalogProvider);
    final orders = ref.watch(ordersProvider);
    final revenue = orders.fold<double>(0, (s, o) => s + o.total);
    final lowStock = products.where((p) => p.stock > 0 && p.stock <= 10).length;
    final outOfStock = products.where((p) => p.stock == 0).length;

    return ListView(
      padding: const EdgeInsets.all(Gap.lg),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: AppStrings.adminRevenue,
                value: Money.format(revenue),
                icon: Icons.payments_rounded,
                gradient: AppColors.brandGradient,
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _StatCard(
                label: AppStrings.adminOrders,
                value: '${orders.length}',
                icon: Icons.receipt_long_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: AppStrings.adminProducts,
                value: '${products.length}',
                icon: Icons.inventory_2_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF0E9488)],
                ),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: _StatCard(
                label: AppStrings.adminLowStock,
                value: '$lowStock / $outOfStock',
                icon: Icons.warning_amber_rounded,
                gradient: AppColors.flashGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.xl),
        const Text(
          AppStrings.adminOrders,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: Gap.md),
        ...orders
            .take(5)
            .map(
              (o) => GlassCard(
                radius: 14,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.orderNumber} ${o.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${o.shipments.length} شحنة • ${AppDate.short(o.date)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PriceTag(price: o.total, fontSize: 13),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        boxShadow: Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: Gap.md),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Products ───────────────────────────
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(catalogProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(context, ref, categories),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.adminAddProduct),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 90),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          final cat = _categoryName(categories, p.categoryId);
          return GlassCard(
            radius: 14,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                NetImage(
                  url: p.images.first,
                  width: 56,
                  height: 56,
                  radius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cat • ${AppStrings.adminInventory}: ${p.stock}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      PriceTag(
                        price: p.price,
                        oldPrice: p.oldPrice,
                        fontSize: 13,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                  onPressed: () =>
                      _openEditor(context, ref, categories, product: p),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context, ref, p),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Product p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(AppStrings.adminDeleteProduct),
        content: Text('هل تريد حذف "${p.title}"؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(catalogProvider.notifier).remove(p.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

void _openEditor(
  BuildContext context,
  WidgetRef ref,
  List<ProductCategory> categories, {
  Product? product,
}) {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(text: product?.title ?? '');
  final price = TextEditingController(
    text: product?.price.toStringAsFixed(0) ?? '',
  );
  final oldPrice = TextEditingController(
    text: product?.oldPrice?.toStringAsFixed(0) ?? '',
  );
  final stock = TextEditingController(text: product?.stock.toString() ?? '20');
  final description = TextEditingController(text: product?.description ?? '');
  final image = TextEditingController(text: product?.images.first ?? '');
  String? categoryId = product?.categoryId ?? 'c1';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (ctx, setSheet) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  Text(
                    product == null
                        ? AppStrings.adminAddProduct
                        : AppStrings.adminEditProduct,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  _input(
                    title,
                    'اسم المنتج',
                    (v) => v!.trim().isEmpty ? AppStrings.requiredField : null,
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      Expanded(
                        child: _input(
                          price,
                          'السعر',
                          (v) => double.tryParse(v ?? '') == null
                              ? 'رقم غير صحيح'
                              : null,
                          number: true,
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: _input(
                          oldPrice,
                          'السعر قبل الخصم',
                          (v) => null,
                          number: true,
                          required: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  DropdownButtonFormField<String>(
                    initialValue: categoryId,
                    decoration: const InputDecoration(labelText: 'القسم'),
                    dropdownColor: AppColors.surfaceVariant,
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (v) => setSheet(() => categoryId = v),
                  ),
                  const SizedBox(height: Gap.md),
                  _input(
                    stock,
                    'المخزون',
                    (v) =>
                        int.tryParse(v ?? '') == null ? 'رقم غير صحيح' : null,
                    number: true,
                  ),
                  const SizedBox(height: Gap.md),
                  _input(image, 'رابط الصورة', (v) => null, required: false),
                  const SizedBox(height: Gap.md),
                  _input(
                    description,
                    'الوصف',
                    (v) => null,
                    maxLines: 3,
                    required: false,
                  ),
                  const SizedBox(height: Gap.xl),
                  NeonButton(
                    label: AppStrings.save,
                    icon: Icons.check_rounded,
                    onPressed: () {
                      if (!form.currentState!.validate()) return;
                      final img = image.text.trim().isEmpty
                          ? MockData.img(title.text)
                          : image.text.trim();
                      final newPrice = double.tryParse(price.text) ?? 0;
                      final newOld = double.tryParse(oldPrice.text);
                      final newStock = int.tryParse(stock.text) ?? 0;
                      if (product == null) {
                        ref
                            .read(catalogProvider.notifier)
                            .add(
                              Product(
                                id: 'p${DateTime.now().millisecondsSinceEpoch}',
                                title: title.text.trim(),
                                images: [img, img],
                                price: newPrice,
                                oldPrice: (newOld != null && newOld > newPrice)
                                    ? newOld
                                    : null,
                                rating: 4.5,
                                vendor: MockData.vendors.first,
                                categoryId: categoryId ?? 'c1',
                                description: description.text.trim(),
                                stock: newStock,
                              ),
                            );
                      } else {
                        ref
                            .read(catalogProvider.notifier)
                            .update(
                              product.copyWith(
                                title: title.text.trim(),
                                price: newPrice,
                                oldPrice: (newOld != null && newOld > newPrice)
                                    ? newOld
                                    : null,
                                stock: newStock,
                                categoryId: categoryId,
                                description: description.text.trim(),
                                images: [img, img],
                              ),
                            );
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحفظ بنجاح')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────── Inventory ───────────────────────────
class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(catalogProvider);
    final low = [...products]..sort((a, b) => a.stock.compareTo(b.stock));

    return ListView.builder(
      padding: const EdgeInsets.all(Gap.lg),
      itemCount: low.length,
      itemBuilder: (context, i) {
        final p = low[i];
        final Color color = p.stock == 0
            ? AppColors.danger
            : (p.stock <= 10 ? AppColors.warning : AppColors.success);
        return GlassCard(
          radius: 14,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NetImage(url: p.images.first, width: 52, height: 52, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.stock == 0
                          ? AppStrings.adminOutOfStock
                          : '${AppStrings.adminInventory}: ${p.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    ref.read(catalogProvider.notifier).adjustStock(p.id, -1),
              ),
              Text(
                '${p.stock}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                onPressed: () =>
                    ref.read(catalogProvider.notifier).adjustStock(p.id, 1),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Promotions ───────────────────────────
class _PromotionsTab extends ConsumerWidget {
  const _PromotionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(couponsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openCouponEditor(context, ref),
        icon: const Icon(Icons.local_offer_rounded),
        label: const Text(AppStrings.adminNewPromotion),
      ),
      body: coupons.isEmpty
          ? const EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'لا توجد عروض',
              subtitle: 'أضف كوبون خصم جديد للبدء',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 90),
              itemCount: coupons.length,
              itemBuilder: (context, i) {
                final c = coupons[i];
                return GlassCard(
                  radius: 14,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          c.isPercent
                              ? '${c.value.toInt()}%'
                              : Money.format(c.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              c.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'حد أدنى: ${Money.format(c.minOrder)} • ينتهي ${AppDate.short(c.expiry)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        onPressed: () =>
                            ref.read(couponsProvider.notifier).remove(c.code),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

void _openCouponEditor(BuildContext context, WidgetRef ref) {
  final form = GlobalKey<FormState>();
  final code = TextEditingController();
  final value = TextEditingController();
  final minOrder = TextEditingController(text: '0');
  final desc = TextEditingController();
  bool isPercent = true;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Form(
          key: form,
          child: StatefulBuilder(
            builder: (ctx, setSheet) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                const Text(
                  AppStrings.adminNewPromotion,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Gap.lg),
                _input(
                  code,
                  'كود الخصم',
                  (v) => (v == null || v.trim().isEmpty)
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    Expanded(
                      child: _input(
                        value,
                        'القيمة',
                        (v) => double.tryParse(v ?? '') == null
                            ? 'رقم غير صحيح'
                            : null,
                        number: true,
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: _input(
                        minOrder,
                        'أقل مبلغ',
                        (v) => null,
                        number: true,
                        required: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    const Text(
                      'نوع الخصم: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('نسبة %'),
                      selected: isPercent,
                      onSelected: (_) => setSheet(() => isPercent = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('مبلغ ثابت'),
                      selected: !isPercent,
                      onSelected: (_) => setSheet(() => isPercent = false),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md),
                _input(desc, 'الوصف', (v) => null, required: false),
                const SizedBox(height: Gap.xl),
                NeonButton(
                  label: AppStrings.save,
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (!form.currentState!.validate()) return;
                    ref
                        .read(couponsProvider.notifier)
                        .add(
                          Coupon(
                            code: code.text.trim().toUpperCase(),
                            description: desc.text.trim().isEmpty
                                ? 'خصم خاص'
                                : desc.text.trim(),
                            value: double.tryParse(value.text) ?? 0,
                            isPercent: isPercent,
                            minOrder: double.tryParse(minOrder.text) ?? 0,
                            expiry: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          ),
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إنشاء العرض')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────── Orders ───────────────────────────
class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبات',
        subtitle: 'ستظهر الطلبات فور وصولها',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(Gap.lg),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        return GlassCard(
          radius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppStrings.orderNumber} ${o.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  PriceTag(price: o.total, fontSize: 13),
                ],
              ),
              const SizedBox(height: Gap.sm),
              for (int s = 0; s < o.shipments.length; s++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.shipments[s].vendorName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    DropdownButton<OrderStatus>(
                      value: o.shipments[s].status,
                      dropdownColor: AppColors.surfaceVariant,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: [
                        for (final st in OrderStatus.values)
                          DropdownMenuItem(
                            value: st,
                            child: Text(_statusLabel(st)),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref
                              .read(ordersProvider.notifier)
                              .setShipmentStatus(o.id, s, v);
                        }
                      },
                    ),
                  ],
                ),
                if (s != o.shipments.length - 1) const Divider(height: 18),
              ],
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppStrings.statusPending;
      case OrderStatus.processing:
        return AppStrings.statusProcessing;
      case OrderStatus.shipped:
        return AppStrings.statusShipped;
      case OrderStatus.outForDelivery:
        return AppStrings.statusOutForDelivery;
      case OrderStatus.delivered:
        return AppStrings.statusDelivered;
      case OrderStatus.cancelled:
        return AppStrings.statusCancelled;
    }
  }
}

// ─────────────────────────── helpers ───────────────────────────
String _categoryName(List<ProductCategory> categories, String id) {
  for (final c in categories) {
    if (c.id == id) return c.name;
  }
  return 'بدون قسم';
}

Widget _input(
  TextEditingController controller,
  String label,
  String? Function(String?)? validator, {
  bool number = false,
  bool required = true,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    inputFormatters: number
        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
        : null,
    validator: validator,
    decoration: InputDecoration(labelText: label),
  );
}
