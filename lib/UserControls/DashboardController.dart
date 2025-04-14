import 'package:delpick_admin/src/ApiService.dart';
import 'package:delpick_admin/src/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../src/api_config.dart';


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
  // final totalOrders = '0'.obs;
  final activeDrivers = '0'.obs;
  // final totalDrivers = '0'.obs;
  final totalStores = '0'.obs;
  final totalCustomers = '0'.obs;
  var totalOrders = '0'.obs;
  var totalDrivers = '0'.obs;
  var ordersPercentage = '+0%'.obs;
  var driversPercentage = '+0%'.obs;

  // Persentase perubahan (bisa dihitung berdasarkan data historis jika ada)
  // final ordersPercentage = '+0%'.obs;
  // final driversPercentage = '+0%'.obs;
  final storesPercentage = '+0%'.obs;
  final customersPercentage = '+0%'.obs;

  final Dio _dio = Dio();

  final RxList<SectionModel> sections = <SectionModel>[
    SectionModel(title: "Overview", icon: Icons.home),
    SectionModel(title: "Customers", icon: Icons.people),
    SectionModel(title: "Driver", icon: Icons.motorcycle_rounded),
    SectionModel(title: "Store", icon: Icons.shopping_bag),
    SectionModel(title: "Orders", icon: Icons.list_alt),
    SectionModel(title: "Statistic", icon: Icons.show_chart),
  ].obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchDashboardStats();
  // }

  // Mengambil data untuk dashboard overview dari berbagai endpoint
  // Buat instance Dio
  // final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    // Konfigurasi Dio
    _dio.options.baseUrl = ApiService.baseUrl;
    _dio.options.headers = ApiConstants.headers;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    try {
      // Fetch orders data
      final ordersResponse = await _dio.get('/orders/stats');

      if (ordersResponse.statusCode == 200) {
        final ordersData = ordersResponse.data;
        totalOrders.value = ordersData['total'].toString();
        ordersPercentage.value = '+${ordersData['percentage']}%';
      }

      // Fetch drivers data - get all drivers endpoint
      final driversResponse = await _dio.get('/drivers');

      if (driversResponse.statusCode == 200) {
        final driversData = driversResponse.data;

        // Mengambil jumlah driver dari respons API
        if (driversData['data'] != null && driversData['data'] is List) {
          final driversList = driversData['data'] as List;
          totalDrivers.value = driversList.length.toString();

          // Menghitung persentase atau menggunakan nilai default
          // Bisa ditingkatkan jika memiliki data historis untuk perbandingan
          driversPercentage.value = '+5%'; // Contoh nilai default
        }
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Penanganan kesalahan yang lebih baik dengan Dio
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          print('Connection timeout');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          print('Receive timeout');
        } else if (e.response != null) {
          print('Error response: ${e.response?.statusCode} - ${e.response?.statusMessage}');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _dio.close(); // Pastikan untuk menutup koneksi Dio ketika controller dihapus
    super.onClose();
  }
  // Future<void> fetchDashboardStats() async {
  //   isLoading.value = true;
  //   try {
  //     final token = await ApiService.getToken();
  //     final headers = {'Authorization': 'Bearer $token'};
  //
  //     // Fetch customers data
  //     final customersResponse = await _dio.get(
  //       '${ApiConfig.baseUrl}/api/customers',
  //       options: Options(headers: headers),
  //     );
  //
  //     // Fetch stores data
  //     final storesResponse = await _dio.get(
  //       '${ApiConfig.baseUrl}/api/stores',
  //       options: Options(headers: headers),
  //     );
  //
  //     // Fetch drivers data
  //     final driversResponse = await _dio.get(
  //       '${ApiConfig.baseUrl}/drivers',
  //       options: Options(headers: headers),
  //     );
  //
  //
  //     // Fetch orders data (asumsi endpoint untuk orders ada)
  //     final ordersResponse = await _dio.get(
  //       '${ApiConfig.baseUrl}/orders',
  //       options: Options(headers: headers),
  //     );
  //
  //
  //
  //     // Ekstrak total items dari response
  //     if (customersResponse.statusCode == 200) {
  //       final customersData = customersResponse.data['data'];
  //       totalCustomers.value = customersData['totalItems'].toString();
  //     }
  //
  //     if (storesResponse.statusCode == 200) {
  //       final storesData = storesResponse.data['data'];
  //       totalStores.value = storesData['totalItems'].toString();
  //     }
  //
  //     if (driversResponse.statusCode == 200) {
  //       final driversData = driversResponse.data['data'];
  //       totalDrivers.value = driversData['totalItems'].toString();
  //
  //       // Hitung active drivers dari list
  //       int active = 0;
  //       final drivers = driversData['drivers'] as List;
  //       for (var driver in drivers) {
  //         if (driver['status'] == 'active') {
  //           active++;
  //         }
  //       }
  //       activeDrivers.value = active.toString();
  //     }
  //
  //     if (ordersResponse.statusCode == 200) {
  //       final ordersData = ordersResponse.data['data'];
  //       totalOrders.value = ordersData['totalItems'].toString();
  //     }
  //
  //     // Untuk persentase perubahan, kita perlu data historis
  //     // Ini bisa ditambahkan nanti dengan membandingkan data saat ini dengan data sebelumnya
  //     ordersPercentage.value = '+10%';
  //     driversPercentage.value = '+19%';
  //     storesPercentage.value = '+10%';
  //     customersPercentage.value = '+8%';
  //
  //   } catch (e) {
  //     print('Error fetching dashboard stats: $e');
  //     // Fallback ke nilai default jika terjadi error
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Method untuk demo data
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
        'averaqeOrderValue': '\$${(index + 1) * 50}',
        'customerCount': (index + 1) * 100,
      },
    );
  }

  void changeSection(int index) {
    currentSectionIndex.value = index;
  }

  void toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value;
  }

  void refreshData() {
    fetchDashboardStats();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// class SectionModel{
//   final String title;
//   final IconData icon;
//
//   SectionModel({required this.title, required this.icon});
// }
//
// class DashboardController extends GetxController {
//   final RxInt currentSectionIndex = 0.obs;
//   // final RxBool sidebarOpen = false.obs;
//   final RxBool sidebarOpen = true.obs;
//
//   final RxList<SectionModel> sections = <SectionModel>[
//     SectionModel(title: "Overview", icon: Icons.home),
//     SectionModel(title: "Customers", icon: Icons.people),
//     SectionModel(title: "Driver", icon: Icons.motorcycle_rounded),
//     SectionModel(title: "Store", icon: Icons.shopping_bag),
//     SectionModel(title: "Orders", icon: Icons.list_alt),
//     SectionModel(title: "Statistic", icon: Icons.show_chart),
//   ].obs;
//
//   Future<List<Map<String, dynamic>>> fetchData() async {
//     await Future.delayed(Duration(seconds: 1));
//     return List.generate(
//         6,
//         (index)=>{
//           'productName': 'Product $index',
//           'sales' : '\$${(index + 1) * 1000}',
//           'stock': '${(index + 1) * 20} units',
//           'category': 'Category $index',
//           'dateAdded' : '2024-10-1${index + 1}',
//           'totalRevenue' : '\$${(index + 1)* 5000}',
//           'averaqeOrderValue' : '\$${(index + 1)* 50}',
//           'customerCount' : (index + 1) * 100,
//         });
//   }
//
//   void changeSection(int index){
//     currentSectionIndex.value = index;
//   }
//
//   void toggleSidebar(){
//     sidebarOpen.value = !sidebarOpen.value;
//   }
// }