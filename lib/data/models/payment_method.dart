enum PaymentType { card, mada, applePay, wallet, cod }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String label;
  final String? last4;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.last4,
    this.isDefault = false,
  });
}
