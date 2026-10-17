class Address {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String city;
  final String district;
  final String street;
  final String details;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    this.details = '',
    this.isDefault = false,
  });

  String get summary => '$city، $district، $street';

  Address copyWith({bool? isDefault}) => Address(
    id: id,
    label: label,
    fullName: fullName,
    phone: phone,
    city: city,
    district: district,
    street: street,
    details: details,
    isDefault: isDefault ?? this.isDefault,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'city': city,
    'district': district,
    'street': street,
    'details': details,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    label: json['label'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    city: json['city'] as String? ?? '',
    district: json['district'] as String? ?? '',
    street: json['street'] as String? ?? '',
    details: json['details'] as String? ?? '',
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
