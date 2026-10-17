enum OrderStatus {
  pending,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderShipment {
  final String vendorName;
  final String vendorAvatar;
  final OrderStatus status;
  final List<String> itemTitles;
  final List<String> productIds;
  final int itemCount;
  final double amount;
  final String trackingNo;
  final String carrier;

  const OrderShipment({
    required this.vendorName,
    required this.vendorAvatar,
    required this.status,
    required this.itemTitles,
    required this.itemCount,
    required this.amount,
    this.productIds = const [],
    this.trackingNo = '',
    this.carrier = 'XPRESS POST',
  });

  List<OrderStatus> get timeline => const [
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  OrderShipment copyWith({OrderStatus? status, String? trackingNo}) {
    return OrderShipment(
      vendorName: vendorName,
      vendorAvatar: vendorAvatar,
      status: status ?? this.status,
      itemTitles: itemTitles,
      productIds: productIds,
      itemCount: itemCount,
      amount: amount,
      trackingNo: trackingNo ?? this.trackingNo,
      carrier: carrier,
    );
  }

  Map<String, dynamic> toJson() => {
    'vendorName': vendorName,
    'vendorAvatar': vendorAvatar,
    'status': status.name,
    'itemTitles': itemTitles,
    'productIds': productIds,
    'itemCount': itemCount,
    'amount': amount,
    'trackingNo': trackingNo,
    'carrier': carrier,
  };

  factory OrderShipment.fromJson(Map<String, dynamic> json) => OrderShipment(
    vendorName: json['vendorName'] as String? ?? '',
    vendorAvatar: json['vendorAvatar'] as String? ?? '',
    status: _statusFromName(json['status'] as String?),
    itemTitles:
        (json['itemTitles'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    productIds:
        (json['productIds'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    trackingNo: json['trackingNo'] as String? ?? '',
    carrier: json['carrier'] as String? ?? 'XPRESS POST',
  );
}

OrderStatus _statusFromName(String? name) {
  for (final s in OrderStatus.values) {
    if (s.name == name) return s;
  }
  return OrderStatus.processing;
}

class Order {
  final String id;
  final DateTime date;
  final List<OrderShipment> shipments;
  final double total;
  final double subtotal;
  final double shipping;
  final double discount;
  final String addressSummary;
  final String paymentLabel;
  bool escrowHeld;
  bool reviewed;

  Order({
    required this.id,
    required this.date,
    required this.shipments,
    required this.total,
    this.subtotal = 0,
    this.shipping = 0,
    this.discount = 0,
    this.addressSummary = '',
    this.paymentLabel = '',
    this.escrowHeld = true,
    this.reviewed = false,
  });

  OrderStatus get overallStatus {
    if (shipments.every((s) => s.status == OrderStatus.delivered)) {
      return OrderStatus.delivered;
    }
    if (shipments.any((s) => s.status == OrderStatus.cancelled)) {
      return OrderStatus.cancelled;
    }
    const flow = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    var min = OrderStatus.delivered;
    for (final s in shipments) {
      if (flow.indexOf(s.status) < flow.indexOf(min)) min = s.status;
    }
    return min;
  }

  bool get allDelivered =>
      shipments.every((s) => s.status == OrderStatus.delivered);

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'shipments': shipments.map((s) => s.toJson()).toList(),
    'total': total,
    'subtotal': subtotal,
    'shipping': shipping,
    'discount': discount,
    'addressSummary': addressSummary,
    'paymentLabel': paymentLabel,
    'escrowHeld': escrowHeld,
    'reviewed': reviewed,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    shipments:
        (json['shipments'] as List?)
            ?.whereType<Map>()
            .map((e) => OrderShipment.fromJson(e.cast<String, dynamic>()))
            .toList() ??
        const [],
    total: (json['total'] as num?)?.toDouble() ?? 0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
    addressSummary: json['addressSummary'] as String? ?? '',
    paymentLabel: json['paymentLabel'] as String? ?? '',
    escrowHeld: json['escrowHeld'] as bool? ?? false,
    reviewed: json['reviewed'] as bool? ?? false,
  );
}
