import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final bool showBack;
  const OrdersScreen({super.key, this.showBack = false});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);

    List<Order> filtered(int index) {
      switch (index) {
        case 1:
          return orders
              .where(
                (o) =>
                    o.overallStatus == OrderStatus.processing ||
                    o.overallStatus == OrderStatus.pending,
              )
              .toList();
        case 2:
          return orders
              .where(
                (o) =>
                    o.overallStatus == OrderStatus.shipped ||
                    o.overallStatus == OrderStatus.outForDelivery,
              )
              .toList();
        case 3:
          return orders.where((o) => o.allDelivered && !o.reviewed).toList();
        default:
          return orders;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBack,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text(AppStrings.myOrders),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: AppStrings.allOrders),
            Tab(text: AppStrings.toShip),
            Tab(text: AppStrings.toReceive),
            Tab(text: AppStrings.toReview),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: List.generate(4, (i) {
          final list = filtered(i);
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'لا توجد طلبات هنا',
              subtitle: 'ستظهر طلباتك في هذا القسم تلقائيًا',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Gap.md),
            itemCount: list.length,
            itemBuilder: (context, j) => _OrderCard(order: list[j]),
          );
        }),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: Gap.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: Shadows.card,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppStrings.orderNumber} ${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _StatusChip(status: order.overallStatus),
                ],
              ),
            ),
            const Divider(height: 1),
            ...order.shipments.map((s) => _ShipmentRow(shipment: s)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Row(
                children: [
                  Text(
                    AppDate.short(order.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                  const Spacer(),
                  PriceTag(price: order.total, fontSize: 13),
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentRow extends StatelessWidget {
  final OrderShipment shipment;

  const _ShipmentRow({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          NetImage(
            url: shipment.vendorAvatar,
            width: 44,
            height: 44,
            radius: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shipment.vendorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  shipment.itemTitles.join('، '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${shipment.itemCount} منتج • ${Money.format(shipment.amount)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: shipment.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (String, Color, Color) _style(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return (
          AppStrings.statusPending,
          AppColors.warning,
          AppColors.warningSoft,
        );
      case OrderStatus.processing:
        return (
          AppStrings.statusProcessing,
          AppColors.info,
          AppColors.infoSoft,
        );
      case OrderStatus.shipped:
        return (AppStrings.statusShipped, AppColors.info, AppColors.infoSoft);
      case OrderStatus.outForDelivery:
        return (
          AppStrings.statusOutForDelivery,
          AppColors.primary,
          AppColors.primarySoft,
        );
      case OrderStatus.delivered:
        return (
          AppStrings.statusDelivered,
          AppColors.success,
          AppColors.successSoft,
        );
      case OrderStatus.cancelled:
        return (
          AppStrings.statusCancelled,
          AppColors.danger,
          AppColors.dangerSoft,
        );
    }
  }
}
