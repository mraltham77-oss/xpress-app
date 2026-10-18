import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings_ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/app_user.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/models/vendor.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/premium.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null || !user.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Gap.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlowIconBadge(
                  icon: Icons.gpp_bad_rounded,
                  size: 72,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  ),
                ),
                const SizedBox(height: Gap.lg),
                const Text(
                  AppStrings.adminAccessDenied,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Gap.sm),
                const Text(
                  'سجّل الدخول بحساب مشرف للوصول إلى لوحة التحكم.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Gap.xl),
                NeonButton(
                  label: AppStrings.login,
                  icon: Icons.login_rounded,
                  expanded: false,
                  onPressed: () => context.push('/login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: const Text(AppStrings.adminDashboard),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: AppStrings.adminOverview),
              Tab(text: 'المتاجر'),
              Tab(text: AppStrings.adminProducts),
              Tab(text: 'الأقسام'),
              Tab(text: 'المستخدمون'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _StoresTab(),
            _ProductsTab(),
            _CategoriesTab(),
            _UsersTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Overview ───────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(adminStatsProvider);
        ref.invalidate(pendingStoresProvider);
        await ref.read(adminStatsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(Gap.lg),
        children: [
          stats.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _errorBox('تعذّر تحميل الإحصاءات', e),
            data: (m) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'المستخدمون',
                        value: '${m['users'] ?? 0}',
                        icon: Icons.people_alt_rounded,
                        gradient: AppColors.brandGradient,
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: _StatCard(
                        label: 'المتاجر',
                        value: '${m['stores'] ?? 0}',
                        icon: Icons.storefront_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'المنتجات',
                        value: '${m['products'] ?? 0}',
                        icon: Icons.inventory_2_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF0E9488)],
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: _StatCard(
                        label: 'طلبات متاجر معلّقة',
                        value: '${m['pending'] ?? 0}',
                        icon: Icons.hourglass_top_rounded,
                        gradient: AppColors.flashGradient,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xl),
          const _PendingStoresPreview(),
        ],
      ),
    );
  }
}

class _PendingStoresPreview extends ConsumerWidget {
  const _PendingStoresPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingStoresProvider);
    return pending.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => _errorBox('تعذّر تحميل طلبات المتاجر', e),
      data: (stores) {
        if (stores.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'طلبات فتح متجر (${stores.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.md),
            ...stores.take(5).map((s) => _StoreApprovalCard(store: s)),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder, width: 0.8),
        boxShadow: Shadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: Gap.md),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
    );
  }
}

