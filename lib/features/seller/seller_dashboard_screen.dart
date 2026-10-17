import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product.dart';
import '../../data/models/vendor.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';

/// لوحة البائع الحقيقية: متجري + منتجاتي + الطلبات الواردة.
class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final storeAsync = ref.watch(myStoreProvider);

    if (user == null) {
      return _scaffold(
        context,
        _centered(
          icon: Icons.lock_outline_rounded,
          title: 'سجّل الدخول أولًا',
          subtitle: 'تحتاج حساب بائع للوصول إلى لوحة متجرك.',
          actionLabel: 'تسجيل الدخول',
          onAction: () => context.push('/login'),
        ),
      );
    }

    return storeAsync.when(
      loading: () =>
          _scaffold(context, const Center(child: CircularProgressIndicator())),
      error: (e, _) => _scaffold(
        context,
        _centered(
          icon: Icons.error_outline_rounded,
          title: 'تعذّر تحميل المتجر',
          subtitle: '$e',
        ),
      ),
      data: (store) {
        if (store == null) {
          return _scaffold(
            context,
            _centered(
              icon: Icons.storefront_rounded,
              title: 'لا يوجد متجر بعد',
              subtitle: 'افتح متجرك في دقيقة وابدأ بإضافة منتجاتك.',
              actionLabel: 'افتح متجرك',
              onAction: () => context.push('/become-seller'),
            ),
          );
        }
        return _StoreBody(store: store);
      },
    );
  }

  Widget _scaffold(BuildContext context, Widget body) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      title: const Text('لوحة متجري'),
    ),
    body: body,
  );

  Widget _centered({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.primary),
            const SizedBox(height: Gap.lg),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Gap.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: Gap.xl),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreBody extends ConsumerStatefulWidget {
  const _StoreBody({required this.store});

  final Vendor store;

  @override
  ConsumerState<_StoreBody> createState() => _StoreBodyState();
}

class _StoreBodyState extends ConsumerState<_StoreBody> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.lg),
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  widget.store.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  ref.invalidate(myProductsProvider);
                  ref.invalidate(incomingOrdersProvider);
                },
              ),
            ],
          ),
        ),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('منتجاتي')),
            ButtonSegment(value: 1, label: Text('طلبات واردة')),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: Gap.sm),
        Expanded(
          child: _tab == 0
              ? _ProductsTab(store: widget.store)
              : _IncomingTab(store: widget.store),
        ),
      ],
    );
  }
}

