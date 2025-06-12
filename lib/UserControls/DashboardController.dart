import 'package:delpick_admin/src/ApiService.dart';
import 'package:delpick_admin/src/CustomerService.dart';
import 'package:delpick_admin/src/DriverService.dart';
import 'package:delpick_admin/src/StoreService.dart';
import 'package:delpick_admin/src/OrderService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class SectionModel {
  final String title;
  final IconData icon;

  SectionModel({required this.title, required this.icon});
}

class DashboardController extends GetxController {
  final RxInt currentSectionIndex = 0.obs;
  final RxBool sidebarOpen = true.obs;

  // Dashboard stats
  final isLoading = true.obs;
  final activeDrivers = '0'.obs;
  final totalStores = '0'.obs;
  final totalCustomers = '0'.obs;
  var totalOrders = '0'.obs;
  var totalDrivers = '0'.obs;
  var ordersPercentage = '+0%'.obs;
  var driversPercentage = '+0%'.obs;
  final storesPercentage = '+0%'.obs;
  final customersPercentage = '+0%'.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  final Dio _dio = Dio();

  final RxList<SectionModel> sections = <SectionModel>[
    SectionModel(title: "Overview", icon: Icons.home),
    SectionModel(title: "Customers", icon: Icons.people),
    SectionModel(title: "Driver", icon: Icons.motorcycle_rounded),
    SectionModel(title: "Store", icon: Icons.shopping_bag),
    SectionModel(title: "Orders", icon: Icons.list_alt),
    SectionModel(title: "Statistic", icon: Icons.show_chart),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Configure Dio
    _dio.options.baseUrl = ApiService.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Fetch all stats concurrently
      final List<Future> futures = [
        _fetchOrderStats(),
        _fetchDriverStats(),
        _fetchStoreStats(),
        _fetchCustomerStats(),
      ];

      await Future.wait(futures);
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);