// ─────────────────────────── Stores ───────────────────────────
class _StoresTab extends ConsumerWidget {
  const _StoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(allStoresProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(allStoresProvider);
        ref.invalidate(pendingStoresProvider);
        await ref.read(allStoresProvider.future);
      },
      child: stores.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [_errorBox('تعذّر تحميل المتاجر', e)],
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'لا توجد متاجر',
              subtitle: 'ستظهر طلبات التجار هنا للموافقة عليها',
            );
          }
          final pending = list.where((s) => s.isPending).toList();
          final others = list.where((s) => !s.isPending).toList();
          return ListView(
            padding: const EdgeInsets.all(Gap.lg),
            children: [
              if (pending.isNotEmpty) ...[
                const Text(
                  'بانتظار الموافقة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Gap.md),
                ...pending.map((s) => _StoreApprovalCard(store: s)),
                const SizedBox(height: Gap.xl),
              ],
              if (others.isNotEmpty) ...[
                const Text(
                  'كل المتاجر',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Gap.md),
                ...others.map((s) => _StoreTile(store: s)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StoreApprovalCard extends ConsumerStatefulWidget {
  final Vendor store;
  const _StoreApprovalCard({required this.store});

  @override
  ConsumerState<_StoreApprovalCard> createState() => _StoreApprovalCardState();
}

class _StoreApprovalCardState extends ConsumerState<_StoreApprovalCard> {
  bool _busy = false;

  Future<void> _review(bool approve) async {
    String reason = '';
    if (!approve) {
      final controller = TextEditingController();
      reason =
          await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('سبب الرفض'),
              content: TextField(
                controller: controller,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'اكتب سببًا واضحًا للتاجر',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('رفض'),
                ),
              ],
            ),
          ) ??
          '';
      if (reason.isEmpty) return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .reviewStore(
            storeId: widget.store.id,
            approve: approve,
            reason: reason,
          );
      ref.invalidate(pendingStoresProvider);
      ref.invalidate(allStoresProvider);
      ref.invalidate(adminStatsProvider);
      ref.invalidate(storesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'تمت الموافقة على المتجر' : 'تم رفض المتجر',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      _snack(e);
    }
  }

  void _snack(Object e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تعذّر التنفيذ: $e')));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return GlassCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlowIconBadge(
                icon: Icons.storefront_rounded,
                size: 42,
                gradient: AppColors.brandGradient,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (s.category.isNotEmpty) s.category,
                        s.location,
                        if (s.phone.isNotEmpty) s.phone,
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusPill(),
            ],
          ),
          if (s.description.isNotEmpty) ...[
            const SizedBox(height: Gap.sm),
            Text(
              s.description,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'موافقة',
                  icon: Icons.check_rounded,
                  onPressed: _busy ? null : () => _review(true),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _review(false),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'معلّق',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.warning,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StoreTile extends ConsumerWidget {
  final Vendor store;
  const _StoreTile({required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = store;
    final (color, label) = switch (s.status) {
      StoreStatus.approved => (AppColors.success, 'معتمد'),
      StoreStatus.rejected => (AppColors.danger, 'مرفوض'),
      StoreStatus.pending => (AppColors.warning, 'معلّق'),
    };
    return GlassCard(
      radius: 14,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          NetImage(url: s.avatarUrl, width: 48, height: 48, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (s.category.isNotEmpty) s.category,
                    s.location,
                    if (s.phone.isNotEmpty) s.phone,
                  ].join(' • '),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            onPressed: () => _confirmDelete(context, ref, s),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Vendor s) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المتجر'),
        content: Text('حذف "${s.name}" وكل منتجاته؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminRepositoryProvider).deleteStore(s.id);
                ref.invalidate(allStoresProvider);
                ref.invalidate(pendingStoresProvider);
                ref.invalidate(adminStatsProvider);
                ref.invalidate(storesProvider);
                ref.invalidate(catalogProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
                }
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Products ───────────────────────────
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(allProductsProvider);
    final categories = ref.watch(categoriesProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(allProductsProvider);
        ref.invalidate(adminStatsProvider);
        await ref.read(allProductsProvider.future);
      },
      child: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [_errorBox('تعذّر تحميل المنتجات', e)],
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات',
              subtitle: 'تظهر منتجات المتاجر المعتمدة هنا',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Gap.lg),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              final cat = _categoryName(categories, p.categoryId);
              return GlassCard(
                radius: 14,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    NetImage(
                      url: p.imageUrl,
                      width: 56,
                      height: 56,
                      radius: 12,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$cat • ${p.vendor.name} • المخزون: ${p.stock}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          PriceTag(
                            price: p.price,
                            oldPrice: p.oldPrice,
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      onPressed: () => _confirmDelete(context, ref, p),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Product p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.adminDeleteProduct),
        content: Text('هل تريد حذف "${p.title}"؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminRepositoryProvider).deleteProduct(p.id);
                ref.invalidate(allProductsProvider);
                ref.invalidate(adminStatsProvider);
                ref.invalidate(catalogProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
                }
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Categories ───────────────────────────
class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('قسم جديد'),
      ),
      body: categories.isEmpty
          ? const EmptyState(
              icon: Icons.category_outlined,
              title: 'لا توجد أقسام',
              subtitle: 'أضف أول قسم ليظهر في المتجر',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 90),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];
                return GlassCard(
                  radius: 14,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(c.icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        onPressed: () async {
                          try {
                            await ref
                                .read(adminRepositoryProvider)
                                .deleteCategory(c.id);
                            ref.invalidate(categoriesProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تعذّر الحذف: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref) {
    final form = GlobalKey<FormState>();
    final name = TextEditingController();
    final icon = TextEditingController(text: '🛍️');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قسم جديد',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: Gap.lg),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'اسم القسم'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: Gap.md),
                TextFormField(
                  controller: icon,
                  decoration: const InputDecoration(
                    labelText: 'الأيقونة (رمز)',
                  ),
                ),
                const SizedBox(height: Gap.xl),
                NeonButton(
                  label: AppStrings.save,
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(adminRepositoryProvider)
                          .addCategory(
                            name: name.text.trim(),
                            icon: icon.text.trim().isEmpty
                                ? '🛍️'
                                : icon.text.trim(),
                          );
                      ref.invalidate(categoriesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إضافة القسم')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تعذّر الحفظ: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Users ───────────────────────────
class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(allUsersProvider);
        await ref.read(allUsersProvider.future);
      },
      child: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [_errorBox('تعذّر تحميل المستخدمين', e)],
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'لا يوجد مستخدمون',
              subtitle: 'سيظهر المستخدمون المسجّلون هنا',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Gap.lg),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final u = list[i];
              return GlassCard(
                radius: 14,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name.isEmpty ? 'مستخدم' : u.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            u.phone.isNotEmpty ? u.phone : u.city,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<UserRole>(
                      value: u.role,
                      dropdownColor: AppColors.surfaceVariant,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: UserRole.customer,
                          child: Text('عميل'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.seller,
                          child: Text('تاجر'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.admin,
                          child: Text('مشرف'),
                        ),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        try {
                          await ref
                              .read(adminRepositoryProvider)
                              .setUserRole(u.id, v);
                          ref.invalidate(allUsersProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تعذّر التعديل: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────── helpers ───────────────────────────
String _categoryName(List<ProductCategory> categories, String id) {
  for (final c in categories) {
    if (c.id == id) return c.name;
  }
  return 'بدون قسم';
}

Widget _errorBox(String title, Object e) {
  return GlassCard(
    radius: 14,
    padding: const EdgeInsets.all(Gap.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        Text(
          '$e',
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
