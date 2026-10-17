import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  final bool showBack;
  const WishlistScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(wishlistProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text('المفضلة (${products.length})'),
      ),
      body: products.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'قائمة المفضلة فارغة',
              subtitle: 'اضغط على ♡ في أي منتج لإضافته هنا',
              actionLabel: 'تصفّح المنتجات',
              onAction: () => context.go('/home'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(Gap.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Gap.md,
                crossAxisSpacing: Gap.md,
                childAspectRatio: 0.585,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) => ProductCard(
                product: products[i],
                onTap: () => context.push('/product/${products[i].id}'),
              ),
            ),
    );
  }
}
