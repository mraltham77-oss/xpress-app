import '../models/product.dart';
import '../models/product_category.dart';
import '../models/vendor.dart';
import 'supabase_service.dart';

/// قراءة المنتجات والأقسام من سيرفر Supabase.
class CatalogRepository {
  const CatalogRepository();

  Future<List<ProductCategory>> fetchCategories() async {
    final rows = await SupabaseService.client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);
    return rows
        .map<ProductCategory>(
          (r) => _category((r as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<List<Product>> fetchProducts() async {
    final rows = await SupabaseService.client
        .from('products')
        .select('*, vendors(*)')
        .order('created_at', ascending: false);
    return rows.map<Product>((r) {
      final map = (r as Map).cast<String, dynamic>();
      final vendorRow = (map['vendors'] as Map?)?.cast<String, dynamic>();
      return _product(map, vendorRow == null ? null : _vendor(vendorRow));
    }).toList();
  }

  Future<List<Vendor>> fetchStores() async {
    final rows = await SupabaseService.client
        .from('vendors')
        .select()
        .order('created_at', ascending: false);
    return rows.map<Vendor>((r) => _vendor((r as Map).cast())).toList();
  }

  ProductCategory _category(Map<String, dynamic> r) => ProductCategory(
    id: r['id'] as String,
    name: r['name'] as String? ?? '',
    icon: r['icon'] as String? ?? '',
    colorHex: r['color_hex'] as String? ?? 'FFFFFF',
    subcategories:
        (r['subcategories'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    imageAsset: r['image_asset'] as String? ?? '',
  );

  Product _product(Map<String, dynamic> r, Vendor? vendor) => Product(
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
    vendor:
        vendor ??
        const Vendor(
          id: '',
          name: 'XPRESS',
          avatarUrl: '',
          rating: 0,
          followers: 0,
        ),
    categoryId: r['category_id'] as String? ?? '',
    description: r['description'] as String? ?? '',
    colors:
        (r['colors'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    specifications:
        (r['specifications'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
  );

  Vendor _vendor(Map<String, dynamic> r) => Vendor(
    id: r['id'] as String? ?? '',
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
    status: switch (r['status'] as String?) {
      'pending' => StoreStatus.pending,
      'rejected' => StoreStatus.rejected,
      _ => StoreStatus.approved,
    },
    rejectionReason: r['rejection_reason'] as String? ?? '',
  );
}
