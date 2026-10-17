import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final wallet = ref.watch(walletProvider);
    final orders = ref.watch(ordersProvider);
    final wishlistCount = ref.watch(wishlistProvider).length;
    final couponsCount = ref.watch(couponsProvider).length;
    final unread = ref.watch(notificationsProvider.notifier).unread;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 172,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => context.push('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(color: AppColors.background),
                padding: const EdgeInsets.fromLTRB(Gap.lg, 70, Gap.lg, Gap.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: AppColors.textSecondary,
                                size: 36,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: Gap.lg),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? AppStrings.guest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // عضوية ذهبية كما في تصميم XPRESS
                          if (user != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: Shadows.soft,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 14,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'عضوية ذهبية',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              'سجّل دخولك للاستفادة من كل الميزات',
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (user == null)
                      FilledButton(
                        onPressed: () => context.push('/login'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(AppStrings.login),
                      )
                    else
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: GestureDetector(
                onTap: () => context.push('/wallet'),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.walletGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: Shadows.floating,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.availableBalance,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                Money.format(wallet.available),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: Gap.lg),
              padding: const EdgeInsets.symmetric(vertical: Gap.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: Shadows.card,
              ),
              child: Row(
                children: [
                  _QuickStat(
                    label: AppStrings.wishlist,
                    value: '$wishlistCount',
                    icon: Icons.favorite_border_rounded,
                    onTap: () => context.push('/wishlist'),
                  ),
                  _vdiv(),
                  _QuickStat(
                    label: AppStrings.coupons,
                    value: '$couponsCount',
                    icon: Icons.local_offer_outlined,
                    onTap: () => context.push('/coupons'),
                  ),
                  _vdiv(),
                  _QuickStat(
                    label: AppStrings.orders,
                    value: '${orders.length}',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => context.push('/orders'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: Shadows.card,
              ),
              child: Column(
                children: [
                  if (user?.isAdmin ?? false)
                    _MenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: AppStrings.adminDashboard,
                      onTap: () => context.push('/admin'),
                      trailing: const PillBadge(
                        text: 'مشرف',
                        fontSize: 10,
                        color: AppColors.accent,
                        background: AppColors.primarySoft,
                      ),
                    ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: AppStrings.myOrders,
                    onTap: () => context.push('/orders'),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: AppStrings.addresses,
                    onTap: () => context.push('/addresses'),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: AppStrings.wishlist,
                    onTap: () => context.push('/wishlist'),
                  ),
                  _MenuItem(
                    icon: Icons.local_offer_outlined,
                    label: AppStrings.coupons,
                    onTap: () => context.push('/coupons'),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: AppStrings.myWallet,
                    onTap: () => context.push('/wallet'),
                  ),
                  _MenuItem(
                    icon: Icons.storefront_outlined,
                    label: AppStrings.becomeSeller,
                    onTap: () => context.push('/become-seller'),
                    trailing: const PillBadge(text: 'جديد', fontSize: 10),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: AppStrings.helpCenter,
                    onTap: () => context.push('/help'),
                  ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.about,
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              child: user == null
                  ? ElevatedButton.icon(
                      onPressed: () => context.push('/login'),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text(AppStrings.login),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authProvider.notifier).logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تسجيل الخروج')),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(AppStrings.logout),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.xl)),
        ],
      ),
    );
  }

  Widget _vdiv() => Container(width: 1, height: 40, color: AppColors.divider);
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            ?trailing,
            const SizedBox(width: 6),
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
