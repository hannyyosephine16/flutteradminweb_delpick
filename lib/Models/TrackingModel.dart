import 'OrderModel.dart';
import 'DriverModel.dart';

class DriverRequestModel {
  final int id;
  final int orderId;
  final int driverId;
  final String status;
  final DateTime? estimatedPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final OrderModel? order;
  final DriverModel? driver;

  DriverRequestModel({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.status,
    this.estimatedPickupTime,
    this.estimatedDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
    this.order,
    this.driver,
  });

  factory DriverRequestModel.fromJson(Map<String, dynamic> json) {
    return DriverRequestModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.parse(json['estimated_pickup_time'])
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      order: json['order'] != null ? OrderModel.fromJson(json['order']) : null,
      driver:
          json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'status': status,
      'estimated_pickup_time': estimatedPickupTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
  bool get isExpired => status == 'expired';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  String get driverName => driver?.displayName ?? 'Unknown Driver';
  String get orderInfo => 'Order #$orderId';
  String get requestDate => createdAt.toString().split(' ')[0];
}