      // Set default values on error
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchOrderStats() async {
    try {
      // First try to get order stats from dedicated endpoint
      try {
        final response = await _dio.get('/orders/stats');
        if (response.statusCode == 200) {
          final data = response.data;
          // Handle backend response format {message, data}
          final statsData = data['data'] ?? data;
          totalOrders.value =
              (statsData['total'] ?? statsData['totalOrders'] ?? 0).toString();
          ordersPercentage.value = '+${statsData['percentage'] ?? 0}%';
          return;
        }
      } catch (e) {
        print('Order stats endpoint not available, trying orders list: $e');
      }

      // Fallback: get orders count from orders list
      final response = await _dio.get('/orders?page=1&limit=1');
      if (response.statusCode == 200) {
        final data = response.data;
        final responseData = data['data'] ?? data;

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('totalItems')) {
          totalOrders.value = responseData['totalItems'].toString();
        } else if (data is List) {
          totalOrders.value = data.length.toString();
        } else {
          totalOrders.value = '0';
        }
        ordersPercentage.value = '+10%'; // Default percentage
      }
    } catch (e) {
      print('Error fetching order stats: $e');
      totalOrders.value = '0';
      ordersPercentage.value = '+0%';
    }
  }

  Future<void> _fetchDriverStats() async {
    try {
      final response = await _dio.get(
          '/drivers?page=1&limit=100'); // Get more drivers to count active ones
      if (response.statusCode == 200) {
        final data = response.data;

        // Handle backend response format
        if (data is List) {
          // Direct array response
          totalDrivers.value = data.length.toString();
          final activeCount =
              data.where((driver) => driver['status'] == 'active').length;
          activeDrivers.value = activeCount.toString();
        } else if (data is Map) {
          // Check for different response structures
          if (data.containsKey('data')) {
            final responseData = data['data'];
            if (responseData is List) {
              totalDrivers.value = responseData.length.toString();
              final activeCount = responseData
                  .where((driver) => driver['status'] == 'active')
                  .length;
              activeDrivers.value = activeCount.toString();
            } else if (responseData is Map &&
                responseData.containsKey('drivers')) {
              final drivers = responseData['drivers'] as List;
              totalDrivers.value = drivers.length.toString();
              final activeCount = drivers
                  .where((driver) => driver['status'] == 'active')
                  .length;
              activeDrivers.value = activeCount.toString();
            }
          }
        }

        driversPercentage.value = '+5%'; // Default percentage
      }
    } catch (e) {
      print('Error fetching driver stats: $e');
      totalDrivers.value = '0';
      activeDrivers.value = '0';
      driversPercentage.value = '+0%';
    }
  }

  Future<void> _fetchStoreStats() async {
    try {
      final response = await _dio.get('/stores?page=1&limit=1');
      if (response.statusCode == 200) {
        final data = response.data;
        final responseData = data['data'] ?? data;

        if (responseData is Map && responseData.containsKey('totalItems')) {
          totalStores.value = responseData['totalItems'].toString();
        } else if (data is List) {
          totalStores.value = data.length.toString();
        } else {
          totalStores.value = '0';
        }

        storesPercentage.value = '+8%'; // Default percentage
      }
    } catch (e) {
      print('Error fetching store stats: $e');
      totalStores.value = '0';
      storesPercentage.value = '+0%';
    }
  }

  Future<void> _fetchCustomerStats() async {
    try {
      final response = await _dio.get('/customers?page=1&limit=1');
      if (response.statusCode == 200) {
        final data = response.data;
        final responseData = data['data'] ?? data;

        if (responseData is Map && responseData.containsKey('totalItems')) {
          totalCustomers.value = responseData['totalItems'].toString();
        } else if (data is List) {
          totalCustomers.value = data.length.toString();
        } else {
          totalCustomers.value = '0';
        }

        customersPercentage.value = '+12%'; // Default percentage
      }
    } catch (e) {
      print('Error fetching customer stats: $e');
      totalCustomers.value = '0';
      customersPercentage.value = '+0%';
    }
  }

  void _setDefaultValues() {
    totalOrders.value = '0';
    totalDrivers.value = '0';
    activeDrivers.value = '0';
    totalStores.value = '0';
    totalCustomers.value = '0';
    ordersPercentage.value = '+0%';
    driversPercentage.value = '+0%';
    storesPercentage.value = '+0%';
    customersPercentage.value = '+0%';
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.receiveTimeout:
          return 'Server response timeout. Please try again.';
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return 'Authentication failed. Please login again.';
          } else if (error.response?.statusCode == 403) {
            return 'Access denied. Admin privileges required.';
          }
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Network error occurred.';
      }
    }
    return error.toString();
  }

  // Method untuk demo data (tetap diperlukan untuk beberapa komponen)
  Future<List<Map<String, dynamic>>> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(
      6,
      (index) => {
        'productName': 'Product $index',
        'sales': '\$${(index + 1) * 1000}',
        'stock': '${(index + 1) * 20} units',
        'category': 'Category $index',
        'dateAdded': '2024-10-1${index + 1}',
        'totalRevenue': '\$${(index + 1) * 5000}',
        'averageOrderValue': '\$${(index + 1) * 50}',
        'customerCount': (index + 1) * 100,
      },
    );
  }

  // Navigation methods
  void changeSection(int index) {
    currentSectionIndex.value = index;
  }

  void toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value;
  }

  void refreshData() {
    fetchDashboardStats();
  }

  // Utility methods for stats display
  String get totalOrdersFormatted {
    final orders = int.tryParse(totalOrders.value) ?? 0;
    if (orders >= 1000) {
      return '${(orders / 1000).toStringAsFixed(1)}K';
    }
    return orders.toString();
  }

  String get totalDriversFormatted {
    final drivers = int.tryParse(totalDrivers.value) ?? 0;
    if (drivers >= 1000) {
      return '${(drivers / 1000).toStringAsFixed(1)}K';
    }
    return drivers.toString();
  }

  String get totalStoresFormatted {
    final stores = int.tryParse(totalStores.value) ?? 0;
    if (stores >= 1000) {
      return '${(stores / 1000).toStringAsFixed(1)}K';
    }
    return stores.toString();
  }

  String get totalCustomersFormatted {
    final customers = int.tryParse(totalCustomers.value) ?? 0;
    if (customers >= 1000) {
      return '${(customers / 1000).toStringAsFixed(1)}K';
    }
    return customers.toString();
  }

  // Helper methods to get section names
  String getCurrentSectionName() {
    if (currentSectionIndex.value < sections.length) {
      return sections[currentSectionIndex.value].title;
    }
    return 'Dashboard';
  }

  IconData getCurrentSectionIcon() {
    if (currentSectionIndex.value < sections.length) {
      return sections[currentSectionIndex.value].icon;
    }
    return Icons.dashboard;
  }

  // Check if specific sections are active
  bool get isOverviewActive => currentSectionIndex.value == 0;
  bool get isCustomersActive => currentSectionIndex.value == 1;
  bool get isDriversActive => currentSectionIndex.value == 2;
  bool get isStoresActive => currentSectionIndex.value == 3;
  bool get isOrdersActive => currentSectionIndex.value == 4;
  bool get isStatisticsActive => currentSectionIndex.value == 5;

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
