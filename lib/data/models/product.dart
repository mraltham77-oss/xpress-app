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
