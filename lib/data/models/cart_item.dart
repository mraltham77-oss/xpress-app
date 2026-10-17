import 'product.dart';
import 'vendor.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? color;
  final String? size;
  final String? variantId;
  bool selected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.color,
    this.size,
    this.variantId,
    this.selected = true,
  });

  double get unitPrice => product.price;
  double get lineTotal => unitPrice * quantity;
  Vendor get vendor => product.vendor;
}

class CartGroup {
  final Vendor vendor;
  final List<CartItem> items;

  const CartGroup({required this.vendor, required this.items});
}
