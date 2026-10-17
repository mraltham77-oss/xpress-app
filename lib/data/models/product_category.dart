class ProductCategory {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final List<String> subcategories;
  final String imageAsset;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.subcategories = const [],
    this.imageAsset = '',
  });

  ProductCategory copyWith({
    String? name,
    String? icon,
    String? colorHex,
    List<String>? subcategories,
    String? imageAsset,
  }) {
    return ProductCategory(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      subcategories: subcategories ?? this.subcategories,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
