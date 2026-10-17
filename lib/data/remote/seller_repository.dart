import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';
import '../models/product.dart';
import '../models/vendor.dart';
import 'supabase_service.dart';

/// عمليات البائع الحقيقية على Supabase: المتجر، المنتجات، الطلبات الواردة.
class SellerRepository {
  const SellerRepository();

  SupabaseClient get _db => SupabaseService.client;

  // ─────────────────────────── المتجر ───────────────────────────
  Future<Vendor?> myStore(String userId) async {
    final row = await _db
        .from('vendors')
        .select()
        .eq('owner_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return _store(row);
  }

  Future<Vendor> createStore({
    required String userId,
    required String name,
    String category = '',
  }) async {
    final id = 's${DateTime.now().millisecondsSinceEpoch}';
    await _db.from('vendors').insert({
      'id': id,
      'name': name,
      'owner_id': userId,
      'category': category,
      'location': 'القاهرة',
      'verified': false,
    });
    try {
      await _db.rpc('set_my_role_seller');
    } catch (_) {
      // الدور يُحدّث أيضًا من التطبيق — الفشل غير حرج.
    }
    final row = await _db.from('vendors').select().eq('id', id).single();
    return _store(row);
  }

  // ─────────────────────────── المنتجات ───────────────────────────
  Future<List<Product>> myProducts(String storeId) async {
    final rows = await _db
        .from('products')
        .select('*, vendors(*)')
        .eq('vendor_id', storeId)
        .order('created_at', ascending: false);
    return rows.map<Product>((r) => _product((r as Map).cast())).toList();
  }

  Future<String> addProduct({
    required String storeId,
    required String ownerId,
    required String title,
    required double price,
    double? oldPrice,
    required String categoryId,
    String description = '',
    String imageUrl = '',
    int stock = 100,
    bool freeShipping = false,
  }) async {
    final id = 'p${DateTime.now().millisecondsSinceEpoch}';
    await _db.from('products').insert({
      'id': id,
      'title': title,
      'price': price,
      'old_price': oldPrice,
      'images': imageUrl.trim().isEmpty ? <String>[] : [imageUrl.trim()],
      'category_id': categoryId,
      'description': description,
      'stock': stock,
      'free_shipping': freeShipping,
      'vendor_id': storeId,
      'owner_id': ownerId,
    });
    return id;
  }

  Future<void> updateProduct({
    required String id,
    required String title,
    required double price,
    double? oldPrice,
    required String categoryId,
    String description = '',
    String imageUrl = '',
    int stock = 100,
  }) async {
    await _db
        .from('products')
        .update({
          'title': title,
          'price': price,
          'old_price': oldPrice,
          'images': imageUrl.trim().isEmpty ? <String>[] : [imageUrl.trim()],
          'category_id': categoryId,
          'description': description,
          'stock': stock,
        })
        .eq('id', id);
  }

  Future<void> deleteProduct(String id) =>
      _db.from('products').delete().eq('id', id);

  // ─────────────────────────── الطلبات الواردة ───────────────────────────
  Future<List<Order>> incomingOrders(String storeId) async {
    final rows = await _db
        .from('orders')
        .select()
        .contains('store_ids', [storeId])
        .order('date', ascending: false);
    return rows
        .map<Order>(
          (r) => orderFromRemoteRow((r as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<void> setShipmentStatus({
    required String orderId,
    required String storeId,
    required String status,
  }) async {
    await _db.rpc(
      'set_shipment_status',
      params: {
        'p_order_id': orderId,
        'p_store_id': storeId,
        'p_status': status,
      },
    );
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
  );

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
