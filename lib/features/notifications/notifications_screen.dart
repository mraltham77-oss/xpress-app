import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_notification.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('الإشعارات'),
        actions: [
          if (notifier.unread > 0)
            TextButton(
              onPressed: notifier.markAllRead,
              child: const Text('تحديد الكل كمقروء'),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'لا توجد إشعارات',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(Gap.md),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gap.sm),
              itemBuilder: (context, i) => _Tile(
                item: items[i],
                onTap: () => notifier.markRead(items[i].id),
              ),
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _Tile({required this.item, required this.onTap});

  (IconData, Color, Color) get _style {
    switch (item.kind) {
      case NotificationKind.order:
        return (
          Icons.local_shipping_rounded,
          AppColors.info,
          AppColors.infoSoft,
        );
      case NotificationKind.promo:
        return (
          Icons.local_offer_rounded,
          AppColors.primary,
          AppColors.primarySoft,
        );
      case NotificationKind.wallet:
        return (
          Icons.account_balance_wallet_rounded,
          AppColors.success,
          AppColors.successSoft,
        );
      case NotificationKind.system:
        return (
          Icons.campaign_rounded,
          AppColors.warning,
          AppColors.warningSoft,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = _style;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Gap.md),
        decoration: BoxDecoration(
          color: item.read
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16),
          boxShadow: Shadows.card,
          border: item.read
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        AppDate.relative(item.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.read) ...[
              const SizedBox(width: Gap.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
