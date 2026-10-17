class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String city;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.city = 'القاهرة',
    this.role = UserRole.customer,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isSeller => role == UserRole.seller || role == UserRole.admin;

  AppUser copyWith({
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? city,
    UserRole? role,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      role: role ?? this.role,
    );
  }
}

enum UserRole { customer, seller, admin }
