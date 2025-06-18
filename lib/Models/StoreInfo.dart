class StoreInfo {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final String? status;

  StoreInfo({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.rating,
    this.status,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      imageUrl: json['image_url'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      rating: json['rating']?.toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'status': status,
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasRating => rating != null && rating! > 0;
  String get ratingDisplay => rating?.toStringAsFixed(1) ?? '0.0';
  bool get isActive => status == 'active';
}
