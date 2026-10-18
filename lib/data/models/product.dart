import 'vendor.dart';

class ProductVariant {
  final String id;
  final String label;
  final double price;
  final int stock;

  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
    required this.stock,
  });
}

class Product {
  final String id;
  final String title;
  final List<String> images;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewsCount;
  final int soldCount;
  final int stock;
  final bool freeShipping;
  final Vendor vendor;
  final String categoryId;
  final String description;
  final List<String> colors;
  final List<ProductVariant> sizes;
  final List<String> specifications;

  const Product({
    required this.id,
    required this.title,
    required this.images,
    required this.price,
    required this.rating,
    required this.vendor,
    this.oldPrice,
    this.reviewsCount = 0,
    this.soldCount = 0,
    this.stock = 100,
    this.freeShipping = false,
    this.categoryId = '',
    this.description = '',
    this.colors = const [],
    this.sizes = const [],
    this.specifications = const [],
  });

  /// أول صورة بأمان (لا يسبّب انهيارًا عند غياب الصور).
  String get imageUrl => images.isNotEmpty ? images.first : '';

  /// لقطة كاملة تُخزَّن مع السلة حتى تُستعاد دون الحاجة لتحميل الكتالوج.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'images': images,
    'price': price,
    'old_price': oldPrice,
    'rating': rating,
    'reviews_count': reviewsCount,
    'sold_count': soldCount,
    'stock': stock,
    'free_shipping': freeShipping,
    'category_id': categoryId,
    'description': description,
    'colors': colors,
    'specifications': specifications,
    'vendor': {
      'id': vendor.id,
      'name': vendor.name,
      'avatar_url': vendor.avatarUrl,
      'rating': vendor.rating,
      'followers': vendor.followers,
    },
  };

  factory Product.fromJson(Map<String, dynamic> r) {
    final v = (r['vendor'] as Map?)?.cast<String, dynamic>();
    return Product(
      id: r['id'] as String? ?? '',
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
      vendor: v == null
          ? const Vendor(
              id: '',
              name: 'XPRESS',
              avatarUrl: '',
              rating: 0,
              followers: 0,
            )
          : Vendor(
              id: v['id'] as String? ?? '',
              name: v['name'] as String? ?? '',
              avatarUrl: v['avatar_url'] as String? ?? '',
              rating: (v['rating'] as num?)?.toDouble() ?? 0,
              followers: (v['followers'] as num?)?.toInt() ?? 0,
            ),
      categoryId: r['category_id'] as String? ?? '',
      description: r['description'] as String? ?? '',
      colors:
          (r['colors'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      specifications:
          (r['specifications'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  int get discountPercent {
    if (oldPrice == null || oldPrice == 0) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  Product copyWith({
    String? title,
    List<String>? images,
    double? price,
    double? oldPrice,
    double? rating,
    int? reviewsCount,
    int? soldCount,
    int? stock,
    bool? freeShipping,
    String? categoryId,
    String? description,
    List<String>? specifications,
  }) {
    return Product(
      id: id,
      title: title ?? this.title,
      images: images ?? this.images,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      soldCount: soldCount ?? this.soldCount,
      stock: stock ?? this.stock,
      freeShipping: freeShipping ?? this.freeShipping,
      vendor: vendor,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      colors: colors,
      sizes: sizes,
      specifications: specifications ?? this.specifications,
    );
  }
}
