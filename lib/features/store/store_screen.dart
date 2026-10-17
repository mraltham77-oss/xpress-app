import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/product_card.dart';

class StoreScreen extends ConsumerStatefulWidget {
  final String vendorId;

  const StoreScreen({super.key, required this.vendorId});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorByIdProvider(widget.vendorId));
    final products = ref.watch(productsByVendorProvider(widget.vendorId));

    if (vendor == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const EmptyState(
          icon: Icons.storefront_outlined,
          title: 'المتجر غير متوفر',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رابط المتجر')),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
                padding: const EdgeInsets.fromLTRB(Gap.lg, 70, Gap.lg, Gap.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: NetImage(
                        url: vendor.avatarUrl,
                        width: 64,
                        height: 64,
                        radius: 32,
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vendor.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (vendor.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vendor.location} • ${vendor.followers}+ متابع',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(Gap.lg),
              child: Row(
                children: [
                  _stat('التقييم', vendor.rating.toStringAsFixed(1)),
                  _divider(),
                  _stat('المنتجات', '${products.length}'),
                  _divider(),
                  _stat(
                    'المتابعون',
                    '${(vendor.followers / 1000).toStringAsFixed(1)}k',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Gap.md),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _following = !_following);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _following
                            ? 'تتابع ${vendor.name} الآن'
                            : 'ألغيت متابعة ${vendor.name}',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  _following ? Icons.check_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(_following ? 'تتابع المتجر' : 'متابعة المتجر'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'منتجات المتجر',
              leadingIcon: Icons.grid_view_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: Gap.md,
                crossAxisSpacing: Gap.md,
                childAspectRatio: 0.585,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ProductCard(
                  product: products[i],
                  onTap: () => context.push('/product/${products[i].id}'),
                ),
                childCount: products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Widget _divider() =>
      Container(width: 1, height: 34, color: AppColors.divider);
}
