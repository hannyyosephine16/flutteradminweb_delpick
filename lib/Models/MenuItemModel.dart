class MenuItemModel {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final int storeId;
  final String category;
  final bool isAvailable;
  final int? quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Store relation
  final StoreInfo? store;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.category,
    required this.isAvailable,
    this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      storeId: json['store_id'] ?? 0,
      category: json['category'] ?? '',
      isAvailable: json['is_available'] ?? true,
      quantity: json['quantity'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'store_id': storeId,
      'category': category,
      'is_available': isAvailable,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get priceDisplay => 'Rp ${price.toStringAsFixed(0)}';
  String get availabilityText => isAvailable ? 'Available' : 'Unavailable';
  String get stockStatus {
    if (!isAvailable) return 'Unavailable';
    if (quantity == null) return 'Available';
    if (quantity! == 0) return 'Out of Stock';
    if (quantity! <= 10) return 'Low Stock';
    return 'In Stock';
  }
}

class StoreInfo {
  final int id;
  final String name;
  final String? imageUrl;

  StoreInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }
}
