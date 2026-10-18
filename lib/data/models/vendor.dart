enum StoreStatus { pending, approved, rejected }

class Vendor {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int followers;
  final bool verified;
  final String? badge;
  final String location;
  final String ownerId;
  final String category;
  final String description;
  final String phone;
  final StoreStatus status;
  final String rejectionReason;

  const Vendor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.followers,
    this.verified = false,
    this.badge,
    this.location = 'القاهرة',
    this.ownerId = '',
    this.category = '',
    this.description = '',
    this.phone = '',
    this.status = StoreStatus.approved,
    this.rejectionReason = '',
  });

  bool get isPending => status == StoreStatus.pending;
  bool get isApproved => status == StoreStatus.approved;
  bool get isRejected => status == StoreStatus.rejected;

  Vendor copyWith({
    String? name,
    String? avatarUrl,
    String? badge,
    String? location,
    String? category,
    String? description,
    StoreStatus? status,
    bool? verified,
    String? rejectionReason,
  }) {
    return Vendor(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating,
      followers: followers,
      verified: verified ?? this.verified,
      badge: badge ?? this.badge,
      location: location ?? this.location,
      ownerId: ownerId,
      category: category ?? this.category,
      description: description ?? this.description,
      phone: phone,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
