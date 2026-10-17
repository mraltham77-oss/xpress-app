import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/product.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/product_card.dart';

enum SortMode { bestMatch, priceLow, priceHigh, rating, mostSold }

class ProductListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String title;
  final String? query;

  const ProductListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.query,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  SortMode _sort = SortMode.bestMatch;
  RangeValues? _price;
  double _minRating = 0;
  bool _freeShipping = false;
  bool _inStock = false;

  bool get _hasFilters =>
      _price != null || _minRating > 0 || _freeShipping || _inStock;

  List<Product> _apply(List<Product> input) {
    var list = [...input];

    if (widget.query != null && widget.query!.trim().isNotEmpty) {
      final q = widget.query!.trim();
      list = list
          .where((p) => p.title.contains(q) || p.vendor.name.contains(q))
          .toList();
    }
    if (_price != null) {
      list = list
          .where((p) => p.price >= _price!.start && p.price <= _price!.end)
          .toList();
    }
    if (_minRating > 0) {
      list = list.where((p) => p.rating >= _minRating).toList();
    }
    if (_freeShipping) list = list.where((p) => p.freeShipping).toList();
    if (_inStock) list = list.where((p) => p.stock > 0).toList();

    switch (_sort) {
      case SortMode.bestMatch:
        break;
      case SortMode.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortMode.mostSold:
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.categoryId == null
        ? ref.watch(catalogProvider)
        : ref.watch(productsByCategoryProvider(widget.categoryId!));
    final products = _apply(base);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          _SortBar(
            current: _sort,
            onChanged: (s) => setState(() => _sort = s),
            count: products.length,
            filterActive: _hasFilters,
            onFilter: _openFilterSheet,
          ),
          Expanded(
            child: products.isEmpty
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.noResults,
                    subtitle: 'جرّب تعديل الفلاتر أو كلمة البحث',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(Gap.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    RangeValues draftPrice = _price ?? const RangeValues(0, 5000);
    double draftRating = _minRating;
    bool draftFree = _freeShipping;
    bool draftStock = _inStock;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
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
              Row(
                children: [
                  const Text(
                    AppStrings.filter,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setSheet(() {
                      draftPrice = const RangeValues(0, 5000);
                      draftRating = 0;
                      draftFree = false;
                      draftStock = false;
                    }),
                    child: const Text(AppStrings.clearFilters),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Text(
                '${AppStrings.priceRange}: ${Money.format(draftPrice.start)} - ${Money.format(draftPrice.end)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              RangeSlider(
                values: draftPrice,
                max: 5000,
                divisions: 50,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceVariant,
                onChanged: (v) => setSheet(() => draftPrice = v),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                AppStrings.minRating,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: Gap.sm),
              Wrap(
                spacing: 8,
                children: [0, 3, 4, 4.5]
                    .map(
                      (r) => ChoiceChip(
                        label: Text(r == 0 ? 'الكل' : '$r ${AppStrings.andUp}'),
                        selected: draftRating == r,
                        onSelected: (_) =>
                            setSheet(() => draftRating = r.toDouble()),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: Gap.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: const Text(
                  AppStrings.freeShippingOnly,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                value: draftFree,
                onChanged: (v) => setSheet(() => draftFree = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: const Text(
                  AppStrings.inStockOnly,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                value: draftStock,
                onChanged: (v) => setSheet(() => draftStock = v),
              ),
              const SizedBox(height: Gap.lg),
              NeonButton(
                label: AppStrings.applyFilters,
                icon: Icons.tune_rounded,
                onPressed: () {
                  setState(() {
                    _price = draftPrice.start == 0 && draftPrice.end == 5000
                        ? null
                        : draftPrice;
                    _minRating = draftRating;
                    _freeShipping = draftFree;
                    _inStock = draftStock;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final SortMode current;
  final ValueChanged<SortMode> onChanged;
  final int count;
  final bool filterActive;
  final VoidCallback onFilter;

  const _SortBar({
    required this.current,
    required this.onChanged,
    required this.count,
    required this.filterActive,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      child: Row(
        children: [
          Text(
            '$count ${AppStrings.productsCount}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onFilter,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: filterActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.filter,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: filterActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (filterActive)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 18, color: AppColors.divider),
          InkWell(
            onTap: () => _openSortSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _label(current),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(SortMode s) {
    switch (s) {
      case SortMode.bestMatch:
        return AppStrings.bestMatch;
      case SortMode.priceLow:
        return AppStrings.priceLowHigh;
      case SortMode.priceHigh:
        return AppStrings.priceHighLow;
      case SortMode.rating:
        return AppStrings.bestRating;
      case SortMode.mostSold:
        return AppStrings.mostSold;
    }
  }

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Text(
                AppStrings.sortBy,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            ...SortMode.values.map(
              (s) => ListTile(
                title: Text(
                  _label(s),
                  style: TextStyle(
                    fontWeight: current == s
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: current == s
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: current == s
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged(s);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: Gap.md),
          ],
        ),
      ),
    );
  }
}
