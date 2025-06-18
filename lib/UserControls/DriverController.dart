import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/DriverModel.dart';
import '../src/DriverService.dart';

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
  final licenseNumberController = TextEditingController();
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
    licenseNumberController.dispose();
    vehicleNumberController.dispose();
    super.onClose();
  }

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
        page: page,
        limit: itemsPerPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response == null) {
        throw Exception('No response received from server');
      }

      print('🔍 Controller - Response type: ${response.runtimeType}');
      print('🔍 Controller - Response keys: ${response.keys.toList()}');

      List<dynamic> driversData = [];
      int totalPages = 1;
      int totalItems = 0;
      int currentPageNum = page;

      final dataField = response['data'];
      print('🔍 Data field type: ${dataField.runtimeType}');

      if (dataField is List) {
        print('✅ Found drivers array in data field');
        driversData = List<dynamic>.from(dataField);
      } else if (dataField is Map<String, dynamic>) {
        print('📋 Data field keys: ${dataField.keys.toList()}');
        final driversField = dataField['drivers'];
        if (driversField is List) {
          print('✅ Found drivers array in data.drivers');
          driversData = List<dynamic>.from(driversField);
        }
      } else {
        print('⚠️ Unexpected data field type: ${dataField.runtimeType}');
        final rootDrivers = response['drivers'];
        if (rootDrivers is List) {
          print('✅ Found drivers array at root level');
          driversData = List<dynamic>.from(rootDrivers);
        }
      }

      totalPages = (response['totalPages'] as num?)?.toInt() ?? 1;
      totalItems =
          (response['totalItems'] as num?)?.toInt() ?? driversData.length;
      currentPageNum = (response['currentPage'] as num?)?.toInt() ?? page;

      print('📊 Extracted ${driversData.length} drivers from response');
      print(
          '📊 Pagination: Page $currentPageNum of $totalPages (Total: $totalItems)');

      final List<DriverModel> driversList = [];
      for (int i = 0; i < driversData.length; i++) {
        try {
          final item = driversData[i];
          if (item is Map<String, dynamic>) {
            final driver =
                DriverModel.fromJson(Map<String, dynamic>.from(item));
            driversList.add(driver);
            print('✅ Parsed driver ${i + 1}: ${driver.displayName}');
          } else {
            print('⚠️ Driver item $i is not a Map: ${item.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('❌ Error parsing driver item $i: $e');
          print('   Item: ${driversData[i]}');
        }
      }

      if (page == 1) {
        drivers.assignAll(driversList);
      } else {
        drivers.addAll(driversList);
      }

      currentPage.value = currentPageNum;
      this.totalPages.value = totalPages;
      this.totalItems.value = totalItems;

      print('✅ Successfully loaded ${driversList.length} drivers');
      print('📊 Final state - Total drivers in list: ${drivers.length}');
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('❌ Error in fetchDrivers: $e');
      print('📍 Stack trace: $stackTrace');
      _showErrorSnackbar('Failed to load drivers: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreDrivers() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchDrivers(page: currentPage.value + 1);
    }
  }

  Future<void> refreshDrivers() async {
    await fetchDrivers(page: 1, isRefresh: true);
  }

  void searchDrivers(String query) {
    searchQuery.value = query;
    fetchDrivers(page: 1, isRefresh: true);
  }

  void filterDriversByStatus(String status) {
    selectedStatusFilter.value = status;
    fetchDrivers(page: 1, isRefresh: true);
  }

  Future<DriverModel?> getDriverById(String id) async {
    try {
      final driver = await DriverService.getDriverById(id);
      return driver;
    } catch (e) {
      _showErrorSnackbar('Failed to get driver: ${e.toString()}');
      return null;
    }
  }

  Future<bool> createDriver() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      await DriverService.createDriver(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
        licenseNumber: licenseNumberController.text,
        vehiclePlate: vehicleNumberController.text,
        avatar: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
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

  Future<bool> updateDriver() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      await DriverService.updateDriver(
        id: editingDriverId.value,
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        licenseNumber: licenseNumberController.text,
        vehiclePlate: vehicleNumberController.text,
        status: selectedStatus.value,
        avatar: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
      );

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

  Future<void> updateDriverLocation(
      String driverId, double latitude, double longitude) async {
    try {
      await DriverService.updateDriverLocation(
        latitude: latitude,
        longitude: longitude,
      );
      driverLocations[driverId] = {
        'latitude': latitude,
        'longitude': longitude
      };
      _showSuccessSnackbar('Driver location updated');
    } catch (e) {
      _showErrorSnackbar('Failed to update driver location: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getDriverLocation(String driverId) async {
    try {
      return await DriverService.getDriverLocation(driverId);
    } catch (e) {
      _showErrorSnackbar('Failed to get driver location: ${e.toString()}');
      return null;
    }
  }

  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      await DriverService.updateDriverStatus(
        id: driverId,
        status: status,
      );

      final driverIndex =
          drivers.indexWhere((d) => d.id.toString() == driverId);
      if (driverIndex != -1) {
        refreshDrivers();
      }

      _showSuccessSnackbar('Driver status updated to $status');
    } catch (e) {
      _showErrorSnackbar('Failed to update driver status: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getDriverOrders(
      {int page = 1, int limit = 10}) async {
    try {
      final response =
          await DriverService.getDriverOrders(page: page, limit: limit);

      if (response == null) {
        _showErrorSnackbar('No response received from server');
        return [];
      }

      final orders = response['orders'];
      if (orders is List) {
        return List<Map<String, dynamic>>.from(orders);
      } else {
        return [];
      }
    } catch (e) {
      _showErrorSnackbar('Failed to get driver orders: ${e.toString()}');
      return [];
    }
  }

  void setEditMode(DriverModel driver) {
    isEditMode.value = true;
    editingDriverId.value = driver.id.toString();
    nameController.text = driver.displayName;
    emailController.text = driver.displayEmail;
    phoneController.text = driver.displayPhone;
    licenseNumberController.text = driver.licenseNumber;
    vehicleNumberController.text = driver.vehiclePlate;
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
    licenseNumberController.clear();
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

  bool isDriverSelected(DriverModel driver) {
    return selectedDrivers.contains(driver);
  }

  int get selectedCount => selectedDrivers.length;

  List<DriverModel> get filteredDrivers {
    var filtered = drivers.where((driver) {
      if (selectedStatusFilter.value != 'all' &&
          driver.status != selectedStatusFilter.value) {
        return false;
      }

      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return driver.displayName.toLowerCase().contains(query) ||
            driver.displayEmail.toLowerCase().contains(query) ||
            driver.displayPhone.contains(query) ||
            driver.vehiclePlate.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    return filtered;
  }

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

  List<String> get statusOptions => ['active', 'inactive', 'busy'];

  List<String> get filterOptions => ['all', 'active', 'inactive', 'busy'];

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

  String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    if (value.length < 5) {
      return 'License number must be at least 5 characters';
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
      return null;
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
      return null;
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
