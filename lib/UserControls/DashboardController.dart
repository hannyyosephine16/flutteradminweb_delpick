// import 'package:delpick_admin/src/ApiService.dart';
// import 'package:delpick_admin/src/api_constant.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
//
// class SectionModel {
//   final String title;
//   final IconData icon;
//
//   SectionModel({required this.title, required this.icon});
// }
//
// class DashboardController extends GetxController {
//   final RxInt currentSectionIndex = 0.obs;
//   final RxBool sidebarOpen = true.obs;
//
//   // Dashboard stats
//   final isLoading = true.obs;
//   final activeDrivers = '0'.obs;
//   final totalStores = '0'.obs;
//   final totalCustomers = '0'.obs;
//   var totalOrders = '0'.obs;
//   var totalDrivers = '0'.obs;
//   var ordersPercentage = '+0%'.obs;
//   var driversPercentage = '+0%'.obs;
//   final storesPercentage = '+0%'.obs;
//   final customersPercentage = '+0%'.obs;
//
//   // Error handling
//   final RxString errorMessage = ''.obs;
//   final RxBool hasError = false.obs;
//
//   final Dio _dio = Dio();
//
//   final RxList<SectionModel> sections = <SectionModel>[
//     SectionModel(title: "Overview", icon: Icons.home),
//     SectionModel(title: "Customers", icon: Icons.people),
//     SectionModel(title: "Driver", icon: Icons.motorcycle_rounded),
//     SectionModel(title: "Store", icon: Icons.shopping_bag),
//     SectionModel(title: "Orders", icon: Icons.list_alt),
//     SectionModel(title: "Menu Items", icon: Icons.restaurant_menu),
//   ].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _dio.options.baseUrl = ApiConstants.baseUrl;
//     _dio.options.connectTimeout = const Duration(seconds: 10);
//     _dio.options.receiveTimeout = const Duration(seconds: 10);
//
//     fetchDashboardStats();
//   }
//
//   Future<void> fetchDashboardStats() async {
//     isLoading.value = true;
//     hasError.value = false;
//     errorMessage.value = '';
//
//     try {
//       final token = await ApiService.getToken();
//       if (token == null) {
//         throw Exception('No authentication token found');
//       }
//
//       _dio.options.headers = {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       };
//
//       // Fetch stats dari endpoint yang ADA di backend
//       final List<Future> futures = [
//         _fetchCustomerStats(),
//         _fetchDriverStats(),
//         _fetchStoreStats(),
//         _fetchOrderStats(), // Menggunakan estimasi dari data yang ada
//       ];
//
//       await Future.wait(futures);
//     } catch (e) {
//       print('Error fetching dashboard stats: $e');
//       hasError.value = true;
//       errorMessage.value = _getErrorMessage(e);
//       _setDefaultValues();
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Menggunakan endpoint /customers yang ADA
//   Future<void> _fetchCustomerStats() async {
//     try {
//       final response = await _dio.get('/customers?page=1&limit=1');
//       if (response.statusCode == 200) {
//         final data = response.data;
//
//         // Handle response format dari backend: {message, data: {totalItems, totalPages, currentPage, customers}}
//         if (data['data'] != null && data['data']['totalItems'] != null) {
//           totalCustomers.value = data['data']['totalItems'].toString();
//         } else {
//           totalCustomers.value = '0';
//         }
//
//         customersPercentage.value = '+12%'; // Static percentage
//       }
//     } catch (e) {
//       print('Error fetching customer stats: $e');
//       totalCustomers.value = '0';
//       customersPercentage.value = '+0%';
//     }
//   }
//
//   // Menggunakan endpoint /drivers yang ADA
//   Future<void> _fetchDriverStats() async {
//     try {
//       final response = await _dio.get('/drivers?page=1&limit=100');
//       if (response.statusCode == 200) {
//         final data = response.data;
//
//         // Handle different response formats dari backend
//         List<dynamic> drivers = [];
//
//         if (data is List) {
//           drivers = data;
//         } else if (data['data'] != null) {
//           if (data['data'] is List) {
//             drivers = data['data'];
//           } else if (data['data']['drivers'] != null) {
//             drivers = data['data']['drivers'];
//           }
//         }
//
//         totalDrivers.value = drivers.length.toString();
//
//         // Count active drivers
//         final activeCount =
//             drivers.where((driver) => driver['status'] == 'active').length;
//         activeDrivers.value = activeCount.toString();
//
//         driversPercentage.value = '+5%'; // Static percentage
//       }
//     } catch (e) {
//       print('Error fetching driver stats: $e');
//       totalDrivers.value = '0';
//       activeDrivers.value = '0';
//       driversPercentage.value = '+0%';
//     }
//   }
//
//   // Menggunakan endpoint /stores yang ADA
//   Future<void> _fetchStoreStats() async {
//     try {
//       final response = await _dio.get('/stores?page=1&limit=1');
//       if (response.statusCode == 200) {
//         final data = response.data;
//
//         // Handle response format: {message, data: {totalItems, totalPages, currentPage, stores}}
//         if (data['data'] != null && data['data']['totalItems'] != null) {
//           totalStores.value = data['data']['totalItems'].toString();
//         } else {
//           totalStores.value = '0';
//         }
//
//         storesPercentage.value = '+8%'; // Static percentage
//       }
//     } catch (e) {
//       print('Error fetching store stats: $e');
//       totalStores.value = '0';
//       storesPercentage.value = '+0%';
//     }
//   }
//
//   // TIDAK ADA endpoint /orders untuk admin, jadi kita estimasi
//   Future<void> _fetchOrderStats() async {
//     try {
//       // Backend tidak punya endpoint untuk admin melihat semua orders
//       // Kita set default atau bisa fetch dari user/store orders jika memungkinkan
//       totalOrders.value = '0';
//       ordersPercentage.value = '+0%';
//
//       print('No admin orders endpoint available in backend');
//     } catch (e) {
//       print('Error fetching order stats: $e');
//       totalOrders.value = '0';
//       ordersPercentage.value = '+0%';
//     }
//   }
//
//   void _setDefaultValues() {
//     totalOrders.value = '0';
//     totalDrivers.value = '0';
//     activeDrivers.value = '0';
//     totalStores.value = '0';
//     totalCustomers.value = '0';
//     ordersPercentage.value = '+0%';
//     driversPercentage.value = '+0%';
//     storesPercentage.value = '+0%';
//     customersPercentage.value = '+0%';
//   }
//
//   String _getErrorMessage(dynamic error) {
//     if (error is DioException) {
//       switch (error.type) {
//         case DioExceptionType.connectionTimeout:
//           return 'Connection timeout. Please check your internet connection.';
//         case DioExceptionType.receiveTimeout:
//           return 'Server response timeout. Please try again.';
//         case DioExceptionType.badResponse:
//           if (error.response?.statusCode == 401) {
//             return 'Authentication failed. Please login again.';
//           } else if (error.response?.statusCode == 403) {
//             return 'Access denied. Admin privileges required.';
//           }
//           return 'Server error: ${error.response?.statusCode}';
//         case DioExceptionType.cancel:
//           return 'Request was cancelled.';
//         default:
//           return 'Network error occurred.';
//       }
//     }
//     return error.toString();
//   }
//
//   // Navigation methods
//   void changeSection(int index) {
//     currentSectionIndex.value = index;
//   }
//
//   void toggleSidebar() {
//     sidebarOpen.value = !sidebarOpen.value;
//   }
//
//   void refreshData() {
//     fetchDashboardStats();
//   }
//
//   // Utility methods for stats display
//   String get totalOrdersFormatted {
//     final orders = int.tryParse(totalOrders.value) ?? 0;
//     if (orders >= 1000) {
//       return '${(orders / 1000).toStringAsFixed(1)}K';
//     }
//     return orders.toString();
//   }
//
//   String get totalDriversFormatted {
//     final drivers = int.tryParse(totalDrivers.value) ?? 0;
//     if (drivers >= 1000) {
//       return '${(drivers / 1000).toStringAsFixed(1)}K';
//     }
//     return drivers.toString();
//   }
//
//   String get totalStoresFormatted {
//     final stores = int.tryParse(totalStores.value) ?? 0;
//     if (stores >= 1000) {
//       return '${(stores / 1000).toStringAsFixed(1)}K';
//     }
//     return stores.toString();
//   }
//
//   String get totalCustomersFormatted {
//     final customers = int.tryParse(totalCustomers.value) ?? 0;
//     if (customers >= 1000) {
//       return '${(customers / 1000).toStringAsFixed(1)}K';
//     }
//     return customers.toString();
//   }
//
//   // Helper methods to get section names
//   String getCurrentSectionName() {
//     if (currentSectionIndex.value < sections.length) {
//       return sections[currentSectionIndex.value].title;
//     }
//     return 'Dashboard';
//   }
//
//   IconData getCurrentSectionIcon() {
//     if (currentSectionIndex.value < sections.length) {
//       return sections[currentSectionIndex.value].icon;
//     }
//     return Icons.dashboard;
//   }
//
//   // Check if specific sections are active
//   bool get isOverviewActive => currentSectionIndex.value == 0;
//   bool get isCustomersActive => currentSectionIndex.value == 1;
//   bool get isDriversActive => currentSectionIndex.value == 2;
//   bool get isStoresActive => currentSectionIndex.value == 3;
//   bool get isOrdersActive => currentSectionIndex.value == 4;
//   bool get isMenuItemsActive => currentSectionIndex.value == 5;
//
//   @override
//   void onClose() {
//     _dio.close();
//     super.onClose();
//   }
// }
// FIXED: DashboardController.dart - Updated to handle backend response format and missing endpoints
import 'package:delpick_admin/src/ApiService.dart';
import 'package:delpick_admin/src/api_constant.dart';
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
    SectionModel(title: "Menu Items", icon: Icons.restaurant_menu),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _dio.options.baseUrl = ApiConstants.baseUrl;
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

      print('🔄 Fetching dashboard stats from backend...');

      // Fetch stats dari endpoint yang ADA di backend
      final List<Future> futures = [
        _fetchCustomerStats(),
        _fetchDriverStats(),
        _fetchStoreStats(),
        // ❌ REMOVED: _fetchOrderStats() - endpoint tidak ada untuk admin
      ];

      await Future.wait(futures);

      // Set default orders count karena endpoint tidak ada
      totalOrders.value = '0';
      ordersPercentage.value = '+0%';

      print('✅ Dashboard stats fetch completed');
    } catch (e) {
      print('❌ Error fetching dashboard stats: $e');
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCustomerStats() async {
    try {
      print('🔄 Fetching customer stats...');
      final response =
          await _dio.get('${ApiConstants.customers}?page=1&limit=1');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📊 Customer response: ${data.runtimeType}');

        if (data is Map<String, dynamic> &&
            data.containsKey('message') &&
            data.containsKey('data')) {
          final responseData = data['data'] as Map<String, dynamic>;

          // ✅ FIXED: Use correct key names
          if (responseData.containsKey('total_items')) {
            totalCustomers.value = responseData['total_items'].toString();
            print('✅ Customer stats: ${totalCustomers.value}');
          } else {
            totalCustomers.value = '0';
            print('⚠️ No total_items found in customer response');
          }
        } else {
          print('⚠️ Unexpected customer response format');
          totalCustomers.value = '0';
        }

        customersPercentage.value = '+12%'; // Static percentage
      } else {
        print('❌ Customer API error: ${response.statusCode}');
        totalCustomers.value = '0';
      }
    } catch (e) {
      print('❌ Error fetching customer stats: $e');
      totalCustomers.value = '0';
      customersPercentage.value = '+0%';
    }
  }

  Future<void> _fetchDriverStats() async {
    try {
      print('🔄 Fetching driver stats...');
      final response =
          await _dio.get('${ApiConstants.drivers}?page=1&limit=100');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📊 Driver response: ${data.runtimeType}');

        List<dynamic> drivers = [];

        // ✅ FIXED: Handle different possible response formats from backend
        if (data is Map<String, dynamic>) {
          // Format 1: { statusCode: 200, message: "...", data: { total_items, drivers: [...] } }
          if (data['statusCode'] == 200 && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;

            if (responseData.containsKey('drivers')) {
              drivers = responseData['drivers'] as List<dynamic>? ?? [];
            } else if (responseData.containsKey('total_items')) {
              // If only total_items is available
              totalDrivers.value = responseData['total_items'].toString();
              driversPercentage.value = '+5%';
              return;
            }
          }
          // Format 2: { message: "...", data: [...] } - direct array
          else if (data.containsKey('data') && data['data'] is List) {
            drivers = data['data'] as List<dynamic>;
          }
        }
        // Format 3: Direct array response
        else if (data is List) {
          drivers = data;
        }

        totalDrivers.value = drivers.length.toString();

        // Count active drivers
        final activeCount = drivers
            .where((driver) =>
                driver is Map<String, dynamic> && driver['status'] == 'active')
            .length;
        activeDrivers.value = activeCount.toString();

        driversPercentage.value = '+5%'; // Static percentage

        print(
            '✅ Driver stats - Total: ${totalDrivers.value}, Active: ${activeDrivers.value}');
      } else {
        print('❌ Driver API error: ${response.statusCode}');
        totalDrivers.value = '0';
        activeDrivers.value = '0';
      }
    } catch (e) {
      print('❌ Error fetching driver stats: $e');
      totalDrivers.value = '0';
      activeDrivers.value = '0';
      driversPercentage.value = '+0%';
    }
  }

  Future<void> _fetchStoreStats() async {
    try {
      print('🔄 Fetching store stats...');
      final response = await _dio.get('${ApiConstants.stores}?page=1&limit=1');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📊 Store response: ${data.runtimeType}');

        // ✅ FIXED: Handle actual backend response format
        if (data is Map<String, dynamic> &&
            data.containsKey('message') &&
            data.containsKey('data')) {
          final responseData = data['data'] as Map<String, dynamic>;

          if (responseData.containsKey('total_items')) {
            totalStores.value = responseData['total_items'].toString();
            print('✅ Store stats: ${totalStores.value}');
          } else {
            totalStores.value = '0';
            print('⚠️ No total_items found in store response');
          }
        } else {
          print('⚠️ Unexpected store response format');
          totalStores.value = '0';
        }

        storesPercentage.value = '+8%'; // Static percentage
      } else {
        print('❌ Store API error: ${response.statusCode}');
        totalStores.value = '0';
      }
    } catch (e) {
      print('❌ Error fetching store stats: $e');
      totalStores.value = '0';
      storesPercentage.value = '+0%';
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
  bool get isMenuItemsActive => currentSectionIndex.value == 5;

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
