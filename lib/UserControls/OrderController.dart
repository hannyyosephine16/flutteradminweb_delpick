import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/OrderService.dart';
import '../Models/OrderModel.dart';

class OrderController extends GetxController {
  // Observable variables
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final noAdminAccess = true.obs; // Backend tidak support admin orders

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 0.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 10.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Tidak fetch orders karena backend tidak punya endpoint admin orders
    showAdminLimitation();
  }

  void showAdminLimitation() {
    Get.snackbar(
      'Information',
      'Admin orders view is not available in current backend implementation.\n\nAvailable order endpoints:\n• /orders/user (Customer only)\n• /orders/store (Store owner only)',
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Method untuk menampilkan informasi keterbatasan
  Widget buildNoAccessWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.orange,
          ),
          SizedBox(height: 16),
          Text(
            'Orders Management Not Available',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Backend does not provide admin access to all orders',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Order Endpoints:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text('• GET /orders/user - Customer orders only'),
                Text('• GET /orders/store - Store owner orders only'),
                Text('• GET /orders/:id - Individual order details'),
                SizedBox(height: 12),
                Text(
                  'To implement admin orders view, backend needs:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text('• GET /orders - Admin access to all orders'),
                Text('• GET /orders/stats - Order statistics'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder methods untuk konsistensi interface
  Future<void> fetchOrders({int page = 1, bool isRefresh = false}) async {
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    isLoading.value = false;

    _showNotAvailableSnackbar('Fetch orders not available');
  }

  Future<void> refreshOrders() async {
    _showNotAvailableSnackbar('Refresh orders not available');
  }

  Future<OrderModel?> getOrderById(String id) async {
    try {
      // Ini masih bisa digunakan karena ada endpoint /orders/:id
      final response = await OrderService.getOrderById(id);
      return OrderModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get order: ${e.toString()}');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await OrderService.updateOrderStatus(orderId, status);
      _showSuccessSnackbar('Order status updated successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update order status: ${e.toString()}');
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await OrderService.cancelOrder(orderId);
      _showSuccessSnackbar('Order cancelled successfully');
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to cancel order: ${e.toString()}');
      return false;
    }
  }

  // Search and filter methods (placeholder)
  void searchOrders(String query) {
    searchQuery.value = query;
    _showNotAvailableSnackbar('Search orders not available for admin');
  }

  void filterOrdersByStatus(String status) {
    selectedStatusFilter.value = status;
    _showNotAvailableSnackbar('Filter orders not available for admin');
  }

  // Utility methods
  List<OrderModel> get filteredOrders => orders; // Empty list

  int get totalOrdersCount => 0;
  int get pendingOrdersCount => 0;
  int get completedOrdersCount => 0;

  // Status options
  List<String> get statusOptions => [
        'all',
        'pending',
        'approved',
        'preparing',
        'on_delivery',
        'delivered',
        'cancelled'
      ];

  // Helper methods for tracking
  Future<Map<String, dynamic>?> getTrackingData(String orderId) async {
    try {
      return await OrderService.getTrackingData(orderId);
    } catch (e) {
      _showErrorSnackbar('Failed to get tracking data: ${e.toString()}');
      return null;
    }
  }

  // Snackbar helpers
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showNotAvailableSnackbar(String message) {
    Get.snackbar(
      'Not Available',
      '$message\nBackend limitation: No admin orders endpoint',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }
}
