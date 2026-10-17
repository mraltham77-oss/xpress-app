class Coupon {
  final String code;
  final String description;
  final double value; // نسبة مئوية أو مبلغ
  final bool isPercent;
  final double minOrder;
  final DateTime expiry;

  const Coupon({
    required this.code,
    required this.description,
    required this.value,
    required this.minOrder,
    required this.expiry,
    this.isPercent = true,
  });

  double discountFor(double subtotal) {
    if (subtotal < minOrder) return 0;
    return isPercent ? subtotal * value / 100 : value;
  }
}
