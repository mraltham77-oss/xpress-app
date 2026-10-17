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

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: AppStrings.noResults,
        ),
      );
    }

    final notifier = ref.read(ordersProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('تفاصيل الطلب'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          _SuccessHeader(order: order),
          const SizedBox(height: Gap.md),
          // توضيح الصدق: بيانات التتبع والشحن تجريبية في هذه النسخة.
          Container(
            margin: const EdgeInsets.only(bottom: Gap.md),
            padding: const EdgeInsets.all(Gap.md),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'بيانات الطلب والتتبع والشحن توضيحية (وضع تجريبي) ولا تمثّل تتبعًا حيًا.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.warning,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'معلومات الطلب',
            child: Column(
              children: [
                _row('رقم الطلب', order.id),
                _row('التاريخ', AppDate.short(order.date)),
                _row(
                  'طريقة الدفع',
                  order.paymentLabel.isEmpty ? '—' : order.paymentLabel,
                ),
                _row(
                  'العنوان',
                  order.addressSummary.isEmpty ? '—' : order.addressSummary,
                ),
              ],
            ),
          ),
          if (order.escrowHeld)
            Container(
              margin: const EdgeInsets.only(bottom: Gap.md),
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      '${Money.format(order.total)} محتجزة بأمان. لن تصل للبائع حتى تأكيد الاستلام.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ...order.shipments.map((s) => _ShipmentCard(shipment: s)),
          const _MapStrip(),
          const SizedBox(height: Gap.md),
          _Section(
            title: 'ملخص الدفع',
            child: Column(
              children: [
                _row(
                  'المجموع الفرعي',
                  Money.format(
                    order.subtotal == 0 ? order.total : order.subtotal,
                  ),
                ),
                _row(
                  'الشحن',
                  order.shipping == 0 ? 'مجاني' : Money.format(order.shipping),
                ),
                if (order.discount > 0)
                  _row(
                    'الخصم',
                    '- ${Money.format(order.discount)}',
                    color: AppColors.success,
                  ),
                const Divider(height: 20),
                _row('الإجمالي', Money.format(order.total), bold: true),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          if (order.escrowHeld)
            ElevatedButton(
              onPressed: () {
                notifier.confirmReceipt(order);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تأكيد الاستلام وإفراج المبلغ للبائع 🎉'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text(AppStrings.confirmReceipt),
            )
          else if (!order.reviewed)
            ElevatedButton.icon(
              onPressed: () {
                final pid = order.shipments.first.productIds.isEmpty
                    ? ''
                    : order.shipments.first.productIds.first;
                context.push('/review?product=$pid&order=${order.id}');
              },
              icon: const Icon(Icons.star_rounded, size: 20),
              label: const Text('قيّم تجربتك'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.storefront_rounded, size: 20),
              label: const Text('متابعة التسوق'),
            ),
          const SizedBox(height: Gap.xl),
        ],
      ),
    );
  }

  static Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  final Order order;

  const _SuccessHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: Gap.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'شكرًا لك! تم استلام طلبك',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سيتم تجهيز ${order.shipments.length} شحنة من متاجر مختلفة',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final OrderShipment shipment;

  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final flow = shipment.timeline;
    final currentIndex = flow.indexOf(shipment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetImage(
                url: shipment.vendorAvatar,
                width: 40,
                height: 40,
                radius: 10,
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.vendorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shipment.itemTitles.join('، '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (shipment.trackingNo.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.7),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: Shadows.glowSoft,
                    ),
                    child: const Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.carrier,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'رقم التتبع: ${shipment.trackingNo}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppStrings.trackShipment,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.sm),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم تحويلك لخدمة عملاء شركة الشحن…'),
                  backgroundColor: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 44),
              ),
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text(
                'تواصل مع الشركة',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
          const SizedBox(height: Gap.lg),
          ...List.generate(flow.length, (i) {
            final done = i <= currentIndex;
            final isLast = i == flow.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: done ? AppColors.primary : AppColors.divider,
                            width: 2,
                          ),
                        ),
                        child: done
                            ? const Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: done && i < currentIndex
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: Gap.md),
                  Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : Gap.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label(flow[i]),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: done
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: done
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        if (_sub(flow[i]).isNotEmpty)
                          Text(
                            _sub(flow[i]),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            );
          }),
          const SizedBox(height: Gap.sm),
          Row(
            children: [
              Text(
                '${AppStrings.total}: ',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              PriceTag(price: shipment.amount, fontSize: 13),
            ],
          ),
        ],
      ),
    );
  }

  String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'تم استلام الطلب';
      case OrderStatus.processing:
        return 'قيد التحضير';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.outForDelivery:
        return 'جارٍ التوصيل';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String _sub(OrderStatus s) {
    switch (s) {
      case OrderStatus.shipped:
        return 'تم تسليم الشحنة لشركة التوصيل';
      case OrderStatus.outForDelivery:
        return 'المندوب في الطريق إليك';
      case OrderStatus.delivered:
        return 'وصل إلى العنوان';
      default:
        return '';
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: Gap.md),
          child,
        ],
      ),
    );
  }
}

/// شريط خريطة زخرفي (خلفية خرائط + دبوس المندوب) كما في تصميم XPRESS.
class _MapStrip extends StatelessWidget {
  const _MapStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: Gap.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17.5),
        child: Stack(
          children: [
            NetImage(
              url: 'https://picsum.photos/seed/xpr-map/800/400',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
            Container(color: AppColors.background.withValues(alpha: 0.55)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: Shadows.glow,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      'موقع الطلب — القاهرة',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