// ─────────────────────────── منتجاتي ───────────────────────────
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab({required this.store});

  final Vendor store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('منتج جديد'),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منتجات بعد. اضغط "منتج جديد" لإضافة أول منتج.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Gap.lg),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
            itemBuilder: (_, i) {
              final p = products[i];
              return _ProductRow(
                product: p,
                onEdit: () => _openForm(context, ref, product: p),
                onDelete: () => _delete(context, ref, p),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${p.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(sellerRepositoryProvider).deleteProduct(p.id);
      ref.invalidate(myProductsProvider);
      ref.invalidate(catalogProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
      }
    }
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductFormDialog(store: store, product: product),
    );
    if (saved == true) {
      ref.invalidate(myProductsProvider);
      ref.invalidate(catalogProvider);
    }
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          if (product.images.isNotEmpty)
            NetImage(
              url: product.images.first,
              width: 52,
              height: 52,
              radius: 12,
            )
          else
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(0)} ج.م · المخزون ${product.stock}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  const _ProductFormDialog({required this.store, this.product});

  final Vendor store;
  final Product? product;

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _image;
  late final TextEditingController _desc;
  late final TextEditingController _stock;
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _price = TextEditingController(
      text: p == null ? '' : p.price.toStringAsFixed(0),
    );
    _oldPrice = TextEditingController(
      text: (p?.oldPrice == null) ? '' : p!.oldPrice!.toStringAsFixed(0),
    );
    _image = TextEditingController(
      text: (p?.images.isNotEmpty ?? false) ? p!.images.first : '',
    );
    _desc = TextEditingController(text: p?.description ?? '');
    _stock = TextEditingController(text: (p?.stock ?? 10).toString());
    _categoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _image.dispose();
    _desc.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final price = double.tryParse(_price.text.trim());
    if (title.isEmpty || price == null || _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل: الاسم + السعر + القسم'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(sellerRepositoryProvider);
    final ownerId = ref.read(authProvider)?.id ?? '';
    try {
      if (widget.product == null) {
        await repo.addProduct(
          storeId: widget.store.id,
          ownerId: ownerId,
          title: title,
          price: price,
          oldPrice: double.tryParse(_oldPrice.text.trim()),
          categoryId: _categoryId!,
          description: _desc.text.trim(),
          imageUrl: _image.text.trim(),
          stock: int.tryParse(_stock.text.trim()) ?? 10,
        );
      } else {
        await repo.updateProduct(
          id: widget.product!.id,
          title: title,
          price: price,
          oldPrice: double.tryParse(_oldPrice.text.trim()),
          categoryId: _categoryId!,
          description: _desc.text.trim(),
          imageUrl: _image.text.trim(),
          stock: int.tryParse(_stock.text.trim()) ?? 10,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر الحفظ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return AlertDialog(
      title: Text(widget.product == null ? 'منتج جديد' : 'تعديل المنتج'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'اسم المنتج'),
            ),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'السعر'),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: TextField(
                    controller: _oldPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر قبل الخصم',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'القسم'),
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _image,
              decoration: const InputDecoration(
                labelText: 'رابط صورة المنتج (URL)',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المخزون'),
            ),
            const SizedBox(height: Gap.md),
            TextField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}

// ─────────────────────────── الطلبات الواردة ───────────────────────────
class _IncomingTab extends ConsumerWidget {
  const _IncomingTab({required this.store});

  final Vendor store;

  static const _flow = [
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  static String _label(OrderStatus s) => switch (s) {
    OrderStatus.pending => 'بانتظار القبول',
    OrderStatus.processing => 'قيد التجهيز',
    OrderStatus.shipped => 'تم الشحن',
    OrderStatus.outForDelivery => 'خرج للتوصيل',
    OrderStatus.delivered => 'تم التسليم',
    OrderStatus.cancelled => 'ملغي',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(incomingOrdersProvider);
    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد طلبات واردة بعد.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(Gap.lg),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
          itemBuilder: (_, i) => _OrderCard(
            order: orders[i],
            store: store,
            flow: _flow,
            label: _label,
            onSet: (order, status) async {
              try {
                await ref
                    .read(sellerRepositoryProvider)
                    .setShipmentStatus(
                      orderId: order.id,
                      storeId: store.id,
                      status: status.name,
                    );
                ref.invalidate(incomingOrdersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث الحالة إلى: ${_label(status)}'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('تعذّر التحديث: $e')));
                }
              }
            },
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.store,
    required this.flow,
    required this.label,
    required this.onSet,
  });

  final Order order;
  final Vendor store;
  final List<OrderStatus> flow;
  final String Function(OrderStatus) label;
  final Future<void> Function(Order, OrderStatus) onSet;

  @override
  Widget build(BuildContext context) {
    final mine = order.shipments.where((s) => s.vendorId == store.id).toList();
    final status = mine.isEmpty ? OrderStatus.processing : mine.first.status;
    final currentIndex = flow.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label(status),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          for (final s in mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${s.itemTitles.join('، ')}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
          const SizedBox(height: Gap.sm),
          Text(
            'الإجمالي: ${order.total.toStringAsFixed(0)} ج.م · ${order.addressSummary}',
            style: const TextStyle(fontSize: 12.5),
          ),
          const SizedBox(height: Gap.md),
          if (status != OrderStatus.delivered &&
              status != OrderStatus.cancelled) ...[
            Row(
              children: [
                if (currentIndex < flow.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSet(order, flow[currentIndex + 1]),
                      child: Text('التالي: ${label(flow[currentIndex + 1])}'),
                    ),
                  ),
                const SizedBox(width: Gap.sm),
                OutlinedButton(
                  onPressed: () => onSet(order, OrderStatus.cancelled),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
