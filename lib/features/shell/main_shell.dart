import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/providers/providers.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../home/home_screen.dart';
import '../wishlist/wishlist_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final _tabs = const [
    _TabSpec(AppStrings.home, 'assets/xpress/icons/navigation/home.svg'),
    _TabSpec(
      AppStrings.categories,
      'assets/xpress/icons/navigation/categories.svg',
    ),
    _TabSpec(
      AppStrings.wishlistNav,
      'assets/xpress/icons/navigation/heart.svg',
    ),
    _TabSpec(AppStrings.cart, 'assets/xpress/icons/navigation/cart.svg'),
    _TabSpec(AppStrings.account, 'assets/xpress/icons/navigation/profile.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref
        .watch(cartProvider)
        .fold<int>(0, (s, i) => s + i.quantity);
    final index = ref.watch(shellTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          CategoriesScreen(),
          WishlistScreen(),
          CartScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = index == i;
                final isCart = i == 3;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref.read(shellTabProvider.notifier).select(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Motion.base,
                          curve: Motion.ease,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected ? AppColors.brandGradient : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selected ? Shadows.glowSoft : null,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedScale(
                                scale: selected ? 1 : 0.92,
                                duration: Motion.base,
                                child: SvgPicture.asset(
                                  tab.asset,
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              if (isCart && cartCount > 0)
                                PositionedDirectional(
                                  top: -7,
                                  end: -10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      '$cartCount',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  final String label;
  final String asset;
  const _TabSpec(this.label, this.asset);
}
