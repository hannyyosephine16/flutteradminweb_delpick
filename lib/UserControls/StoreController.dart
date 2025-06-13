import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/StoreService.dart';

// StoreModel sudah ada di Models/StoreModel.dart, import dari sana
import '../Models/StoreModel.dart';

class StoreController extends GetxController {
  // Observable variables
  final stores = <StoreModel>[].obs;
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
  final selectedStores = <StoreModel>[].obs;
  final isAllSelected = false.obs;

  // Form data for add/edit
  final formKey = GlobalKey<FormState>();

  // Owner data
  final ownerNameController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final ownerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Store data
  final storeNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Form state
  final isFormLoading = false.obs;
  final isEditMode = false.obs;
  final editingStoreId = ''.obs;
  final selectedImageBase64 = ''.obs;
  final selectedStatus = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  @override
  void onClose() {
    // Dispose all controllers
    ownerNameController.dispose();
    ownerEmailController.dispose();
    ownerPhoneController.dispose();
    ownerPasswordController.dispose();
    confirmPasswordController.dispose();
    storeNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  // Fetch stores dengan pagination (SESUAI BACKEND FORMAT)
  Future<void> fetchStores({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        stores.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final response = await StoreService.getAllStores(
          page: page, limit: itemsPerPage.value);

      // Handle backend response format: {message, data: {totalItems, totalPages, currentPage, stores}}
      List<dynamic> storesData;
      if (response.containsKey('stores')) {
        storesData = response['stores'];
      } else if (response.containsKey('data') && response['data'] is List) {
        storesData = response['data'];
      } else if (response is List) {
        storesData = response;
      } else {
        storesData = [];
      }

      final storesList =
          storesData.map((json) => StoreModel.fromJson(json)).toList();

      if (page == 1) {
        stores.assignAll(storesList);
      } else {
        stores.addAll(storesList);
      }

      // Update pagination info
      currentPage.value = response['currentPage'] ?? page;
      totalPages.value = response['totalPages'] ?? 1;
      totalItems.value = response['totalItems'] ?? storesList.length;

      print('Fetched ${storesList.length} stores, total: ${totalItems.value}');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      _showErrorSnackbar('Failed to load stores: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more stores (pagination)
  Future<void> loadMoreStores() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchStores(page: currentPage.value + 1);
    }
  }

  // Refresh stores list
  Future<void> refreshStores() async {
    await fetchStores(page: 1, isRefresh: true);
  }

  // Search stores
  void searchStores(String query) {
    searchQuery.value = query;
    fetchStores(page: 1, isRefresh: true);
  }

  // Filter stores by status
  void filterStoresByStatus(String status) {
    selectedStatusFilter.value = status;
    fetchStores(page: 1, isRefresh: true);
  }

  // Get store by ID
  Future<StoreModel?> getStoreById(String id) async {
    try {
      final response = await StoreService.getStoreById(id);
      return StoreModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get store: ${e.toString()}');
      return null;
    }
  }

  // Create new store (ADMIN BISA AKSES)
  Future<bool> createStore() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final latitude = double.tryParse(latitudeController.text);
      final longitude = double.tryParse(longitudeController.text);

      if (latitude == null || longitude == null) {
        _showErrorSnackbar('Please enter valid latitude and longitude');
        return false;
      }

      await StoreService.createStore(
        ownerNameController.text, // name
        ownerEmailController.text, // email
        ownerPasswordController.text, // password
        ownerPhoneController.text, // phone
        storeNameController.text, // storeName
        addressController.text, // address
        descriptionController.text, // description
        openTimeController.text, // openTime
        closeTimeController.text, // closeTime
        latitude, // latitude
        longitude, // longitude
        selectedImageBase64.value.isNotEmpty ? selectedImageBase64.value : null,
      );

      _showSuccessSnackbar('Store created successfully');
      clearForm();
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to create store: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Update store (ADMIN BISA AKSES)
  Future<bool> updateStore() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final latitude = double.tryParse(latitudeController.text);
      final longitude = double.tryParse(longitudeController.text);

      final Map<String, dynamic> updateData = {
        // Owner data
        'name': ownerNameController.text,
        'email': ownerEmailController.text,
        'phone': ownerPhoneController.text,

        // Store data
        'storeName': storeNameController.text,
        'address': addressController.text,
        'description': descriptionController.text,
        'openTime': openTimeController.text,
        'closeTime': closeTimeController.text,
        'status': selectedStatus.value,
      };

      if (ownerPasswordController.text.isNotEmpty) {
        updateData['password'] = ownerPasswordController.text;
      }

      if (latitude != null && longitude != null) {
        updateData['latitude'] = latitude;
        updateData['longitude'] = longitude;
      }

      if (selectedImageBase64.value.isNotEmpty) {
        updateData['image'] = selectedImageBase64.value;
      }

      await StoreService.updateStore(editingStoreId.value, updateData);

      _showSuccessSnackbar('Store updated successfully');
      clearForm();
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update store: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Delete store (ADMIN BISA AKSES)
  Future<bool> deleteStore(String id) async {
    try {
      await StoreService.deleteStore(id);
      _showSuccessSnackbar('Store deleted successfully');
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete store: ${e.toString()}');
      return false;
    }
  }

  // Delete multiple stores
  Future<bool> deleteMultipleStores() async {
    if (selectedStores.isEmpty) {
      _showErrorSnackbar('No stores selected');
      return false;
    }

    try {
      for (final store in selectedStores) {
        await StoreService.deleteStore(store.id.toString());
      }

      _showSuccessSnackbar(
          '${selectedStores.length} stores deleted successfully');
      clearSelection();
      refreshStores();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete stores: ${e.toString()}');
      return false;
    }
  }

  // Update store status (ADMIN BISA AKSES)
  Future<void> updateStoreStatus(String storeId, String status) async {
    try {
      await StoreService.updateStoreStatus(storeId, status);

      // Update local store status
      final storeIndex = stores.indexWhere((s) => s.id.toString() == storeId);
      if (storeIndex != -1) {
        // Refresh data to get updated store
        refreshStores();
      }

      _showSuccessSnackbar('Store status updated to $status');
    } catch (e) {
      _showErrorSnackbar('Failed to update store status: ${e.toString()}');
    }
  }

  // Form management
  void setEditMode(StoreModel store) {
    isEditMode.value = true;
    editingStoreId.value = store.id.toString();

    // Owner data
    ownerNameController.text = store.ownerName;
    ownerEmailController.text = store.ownerEmail;
    ownerPhoneController.text = store.ownerPhone;
    ownerPasswordController.clear();
    confirmPasswordController.clear();

    // Store data
    storeNameController.text = store.name;
    addressController.text = store.address;
    descriptionController.text = store.description ?? '';
    openTimeController.text = store.openTime ?? '';
    closeTimeController.text = store.closeTime ?? '';
    latitudeController.text = store.latitude?.toString() ?? '';
    longitudeController.text = store.longitude?.toString() ?? '';
    selectedStatus.value = store.status;
    selectedImageBase64.value = store.imageUrl ?? '';
  }

  void clearForm() {
    isEditMode.value = false;
    editingStoreId.value = '';

    // Clear owner data
    ownerNameController.clear();
    ownerEmailController.clear();
    ownerPhoneController.clear();
    ownerPasswordController.clear();
    confirmPasswordController.clear();

    // Clear store data
    storeNameController.clear();
    addressController.clear();
    descriptionController.clear();
    openTimeController.clear();
    closeTimeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    selectedStatus.value = 'active';
    selectedImageBase64.value = '';
  }

  void setSelectedImage(String base64Image) {
    selectedImageBase64.value = base64Image;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  // Selection management
  void toggleStoreSelection(StoreModel store) {
    if (selectedStores.contains(store)) {
      selectedStores.remove(store);
    } else {
      selectedStores.add(store);
    }
    _updateSelectAllState();
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      selectedStores.clear();
    } else {
      selectedStores.assignAll(stores);
    }
    _updateSelectAllState();
  }

  void clearSelection() {
    selectedStores.clear();
    isAllSelected.value = false;
  }

  void _updateSelectAllState() {
    isAllSelected.value =
        stores.isNotEmpty && selectedStores.length == stores.length;
  }

  // Utility methods
  bool isStoreSelected(StoreModel store) {
    return selectedStores.contains(store);
  }

  int get selectedCount => selectedStores.length;

  List<StoreModel> get filteredStores {
    var filtered = stores.where((store) {
      // Status filter
      if (selectedStatusFilter.value != 'all' &&
          store.status != selectedStatusFilter.value) {
        return false;
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return store.name.toLowerCase().contains(query) ||
            store.address.toLowerCase().contains(query) ||
            store.ownerName.toLowerCase().contains(query) ||
            (store.description?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    return filtered;
  }

  // Statistics
  int get totalStoresCount => totalItems.value;
  int get activeStoresCount => stores.where((s) => s.isActive).length;
  int get inactiveStoresCount => stores.where((s) => s.isInactive).length;

  double get averageRating => stores.isEmpty
      ? 0.0
      : stores.fold(0.0, (sum, store) => sum + store.rating) / stores.length;

  String get averageRatingDisplay => averageRating.toStringAsFixed(1);

  // Status options for dropdown
  List<String> get statusOptions => ['active', 'inactive'];

  // Filter options
  List<String> get filterOptions => ['all', 'active', 'inactive'];

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
  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner name is required';
    }
    if (value.length < 2) {
      return 'Owner name must be at least 2 characters';
    }
    return null;
  }

  String? validateOwnerEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateOwnerPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner phone is required';
    }
    if (value.length < 10) {
      return 'Phone must be at least 10 digits';
    }
    return null;
  }

  String? validateStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Store name is required';
    }
    if (value.length < 2) {
      return 'Store name must be at least 2 characters';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  String? validateCoordinate(String? value, String coordinateName) {
    if (value == null || value.isEmpty) {
      return '$coordinateName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid $coordinateName';
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
    if (isEditMode.value && ownerPasswordController.text.isEmpty) {
      return null; // Skip validation if password is not being updated
    }
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != ownerPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
