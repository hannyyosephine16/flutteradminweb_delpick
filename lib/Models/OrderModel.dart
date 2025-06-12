class OrderModel {
  final int id;
  final String code;
  final String deliveryAddress;
  final double subtotal;
  final double serviceCharge;
  final double total;
  final String
      orderStatus; // 'pending', 'approved', 'preparing', 'on_delivery', 'delivered', 'cancelled'
  final String
      deliveryStatus; // 'waiting', 'picking_up', 'on_delivery', 'delivered'
  final DateTime orderDate;
  final String? notes;
  final int customerId;
  final int? driverId;
  final int storeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data
  final List<OrderItemInfo>? items;
  final StoreInfo? store;
  final CustomerInfo? customer;
  final DriverInfo? driver;
  final List<OrderReviewInfo>? orderReviews;
  final List<DriverReviewInfo>? driverReviews;

  OrderModel({
    required this.id,
    required this.code,
    required this.deliveryAddress,
    required this.subtotal,
    required this.serviceCharge,
    required this.total,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.orderDate,
    this.notes,
    required this.customerId,
    this.driverId,
    required this.storeId,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.store,
    this.customer,
    this.driver,
    this.orderReviews,
    this.driverReviews,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      serviceCharge: (json['serviceCharge'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      orderStatus: json['order_status'] ?? json['orderStatus'] ?? 'pending',
      deliveryStatus:
          json['delivery_status'] ?? json['deliveryStatus'] ?? 'waiting',
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      customerId: json['customerId'] ?? 0,
      driverId: json['driverId'],
      storeId: json['storeId'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      orderReviews: json['orderReviews'] != null
          ? (json['orderReviews'] as List)
              .map((review) => OrderReviewInfo.fromJson(review))
              .toList()
          : null,
      driverReviews: json['driverReviews'] != null
          ? (json['driverReviews'] as List)
              .map((review) => DriverReviewInfo.fromJson(review))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'deliveryAddress': deliveryAddress,
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'total': total,
      'order_status': orderStatus,
      'delivery_status': deliveryStatus,
      'orderDate': orderDate.toIso8601String(),
      'notes': notes,
      'customerId': customerId,
      'driverId': driverId,
      'storeId': storeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
      'store': store?.toJson(),
      'customer': customer?.toJson(),
      'driver': driver?.toJson(),
      'orderReviews': orderReviews?.map((review) => review.toJson()).toList(),
      'driverReviews': driverReviews?.map((review) => review.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    int? id,
    String? code,
    String? deliveryAddress,
    double? subtotal,
    double? serviceCharge,
    double? total,
    String? orderStatus,
    String? deliveryStatus,
    DateTime? orderDate,
    String? notes,
    int? customerId,
    int? driverId,
    int? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemInfo>? items,
    StoreInfo? store,
    CustomerInfo? customer,
    DriverInfo? driver,
    List<OrderReviewInfo>? orderReviews,
    List<DriverReviewInfo>? driverReviews,
  }) {
    return OrderModel(
      id: id ?? this.id,
      code: code ?? this.code,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      total: total ?? this.total,
      orderStatus: orderStatus ?? this.orderStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      orderDate: orderDate ?? this.orderDate,
      notes: notes ?? this.notes,
      customerId: customerId ?? this.customerId,
      driverId: driverId ?? this.driverId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      store: store ?? this.store,
      customer: customer ?? this.customer,
      driver: driver ?? this.driver,
      orderReviews: orderReviews ?? this.orderReviews,
      driverReviews: driverReviews ?? this.driverReviews,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, code: $code, orderStatus: $orderStatus, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Utility getters
  String get displayCode => code;
  String get customerName => customer?.name ?? 'Unknown Customer';
  String get storeName => store?.name ?? 'Unknown Store';
  String get driverName => driver?.name ?? 'No Driver Assigned';

  String get totalDisplay => 'Rp ${total.toStringAsFixed(0)}';
  String get subtotalDisplay => 'Rp ${subtotal.toStringAsFixed(0)}';
  String get serviceChargeDisplay => 'Rp ${serviceCharge.toStringAsFixed(0)}';

  String get orderStatusDisplay {
    switch (orderStatus) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'preparing':
        return 'Preparing';
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
      case 'waiting':
        return 'Waiting';
      case 'picking_up':
        return 'Picking Up';
      case 'on_delivery':
        return 'On Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  bool get isPending => orderStatus == 'pending';
  bool get isApproved => orderStatus == 'approved';
  bool get isPreparing => orderStatus == 'preparing';
  bool get isOnDelivery => orderStatus == 'on_delivery';
  bool get isDelivered => orderStatus == 'delivered';
  bool get isCancelled => orderStatus == 'cancelled';

  bool get hasDriver => driverId != null;
  bool get hasItems => items != null && items!.isNotEmpty;
  bool get hasReviews =>
      (orderReviews != null && orderReviews!.isNotEmpty) ||
      (driverReviews != null && driverReviews!.isNotEmpty);

  int get itemCount => items?.length ?? 0;
  int get totalQuantity =>
      items?.fold(0, (sum, item) => sum! + item.quantity) ?? 0;

  String get orderDateDisplay =>
      orderDate.toString().split(' ')[0]; // YYYY-MM-DD format
  String get orderTimeDisplay =>
      orderDate.toString().split(' ')[1].substring(0, 5); // HH:MM format
}

// Supporting classes for relations
class OrderItemInfo {
  final int id;
  final int orderId;
  final String name;
  final int quantity;
  final int price;
  final String? imageUrl;

  OrderItemInfo({
    required this.id,
    required this.orderId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItemInfo.fromJson(Map<String, dynamic> json) {
    return OrderItemInfo(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  String get totalPrice => 'Rp ${(price * quantity).toStringAsFixed(0)}';
  String get unitPrice => 'Rp ${price.toStringAsFixed(0)}';
}

class StoreInfo {
  final int id;
  final String name;
  final String address;
  final String? imageUrl;
  final String? phone;

  StoreInfo({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.phone,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
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

  DriverInfo({
    required this.id,
    required this.name,
    this.phone,
    this.vehicleNumber,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      vehicleNumber: json['vehicle_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_number': vehicleNumber,
    };
  }
}

class OrderReviewInfo {
  final int id;
  final int orderId;
  final int rating;
  final String? comment;

  OrderReviewInfo({
    required this.id,
    required this.orderId,
    required this.rating,
    this.comment,
  });

  factory OrderReviewInfo.fromJson(Map<String, dynamic> json) {
    return OrderReviewInfo(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class DriverReviewInfo {
  final int id;
  final int driverId;
  final int orderId;
  final int rating;
  final String? comment;

  DriverReviewInfo({
    required this.id,
    required this.driverId,
    required this.orderId,
    required this.rating,
    this.comment,
  });

  factory DriverReviewInfo.fromJson(Map<String, dynamic> json) {
    return DriverReviewInfo(
      id: json['id'] ?? 0,
      driverId: json['driverId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}
