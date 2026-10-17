class Vendor {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int followers;
  final bool verified;
  final String? badge;
  final String location;

  const Vendor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.followers,
    this.verified = false,
    this.badge,
    this.location = 'القاهرة',
  });
}
