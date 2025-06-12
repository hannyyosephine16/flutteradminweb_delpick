import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/DriverService.dart';
import 'dart:typed_data';

// Import the DriverModel we created earlier
class DriverModel {
  final int id;
  final int userId;
  final String vehicleNumber;
  final double rating;
  final int reviewsCount;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserInfo? user;

  DriverModel({
    required this.id,
    required this.userId,
    required this.vehicleNumber,
    required this.rating,
    required this.reviewsCount,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      vehicleNumber: json['vehicle_number'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      status: json['status'] ?? 'inactive',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }

  String get displayName => user?.name ?? 'Unknown Driver';
  String get displayEmail => user?.email ?? '';
  String get displayPhone => user?.phone ?? '';
  bool get isActive => status == 'active';
  bool get isBusy => status == 'busy';
  String get ratingDisplay => rating.toStringAsFixed(1);
}

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class DriverController extends GetxController {
  // Observable variables
  final drivers = <DriverModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 0.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 10.obs;

  // Search and filter
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;

  // Selection
  final selectedDrivers = <DriverModel>[].obs;
  final isAllSelected = false.obs;

  // Form data for add/edit
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final vehicleNumberController = TextEditingController();

  // Form state
  final isFormLoading = false.obs;
  final isEditMode = false.obs;
  final editingDriverId = ''.obs;
  final selectedImageBase64 = ''.obs;
  final selectedStatus = 'inactive'.obs;

  // Driver locations for tracking
  final driverLocations = <String, Map<String, double>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDrivers();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    vehicleNumberController.dispose();
    super.onClose();
  }

  // Fetch drivers with pagination
  Future<void> fetchDrivers({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        drivers.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final response = await DriverService.getAllDrivers(
          page: page, limit: itemsPerPage.value);

      // Handle backend response format
      List<dynamic> driversData;
      if (response.containsKey('data') && response['data'] is List) {
        driversData = response['data'];
      } else if (response.containsKey('drivers')) {
        driversData = response['drivers'];
      } else if (response is List) {
        driversData = response;
      } else {
        driversData = [];
      }

      final driversList =
          driversData.map((json) => DriverModel.fromJson(json)).toList();

      if (page == 1) {
        drivers.assignAll(driversList);
      } else {
        drivers.addAll(driversList);
      }

      // Update pagination info
      currentPage.value = response['currentPage'] ?? page;
      totalPages.value = response['totalPages'] ?? 1;
      totalItems.value = response['totalItems'] ?? driversList.length;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      _showErrorSnackbar('Failed to load drivers: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more drivers (pagination)
  Future<void> loadMoreDrivers() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchDrivers(page: currentPage.value + 1);
    }
  }

  // Refresh drivers list
  Future<void> refreshDrivers() async {
    await fetchDrivers(page: 1, isRefresh: true);
  }

  // Search drivers
  void searchDrivers(String query) {
    searchQuery.value = query;
    fetchDrivers(page: 1, isRefresh: true);
  }

  // Filter drivers by status
  void filterDriversByStatus(String status) {
    selectedStatusFilter.value = status;
    fetchDrivers(page: 1, isRefresh: true);
  }

  // Get driver by ID
  Future<DriverModel?> getDriverById(String id) async {
    try {
      final response = await DriverService.getDriverById(id);
      return DriverModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get driver: ${e.toString()}');
      return null;
    }
  }

  // Create new driver
  Future<bool> createDriver() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      await DriverService.createDriver(
        nameController.text,
        emailController.text,
        passwordController.text,
        phoneController.text,
        vehicleNumberController.text,
        selectedImageBase64.value.isNotEmpty ? selectedImageBase64.value : null,
      );

      _showSuccessSnackbar('Driver created successfully');
      clearForm();
      refreshDrivers();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to create driver: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Update driver
  Future<bool> updateDriver() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final Map<String, dynamic> updateData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'vehicle_number': vehicleNumberController.text,
        'status': selectedStatus.value,
      };

      if (passwordController.text.isNotEmpty) {
        updateData['password'] = passwordController.text;
      }

      if (selectedImageBase64.value.isNotEmpty) {
        updateData['image'] = selectedImageBase64.value;
      }

      await DriverService.updateDriver(editingDriverId.value, updateData);

      _showSuccessSnackbar('Driver updated successfully');
      clearForm();
      refreshDrivers();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update driver: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Delete driver
  Future<bool> deleteDriver(String id) async {
    try {
      await DriverService.deleteDriver(id);
      _showSuccessSnackbar('Driver deleted successfully');
      refreshDrivers();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete driver: ${e.toString()}');
      return false;
    }
  }

  // Delete multiple drivers
  Future<bool> deleteMultipleDrivers() async {
    if (selectedDrivers.isEmpty) {
      _showErrorSnackbar('No drivers selected');
      return false;
    }

    try {
      for (final driver in selectedDrivers) {
        await DriverService.deleteDriver(driver.id.toString());
      }

      _showSuccessSnackbar(
          '${selectedDrivers.length} drivers deleted successfully');
      clearSelection();
      refreshDrivers();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete drivers: ${e.toString()}');
      return false;
    }
  }

  // Update driver location
  Future<void> updateDriverLocation(
      String driverId, double latitude, double longitude) async {
    try {
      await DriverService.updateDriverLocation(latitude, longitude);
      driverLocations[driverId] = {
        'latitude': latitude,
        'longitude': longitude
      };
      _showSuccessSnackbar('Driver location updated');
    } catch (e) {
      _showErrorSnackbar('Failed to update driver location: ${e.toString()}');
    }
  }

  // Get driver location
  Future<Map<String, dynamic>?> getDriverLocation(String driverId) async {
    try {
      return await DriverService.getDriverLocation(driverId);
    } catch (e) {
      _showErrorSnackbar('Failed to get driver location: ${e.toString()}');
      return null;
    }
  }

  // Update driver status
  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      await DriverService.updateDriverStatus(status);

      // Update local driver status
      final driverIndex =
          drivers.indexWhere((d) => d.id.toString() == driverId);
      if (driverIndex != -1) {
        // Note: This is a simplified update. In a real app, you'd want to refresh the driver data
        refreshDrivers();
      }

      _showSuccessSnackbar('Driver status updated to $status');
    } catch (e) {
      _showErrorSnackbar('Failed to update driver status: ${e.toString()}');
    }
  }

  // Get driver orders
  Future<List<Map<String, dynamic>>> getDriverOrders(
      {int page = 1, int limit = 10}) async {
    try {
      final response =
          await DriverService.getDriverOrders(page: page, limit: limit);
      return List<Map<String, dynamic>>.from(response['orders'] ?? []);
    } catch (e) {
      _showErrorSnackbar('Failed to get driver orders: ${e.toString()}');
      return [];
    }
  }

  // Form management
  void setEditMode(DriverModel driver) {
    isEditMode.value = true;
    editingDriverId.value = driver.id.toString();
    nameController.text = driver.displayName;
    emailController.text = driver.displayEmail;
    phoneController.text = driver.displayPhone;
    vehicleNumberController.text = driver.vehicleNumber;
    selectedStatus.value = driver.status;
    passwordController.clear();
    confirmPasswordController.clear();
    selectedImageBase64.value = driver.user?.avatar ?? '';
  }

  void clearForm() {
    isEditMode.value = false;
    editingDriverId.value = '';
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    vehicleNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedImageBase64.value = '';
    selectedStatus.value = 'inactive';
  }

  void setSelectedImage(String base64Image) {
    selectedImageBase64.value = base64Image;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  // Selection management
  void toggleDriverSelection(DriverModel driver) {
    if (selectedDrivers.contains(driver)) {
      selectedDrivers.remove(driver);
    } else {
      selectedDrivers.add(driver);
    }
    _updateSelectAllState();
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      selectedDrivers.clear();
    } else {
      selectedDrivers.assignAll(drivers);
    }
    _updateSelectAllState();
  }

  void clearSelection() {
    selectedDrivers.clear();
    isAllSelected.value = false;
  }

  void _updateSelectAllState() {
    isAllSelected.value =
        drivers.isNotEmpty && selectedDrivers.length == drivers.length;
  }

  // Utility methods
  bool isDriverSelected(DriverModel driver) {
    return selectedDrivers.contains(driver);
  }

  int get selectedCount => selectedDrivers.length;

  List<DriverModel> get filteredDrivers {
    var filtered = drivers.where((driver) {
      // Status filter
      if (selectedStatusFilter.value != 'all' &&
          driver.status != selectedStatusFilter.value) {
        return false;
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return driver.displayName.toLowerCase().contains(query) ||
            driver.displayEmail.toLowerCase().contains(query) ||
            driver.displayPhone.contains(query) ||
            driver.vehicleNumber.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    return filtered;
  }

  // Statistics
  int get totalDriversCount => totalItems.value;
  int get activeDriversCount => drivers.where((d) => d.isActive).length;
  int get busyDriversCount => drivers.where((d) => d.isBusy).length;
  int get inactiveDriversCount =>
      drivers.where((d) => d.status == 'inactive').length;

  double get averageRating => drivers.isEmpty
      ? 0.0
      : drivers.fold(0.0, (sum, driver) => sum + driver.rating) /
          drivers.length;

  String get averageRatingDisplay => averageRating.toStringAsFixed(1);

  // Status options for dropdown
  List<String> get statusOptions => ['active', 'inactive', 'busy'];

  // Filter options
  List<String> get filterOptions => ['all', 'active', 'inactive', 'busy'];

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

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (value.length < 10) {
      return 'Phone must be at least 10 digits';
    }
    return null;
  }

  String? validateVehicleNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle number is required';
    }
    if (value.length < 3) {
      return 'Vehicle number must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (isEditMode.value && (value == null || value.isEmpty)) {
      return null; // Password is optional when editing
    }
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (isEditMode.value && passwordController.text.isEmpty) {
      return null; // Skip validation if password is not being updated
    }
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
