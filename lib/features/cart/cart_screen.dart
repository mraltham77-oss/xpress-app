import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/cart_item.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final groups = notifier.groups;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${AppStrings.cartTitle} (${notifier.itemCount})'),
        automaticallyImplyLeading: false,
      ),
      body: cart.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.emptyCart,
              subtitle: AppStrings.emptyCartHint,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                if (groups.length > 1)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سلتك تحتوي منتجات من ${groups.length} متاجر — سيتم تقسيم الطلب إلى شحنات منفصلة.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ...groups.map((g) => _VendorGroup(group: g)),
                const SizedBox(height: 8),
                _CouponRow(),
              ],
            ),
      bottomNavigationBar: cart.isEmpty ? null : _CheckoutBar(),
    );
  }
}

class _VendorGroup extends ConsumerWidget {
  final CartGroup group;

  const _VendorGroup({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final allSelected = group.items.every((i) => i.selected);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _Checkbox(
                  value: allSelected,
                  onTap: () {
                    final value = !allSelected;
                    for (final i in group.items) {
                      if (i.selected != value) notifier.toggleSelect(i);
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        group.vendor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (group.vendor.verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.info,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
          const Divider(),
          ...group.items.map((item) => _CartTile(item: item)),
        ],
      ),
    );
  }
}

class _CartTile extends ConsumerWidget {
  final CartItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Checkbox(
            value: item.selected,
            onTap: () => notifier.toggleSelect(item),
          ),
          const SizedBox(width: 8),
          NetImage(
            url: item.product.images.first,
            width: 78,
            height: 78,
            radius: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
                if (item.color != null || item.size != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      [
                        if (item.color != null) item.color,
                        if (item.size != null) 'مقاس ${item.size}',
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    PriceTag(price: item.unitPrice),
                    const Spacer(),
                    QuantityStepper(
                      value: item.quantity,
                      onDecrement: () => notifier.decrement(item),
                      onIncrement: () => notifier.increment(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _Checkbox({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primary : AppColors.textHint,
            width: 1.6,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/coupons'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: Shadows.card,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            const Text(AppStrings.applyCoupon, style: TextStyle(fontSize: 14)),
            const Spacer(),
            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final cart = ref.watch(cartProvider);
    final count = notifier.selectedCount;
    final subtotal = notifier.selectedSubtotal;
    final allSelected = cart.isNotEmpty && cart.every((i) => i.selected);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => notifier.toggleAll(!allSelected),
                child: Row(
                  children: [
                    _Checkbox(
                      value: allSelected,
                      onTap: () => notifier.toggleAll(!allSelected),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      AppStrings.selectAll,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.total,
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                  PriceTag(price: subtotal, fontSize: 15),
                ],
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: count == 0 ? null : () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(
                  '${AppStrings.checkout} ($count)',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
