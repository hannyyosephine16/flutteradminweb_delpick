class CustomerModel {
  final String name;
  final String email;
  final String phone;
  final String registeredDate;
  final int orders;
  final double spent;
  final int loyaltyPoints;
  final String imageUrl; // Added imageUrl field

  CustomerModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.registeredDate,
    required this.orders,
    required this.spent,
    required this.loyaltyPoints,
    required this.imageUrl, // Include imageUrl in constructor
  });
}