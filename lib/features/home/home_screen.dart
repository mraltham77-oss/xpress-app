import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/premium.dart';
import '../../shared/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final flash = ref.watch(flashDealsProvider);
    final catalog = ref.watch(catalogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            Future<void>.delayed(const Duration(milliseconds: 900)),
        child: CustomScrollView(
          slivers: [
            const _HomeHeader(),
            const SliverToBoxAdapter(child: _DemoBanner()),
            const SliverToBoxAdapter(child: _PromoCarousel()),
            const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: AppStrings.categories,
                subtitle: 'تصفّح حسب القسم',
                leadingIcon: Icons.grid_view_rounded,
                onSeeAll: null,
              ),
            ),
            SliverToBoxAdapter(child: _CategoryGrid(categories: categories)),
            if (flash.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'عروض اليوم',
                  subtitle: 'خصومات تنتهي قريبًا',
                  leadingIcon: Icons.bolt_rounded,
                  accent: AppColors.primaryDark,
                  onSeeAll: () => context.push('/products?title=عروض فلاش'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 268,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                    itemCount: flash.length,
                    separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
                    itemBuilder: (context, i) => _FlashCard(product: flash[i]),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SectionHeader(
                title: AppStrings.recommendedForYou,
                subtitle: 'مختار بعناية من أجلك',
                leadingIcon: Icons.auto_awesome_rounded,
                onSeeAll: () => context.push('/products?title=كل المنتجات'),
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
                  (context, i) =>
                      ProductCard(
                            product: catalog[i],
                            onTap: () =>
                                context.push('/product/${catalog[i].id}'),
                          )
                          .animate()
                          .fadeIn(delay: (60 * (i % 6)).ms, duration: 350.ms)
                          .slideY(begin: 0.12, end: 0),
                  childCount: catalog.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Gap.md)),
            const SliverToBoxAdapter(child: _TrustBar()),
            const SliverToBoxAdapter(child: SizedBox(height: Gap.xxl)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).length;
    final notifCount = ref
        .watch(notificationsProvider)
        .where((n) => !n.read)
        .length;

    Widget icon(
      IconData ic,
      int badge,
      VoidCallback onTap, {
      Color badgeColor = AppColors.primary,
    }) {
      final withBadge = badge > 0;
      final target = withBadge
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(ic, color: Colors.white),
                PositionedDirectional(
                  top: -7,
                  end: -7,
                  child: Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      boxShadow: Shadows.soft,
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Icon(ic, color: Colors.white);
      return IconButton(onPressed: onTap, icon: target);
    }

    void goCart() {
      ref.read(shellTabProvider.notifier).select(3);
      context.go('/home');
    }

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 58,
      titleSpacing: Gap.lg,
      title: Row(
        textDirection: TextDirection.ltr,
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: const XpressLogo(size: 30, fontSize: 15),
          ),
          const Spacer(),
          icon(
            Icons.notifications_none_rounded,
            notifCount,
            () => context.push('/notifications'),
            badgeColor: AppColors.primary,
          ),
          icon(
            Icons.shopping_cart_outlined,
            cartCount,
            goCart,
            badgeColor: AppColors.danger,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
          child: GestureDetector(
            onTap: () => context.push('/search'),
            child: AbsorbPointer(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 21,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        AppStrings.searchHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 17,
                      ),
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
}

/// شريط وضوح: يُذكّر بأن البيانات المعروضة تجريبية (Mock) وليست مخزونًا حقيقيًا.
class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'وضع تجريبي — المنتجات والأسعار بيانات توضيحية وليست مخزونًا حقيقيًا.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBar extends StatelessWidget {
  const _TrustBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Gap.md),
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: Row(
        children: const [
          _TrustItem(
            icon: Icons.verified_user_rounded,
            label: 'دفع آمن',
            color: AppColors.success,
          ),
          _TrustItem(
            icon: Icons.local_shipping_rounded,
            label: 'شحن سريع',
            color: AppColors.info,
          ),
          _TrustItem(
            icon: Icons.workspace_premium_rounded,
            label: 'منتجات أصلية',
            color: AppColors.accent,
          ),
          _TrustItem(
            icon: Icons.support_agent_rounded,
            label: 'دعم فني',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  static const _banners = [
    _Banner(
      eyebrow: 'عروض قوية',
      lead: 'خصومات تصل إلى',
      highlight: '70%',
      cta: 'تسوّق الآن',
      gradient: [Color(0xFF160B30), Color(0xFF5B19B7), Color(0xFFFF5A20)],
      image: 'https://picsum.photos/seed/xp-banner-1/500/500',
    ),
    _Banner(
      eyebrow: 'توصيل مجاني',
      lead: 'شحن مجاني على الطلبات فوق',
      highlight: '300ج',
      cta: 'اطلب الآن',
      gradient: [Color(0xFF0E1330), Color(0xFF2A1A6E), Color(0xFF7A2CFF)],
      image: 'https://picsum.photos/seed/xp-banner-2/500/500',
    ),
    _Banner(
      eyebrow: 'دفع آمن',
      lead: 'أموالك محفوظة حتى الاستلام',
      highlight: '100%',
      cta: 'اكتشف',
      gradient: [Color(0xFF0F1A2E), Color(0xFF123A6E), Color(0xFF0E9488)],
      image: 'https://picsum.photos/seed/xp-banner-3/500/500',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _page = (_page + 1) % _banners.length;
      _controller.animateToPage(
        _page,
        duration: Motion.slow,
        curve: Motion.emphasize,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _BannerCard(banner: _banners[i]),
            ),
          ),
        ),
        const SizedBox(height: Gap.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: Motion.base,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == i ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _page == i ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner {
  final String eyebrow;
  final String lead;
  final String highlight;
  final String cta;
  final List<Color> gradient;
  final String image;
  const _Banner({
    required this.eyebrow,
    required this.lead,
    required this.highlight,
    required this.cta,
    required this.gradient,
    required this.image,
  });
}

/// بانر العروض الرئيسي بتصميم XPRESS (نص + نسبة خصم كبيرة + صورة منتج).
class _BannerCard extends StatelessWidget {
  final _Banner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final b = banner;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: b.gradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: Shadows.glowSoft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            top: -46,
            start: -30,
            child: _blob(AppColors.primary.withValues(alpha: 0.55), 150),
          ),
          PositionedDirectional(
            bottom: -60,
            end: 60,
            child: _blob(AppColors.neon.withValues(alpha: 0.35), 130),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          b.eyebrow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.lead,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GradientText(
                          b.highlight,
                          fontSize: 38,
                          gradient: AppColors.flashGradient,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.xGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: Shadows.glowOrange,
                          ),
                          child: Text(
                            b.cta,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: NetImage(url: b.image, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

class _CategoryGrid extends StatelessWidget {
  final List<dynamic> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: Gap.lg,
          crossAxisSpacing: Gap.sm,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) => _CategoryTile(
          category: categories[i],
          onTap: () => context.push(
            '/category/${categories[i].id}?name=${Uri.encodeComponent(categories[i].name)}',
          ),
        ),
      ),
    );
  }
}

/// أيقونة كل قسم (رسم خطّي أبيض داخل مربّع بنفسجي) كما في التصميم.
const Map<String, IconData> _categoryIcons = {
  'c1': Icons.smartphone_rounded,
  'c2': Icons.checkroom_rounded,
  'c3': Icons.chair_rounded,
  'c4': Icons.sports_soccer_rounded,
  'c5': Icons.spa_rounded,
  'c6': Icons.toys_rounded,
  'c7': Icons.directions_car_rounded,
  'c8': Icons.watch_rounded,
};

class _CategoryTile extends StatelessWidget {
  final dynamic category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = category;
    final icon = _categoryIcons[c.id] ?? Icons.category_rounded;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.categoryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: Shadows.glowSoft,
            ),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final dynamic product;

  const _FlashCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: 156,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: Shadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 156,
                  width: double.infinity,
                  child: NetImage(url: product.images.first, fit: BoxFit.cover),
                ),
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.flashGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${product.discountPercent}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  child: _FlashProgress(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  PriceTag(
                    price: product.price,
                    oldPrice: product.oldPrice,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 8),
                  _CountdownChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashProgress extends StatelessWidget {
  const _FlashProgress();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      color: AppColors.primarySoft,
      child: const FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 0.66,
        child: ColoredBox(color: AppColors.primary),
      ),
    );
  }
}

class _CountdownChip extends StatefulWidget {
  @override
  State<_CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<_CountdownChip> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (mounted) setState(() => _left = end.difference(now));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _two(_left.inHours);
    final m = _two(_left.inMinutes % 60);
    final s = _two(_left.inSeconds % 60);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          _box(h),
          const _Colon(),
          _box(m),
          const _Colon(),
          _box(s),
        ],
      ),
    );
  }

  Widget _box(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    ),
  );
}

class _Colon extends StatelessWidget {
  const _Colon();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 2),
    child: Text(
      ':',
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, height: 1.4),
    ),
  );
}
