import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/product.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/pressable.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _scroll = ScrollController();
  int _imageIndex = 0;
  int _colorIndex = 0;
  int? _sizeIndex;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool get _pinned => _scroll.hasClients && _scroll.offset > 300;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));
    final isFav = ref.watch(wishlistProvider).contains(widget.productId);

    if (product == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: AppStrings.noResults,
        ),
      );
    }

    final unitPrice = _sizeIndex != null
        ? product.sizes[_sizeIndex!].price
        : product.price;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              _Gallery(
                product: product,
                index: _imageIndex,
                onChanged: (i) => setState(() => _imageIndex = i),
              ),
              SliverToBoxAdapter(child: _priceBlock(product, unitPrice)),
              SliverToBoxAdapter(child: _variants(product)),
              SliverToBoxAdapter(child: _vendorCard(product)),
              SliverToBoxAdapter(child: _escrowBanner()),
              SliverToBoxAdapter(child: _description(product)),
              SliverToBoxAdapter(child: _reviews(product)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _TopBar(
            pinned: _pinned,
            isFav: isFav,
            onBack: () => context.pop(),
            onFav: () =>
                ref.read(wishlistProvider.notifier).toggle(widget.productId),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        onChat: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('جارٍ فتح محادثة البائع...')),
        ),
        onAddToCart: () => _add(context, unitPrice),
        onBuyNow: () => _add(context, unitPrice, buyNow: true),
      ),
    );
  }

  void _add(BuildContext context, double unitPrice, {bool buyNow = false}) {
    final product = ref.read(productByIdProvider(widget.productId))!;
    ref
        .read(cartProvider.notifier)
        .add(
          product,
          qty: 1,
          color: product.colors.isNotEmpty ? product.colors[_colorIndex] : null,
          size: _sizeIndex != null ? product.sizes[_sizeIndex!].label : null,
        );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(buyNow ? 'جارٍ تجهيز طلبك...' : AppStrings.addedToCart),
            ],
          ),
          action: buyNow
              ? null
              : SnackBarAction(
                  label: AppStrings.viewCart,
                  textColor: AppColors.primary,
                  onPressed: () {
                    ref.read(shellTabProvider.notifier).select(3);
                    context.go('/home');
                  },
                ),
        ),
      );
    if (buyNow) context.pop();
  }

  Widget _priceBlock(Product p, double unitPrice) {
    final decimal =
        ref.watch(reviewsProvider.notifier).averageFor(p.id) ?? p.rating;
    final reviewsCount = ref
        .watch(reviewsProvider.notifier)
        .forProduct(p.id)
        .length;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceTag(price: unitPrice, oldPrice: p.oldPrice, fontSize: 20),
              const Spacer(),
              if (p.discountPercent > 0)
                PillBadge(
                  text: 'وفّر ${p.discountPercent}%',
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                  icon: Icons.local_fire_department_rounded,
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 16.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              RatingStars(
                rating: decimal,
                reviews: reviewsCount == 0 ? p.reviewsCount : reviewsCount,
              ),
              Container(
                width: 1,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: AppColors.divider,
              ),
              Text(
                '${p.soldCount}+ ${AppStrings.sold}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _variants(Product p) {
    if (p.colors.isEmpty && p.sizes.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: Gap.sm),
      color: AppColors.surface,
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.colors.isNotEmpty) ...[
            _SectionLabel('${AppStrings.color}:  ${p.colors[_colorIndex]}'),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: Gap.md,
              runSpacing: Gap.md,
              children: List.generate(p.colors.length, (i) {
                return _ColorSwatch(
                  label: p.colors[i],
                  selected: _colorIndex == i,
                  onTap: () => setState(() => _colorIndex = i),
                );
              }),
            ),
            if (p.sizes.isNotEmpty) const SizedBox(height: Gap.xl),
          ],
          if (p.sizes.isNotEmpty) ...[
            _SectionLabel(
              '${AppStrings.size}: ${_sizeIndex == null ? "اختر المقاس" : p.sizes[_sizeIndex!].label}',
            ),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: Gap.md,
              runSpacing: Gap.md,
              children: List.generate(p.sizes.length, (i) {
                final sel = _sizeIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _sizeIndex = i),
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      p.sizes[i].label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: sel ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _vendorCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(top: Gap.sm),
      color: AppColors.surface,
      padding: const EdgeInsets.all(Gap.lg),
      child: Row(
        children: [
          NetImage(url: p.vendor.avatarUrl, width: 50, height: 50, radius: 14),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.vendor.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (p.vendor.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.info,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    RatingStars(rating: p.vendor.rating, size: 12),
                    const SizedBox(width: 10),
                    Text(
                      '${p.vendor.followers}+ متابع',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.push('/store/${p.vendor.id}'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('زيارة المتجر', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _escrowBanner() {
    return Container(
      margin: const EdgeInsets.only(top: Gap.sm),
      color: AppColors.successSoft,
      padding: const EdgeInsets.all(Gap.lg),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.safePayment,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${AppStrings.expectedDelivery}: 5-7 ${AppStrings.days}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
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

  Widget _description(Product p) {
    return Container(
      margin: const EdgeInsets.only(top: Gap.sm),
      color: AppColors.surface,
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(AppStrings.productDetails),
          const SizedBox(height: Gap.md),
          AnimatedCrossFade(
            firstChild: Text(
              p.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.9,
                color: AppColors.textSecondary,
              ),
            ),
            secondChild: Text(
              p.description,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.9,
                color: AppColors.textSecondary,
              ),
            ),
            crossFadeState: _descExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Motion.base,
          ),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _descExpanded ? 'أقل' : 'المزيد',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  Icon(
                    _descExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (p.specifications.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            const Divider(),
            const SizedBox(height: Gap.md),
            const _SectionLabel(AppStrings.specifications),
            const SizedBox(height: Gap.sm),
            ...p.specifications.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(s, style: const TextStyle(fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reviews(Product p) {
    final reviews = ref.watch(reviewsProvider.notifier).forProduct(p.id);
    final decimal =
        ref.watch(reviewsProvider.notifier).averageFor(p.id) ?? p.rating;
    return Container(
      margin: const EdgeInsets.only(top: Gap.sm),
      color: AppColors.surface,
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionLabel(AppStrings.reviews),
              const Spacer(),
              Text(
                'عرض الكل (${reviews.length})',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    decimal.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingStars(rating: decimal, showValue: false, size: 12),
                ],
              ),
              const SizedBox(width: Gap.xl),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final stars = 5 - i;
                    final count = reviews
                        .where((r) => r.rating == stars)
                        .length;
                    final factor = reviews.isEmpty
                        ? 0.0
                        : count / reviews.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Text(
                            '$stars',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: factor,
                                minHeight: 6,
                                backgroundColor: AppColors.surfaceVariant,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          const Divider(),
          const SizedBox(height: Gap.md),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Gap.lg),
              child: Center(
                child: Text(
                  'لا توجد تقييمات بعد — كن أول من يقيّم!',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ),
            )
          else
            ...reviews
                .take(4)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: Gap.lg),
                    child: _reviewItem(r.userName, r.comment, r.rating),
                  ),
                ),
          OutlinedButton.icon(
            onPressed: () => context.push('/review?product=${p.id}'),
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('اكتب تقييمك'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewItem(String name, String text, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const Spacer(),
            RatingStars(rating: stars.toDouble(), showValue: false, size: 12),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            height: 1.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _map = {
    'أسود': Color(0xFF1F1F1F),
    'أبيض': Color(0xFFF2F2F2),
    'أزرق': Color(0xFF2F6BFF),
    'ذهبي': Color(0xFFD4AF37),
    'فضي': Color(0xFFC0C6CF),
    'وردي': Color(0xFFF48FB1),
    'رمادي': Color(0xFF8A8F98),
    'بني': Color(0xFF8B5E3C),
    'بيج': Color(0xFFE5D3B3),
  };

  @override
  Widget build(BuildContext context) {
    final color = _map[label] ?? AppColors.surfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final Product product;
  final int index;
  final ValueChanged<int> onChanged;

  const _Gallery({
    required this.product,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 400,
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: product.images.length,
              onPageChanged: onChanged,
              itemBuilder: (context, i) {
                final image = NetImage(
                  url: product.images[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
                return i == 0
                    ? Hero(tag: 'product-${product.id}', child: image)
                    : image;
              },
            ),
            PositionedDirectional(
              bottom: 16,
              start: 0,
              end: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.images.length,
                  (i) => AnimatedContainer(
                    duration: Motion.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == i ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: index == i
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: Shadows.soft,
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 14,
              end: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}/${product.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool pinned;
  final bool isFav;
  final VoidCallback onBack;
  final VoidCallback onFav;

  const _TopBar({
    required this.pinned,
    required this.isFav,
    required this.onBack,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.base,
      color: pinned ? AppColors.surface : Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            children: [
              _circle(pinned, Icons.arrow_forward_rounded, onBack),
              const Spacer(),
              _circle(
                pinned,
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                onFav,
                active: isFav,
              ),
              const SizedBox(width: 10),
              _circle(
                pinned,
                Icons.share_outlined,
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رابط المنتج')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(
    bool pinned,
    IconData icon,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: pinned
              ? AppColors.surfaceVariant
              : Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
          boxShadow: pinned ? null : Shadows.soft,
        ),
        child: Icon(
          icon,
          size: 22,
          color: active
              ? AppColors.primary
              : (pinned ? AppColors.textPrimary : Colors.white),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onChat;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _BottomBar({
    required this.onChat,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, Gap.md),
          child: Row(
            children: [
              _iconAction(
                Icons.chat_bubble_outline_rounded,
                AppStrings.chatSeller,
                onChat,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddToCart,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    AppStrings.addToCart,
                    style: TextStyle(fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBuyNow,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    AppStrings.buyNow,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, String label, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 23, color: AppColors.textSecondary),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
