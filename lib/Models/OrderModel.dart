class OrderModel {
  final int id;
  final int customerId;
  final int storeId;
  final int? driverId;
  final String orderStatus;
  final String deliveryStatus;
  final double totalAmount;
  final double deliveryFee;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime? estimatedPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final List<dynamic>? trackingUpdates;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<OrderItemInfo>? items;
  final StoreInfo? store;
  final CustomerInfo? customer;
  final DriverInfo? driver;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.driverId,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.deliveryFee,
    this.destinationLatitude,
    this.destinationLongitude,
    this.estimatedPickupTime,
    this.actualPickupTime,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.trackingUpdates,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.store,
    this.customer,
    this.driver,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      driverId: json['driver_id'],
      orderStatus: json['order_status'] ?? 'pending',
      deliveryStatus: json['delivery_status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      destinationLatitude: json['destination_latitude']?.toDouble(),
      destinationLongitude: json['destination_longitude']?.toDouble(),
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.parse(json['estimated_pickup_time'])
          : null,
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.parse(json['actual_pickup_time'])
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'])
          : null,
      trackingUpdates: json['tracking_updates'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItemInfo.fromJson(item))
              .toList()
          : null,
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'])
          : null,
      driver:
          json['driver'] != null ? DriverInfo.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'store_id': storeId,
      'driver_id': driverId,
      'order_status': orderStatus,
      'delivery_status': deliveryStatus,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'estimated_pickup_time': estimatedPickupTime?.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'tracking_updates': trackingUpdates,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get totalDisplay => 'Rp ${totalAmount.toStringAsFixed(0)}';
  String get deliveryFeeDisplay => 'Rp ${deliveryFee.toStringAsFixed(0)}';
  String get grandTotalDisplay =>
      'Rp ${(totalAmount + deliveryFee).toStringAsFixed(0)}';
  String get customerName => customer?.name ?? 'Unknown Customer';
  String get storeName => store?.name ?? 'Unknown Store';
  String get driverName => driver?.name ?? 'No Driver Assigned';
  bool get hasDriver => driverId != null;
  String get orderDateDisplay => createdAt.toString().split(' ')[0];
  bool get hasDestination =>
      destinationLatitude != null && destinationLongitude != null;

  String get orderStatusDisplay {
    switch (orderStatus) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'on_delivery':
        return 'On Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get deliveryStatusDisplay {
    switch (deliveryStatus) {
      case 'pending':
        return 'Pending';
      case 'picked_up':
        return 'Picked Up';
      case 'on_way':
        return 'On Way';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  bool get isCompleted => orderStatus == 'delivered';
  bool get isCancelled => orderStatus == 'cancelled';
  bool get isPending => orderStatus == 'pending';
  bool get isInProgress => [
        'confirmed',
        'preparing',
        'ready_for_pickup',
        'on_delivery'
      ].contains(orderStatus);
}

// Supporting classes
class OrderItemInfo {
  final int id;
  final int orderId;
  final int? menuItemId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final int quantity;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItemInfo({
    required this.id,
    required this.orderId,
    this.menuItemId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.quantity,
    required this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItemInfo.fromJson(Map<String, dynamic> json) {
    return OrderItemInfo(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      menuItemId: json['menu_item_id'],
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'quantity': quantity,
      'price': price,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get totalPrice => 'Rp ${(price * quantity).toStringAsFixed(0)}';
  double get totalAmount => price * quantity;
}

class StoreInfo {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  StoreInfo({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.imageUrl,
    this.latitude,
    this.longitude,
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
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
}

class CustomerInfo {
  final int id;
  final String name;
  final String email;
  final String? phone;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

class DriverInfo {
  final int id;
  final String name;
  final String? phone;
  final String? vehicleNumber;
  final double? latitude;
  final double? longitude;

  DriverInfo({
    required this.id,
    required this.name,
    this.phone,
    this.vehicleNumber,
    this.latitude,
    this.longitude,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    // Handle nested user data if driver info comes with user relation
    final userData = json['user'];
    return DriverInfo(
      id: json['id'] ?? 0,
      name: userData?['name'] ?? json['name'] ?? '',
      phone: userData?['phone'] ?? json['phone'],
      vehicleNumber: json['vehicle_plate'] ?? json['vehicle_number'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_number': vehicleNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
}
