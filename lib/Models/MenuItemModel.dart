class MenuItemModel {
  final int id;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final int storeId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Store information (from relation)
  final StoreInfo? store;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      storeId: json['storeId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'store': store?.toJson(),
    };
  }

  MenuItemModel copyWith({
    int? id,
    String? name,
    int? price,
    String? description,
    String? imageUrl,
    int? storeId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    StoreInfo? store,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      store: store ?? this.store,
    );
  }

  @override
  String toString() {
    return 'MenuItemModel(id: $id, name: $name, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Utility getters
  String get displayName => name;
  String get storeName => store?.name ?? 'Unknown Store';

  String get priceDisplay => 'Rp ${price.toStringAsFixed(0)}';
  String get quantityDisplay => '$quantity items';

  bool get isAvailable => quantity > 0;
  bool get isOutOfStock => quantity == 0;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;

  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= 10) return 'Low Stock';
    return 'In Stock';
  }

  String get availabilityText => isAvailable ? 'Available' : 'Out of Stock';

  // Format for display in admin panel
  Map<String, String> get displayData => {
        'ID': id.toString(),
        'Name': name,
        'Price': priceDisplay,
        'Quantity': quantityDisplay,
        'Store': storeName,
        'Status': stockStatus,
        'Created': createdAt.toString().split(' ')[0],
      };
}

// Supporting class for store relation
class StoreInfo {
  final int id;
  final String name;
  final String? address;
  final String? imageUrl;
  final String? phone;

  StoreInfo({
    required this.id,
    required this.name,
    this.address,
    this.imageUrl,
    this.phone,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      imageUrl: json['imageUrl'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'phone': phone,
    };
  }
}
