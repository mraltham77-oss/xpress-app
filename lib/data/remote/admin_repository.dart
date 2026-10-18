import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import 'supabase_service.dart';

/// خصائص لوحة الأدمن الحقيقية: الموافقة على المتاجر، إدارة المنتجات
/// والأقسام والمستخدمين، وتفعيل دور الأدمن بالكود السري.
class AdminRepository {
  const AdminRepository();

  SupabaseClient get _db => SupabaseService.client;

  // ─────────────────────────── تفعيل الأدمن ───────────────────────────
  /// يتحوّل الحساب الحالي إلى أدمن بكود سري (مرة واحدة: أول أدمن فقط).
  Future<bool> claimAdmin(String code) async {
    final res = await _db.rpc('claim_admin', params: {'p_code': code});
    return res == true;
  }

  // ─────────────────────────── المتاجر ───────────────────────────
  Future<List<Vendor>> allStores() async {
    final rows = await _db
        .from('vendors')
        .select()
        .order('created_at', ascending: false);
    return rows.map<Vendor>((r) => _store((r as Map).cast())).toList();
  }

  Future<List<Vendor>> pendingStores() async {
    final rows = await _db
        .from('vendors')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return rows.map<Vendor>((r) => _store((r as Map).cast())).toList();
  }

  Future<void> reviewStore({
    required String storeId,
    required bool approve,
    String reason = '',
  }) async {
    await _db.rpc(
      'review_store',
      params: {'p_store_id': storeId, 'p_approve': approve, 'p_reason': reason},
    );
  }

  Future<void> deleteStore(String storeId) async {
    await _db.from('products').delete().eq('vendor_id', storeId);
    await _db.from('vendors').delete().eq('id', storeId);
  }

  Future<void> setStoreVerified(String storeId, bool verified) async {
    await _db.from('vendors').update({'verified': verified}).eq('id', storeId);
  }

  // ─────────────────────────── المنتجات ───────────────────────────
  Future<List<Product>> allProducts() async {
    final rows = await _db
        .from('products')
        .select('*, vendors(*)')
        .order('created_at', ascending: false);
    return rows.map<Product>((r) => _product((r as Map).cast())).toList();
  }

  Future<void> deleteProduct(String id) async {
    await _db.from('products').delete().eq('id', id);
  }

  Future<void> setProductStock(String id, int stock) async {
    await _db.from('products').update({'stock': stock}).eq('id', id);
  }

  // ─────────────────────────── الأقسام ───────────────────────────
  Future<void> addCategory({
    required String name,
    String icon = '🛍️',
    String colorHex = 'FFFFFF',
  }) async {
    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
    await _db.from('categories').insert({
      'id': id,
      'name': name,
      'icon': icon,
      'color_hex': colorHex,
      'sort_order': 99,
    });
  }

  Future<void> updateCategory(String id, {String? name, String? icon}) async {
    await _db
        .from('categories')
        .update({'name': ?name, 'icon': ?icon})
        .eq('id', id);
  }

  Future<void> deleteCategory(String id) async {
    await _db.from('categories').delete().eq('id', id);
  }

  // ─────────────────────────── المستخدمون ───────────────────────────
  Future<List<AppUser>> allUsers() async {
    final rows = await _db
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return rows.map<AppUser>((r) {
      final m = (r as Map).cast<String, dynamic>();
      return AppUser(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        city: m['city'] as String? ?? 'القاهرة',
        role: UserRole.values.firstWhere(
          (x) => x.name == (m['role'] ?? 'customer'),
          orElse: () => UserRole.customer,
        ),
      );
    }).toList();
  }

  Future<void> setUserRole(String userId, UserRole role) async {
    await _db.from('profiles').update({'role': role.name}).eq('id', userId);
  }

  // ─────────────────────────── الإشعارات (إرسال عام) ────────────────
  Future<void> broadcastNotification({
    required String title,
    required String body,
  }) async {
    // تُخزَّن في جدول notifications إن وُجد؛ وإلا نتجاهل بهدوء.
    try {
      await _db.from('notifications').insert({
        'id': 'n${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'body': body,
        'read': false,
      });
    } catch (_) {
      // الجدول غير موجود بعد — غير حرج.
    }
  }

  // ─────────────────────────── إحصاءات ───────────────────────────
  Future<Map<String, int>> stats() async {
    Future<int> count(String table, {Map<String, dynamic>? eq}) async {
      try {
        final query = _db.from(table).select('id');
        final rows = eq == null
            ? await query
            : await query.eq(eq.keys.first, eq.values.first);
        return (rows as List).length;
      } catch (_) {
        return 0;
      }
    }

    return {
      'users': await count('profiles'),
      'stores': await count('vendors'),
      'pending': await count('vendors', eq: {'status': 'pending'}),
      'products': await count('products'),
      'orders': await count('orders'),
    };
  }

  // ─────────────────────────── mappers ───────────────────────────
  Vendor _store(Map<String, dynamic> r) => Vendor(
    id: r['id'] as String,
    name: r['name'] as String? ?? '',
    avatarUrl: r['avatar_url'] as String? ?? '',
    rating: (r['rating'] as num?)?.toDouble() ?? 0,
    followers: (r['followers'] as num?)?.toInt() ?? 0,
    verified: r['verified'] as bool? ?? false,
    badge: r['badge'] as String?,
    location: r['location'] as String? ?? 'القاهرة',
    ownerId: r['owner_id'] as String? ?? '',
    category: r['category'] as String? ?? '',
    description: r['description'] as String? ?? '',
    phone: r['phone'] as String? ?? '',
    status: _status(r['status'] as String?),
    rejectionReason: r['rejection_reason'] as String? ?? '',
  );

  StoreStatus _status(String? raw) => switch (raw) {
    'pending' => StoreStatus.pending,
    'rejected' => StoreStatus.rejected,
    _ => StoreStatus.approved,
  };

  Product _product(Map<String, dynamic> r) {
    final vendorRow = (r['vendors'] as Map?)?.cast<String, dynamic>();
    return Product(
      id: r['id'] as String,
      title: r['title'] as String? ?? '',
      images:
          (r['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      price: (r['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (r['old_price'] as num?)?.toDouble(),
      rating: (r['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (r['reviews_count'] as num?)?.toInt() ?? 0,
      soldCount: (r['sold_count'] as num?)?.toInt() ?? 0,
      stock: (r['stock'] as num?)?.toInt() ?? 0,
      freeShipping: r['free_shipping'] as bool? ?? false,
      vendor: vendorRow == null
          ? const Vendor(
              id: '',
              name: 'XPRESS',
              avatarUrl: '',
              rating: 0,
              followers: 0,
            )
          : _store(vendorRow),
      categoryId: r['category_id'] as String? ?? '',
      description: r['description'] as String? ?? '',
      colors:
          (r['colors'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      specifications:
          (r['specifications'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}

// يُستخدم لتنبيه الشاشات عند وجود إشعارات (توافق مع نموذج الإشعارات).
List<AppNotification> emptyNotifications() => const [];
