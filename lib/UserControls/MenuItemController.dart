import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/MenuItemService.dart';

// Simplified MenuItemModel for controller usage
class MenuItemModel {
  final int id;
  final String name;
  final int price;
  final String? description;
  final String? imageUrl;
  final int storeId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StoreInfo? store;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.storeId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.store,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      storeId: json['storeId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      store: json['store'] != null ? StoreInfo.fromJson(json['store']) : null,
    );
  }

  String get priceDisplay => 'Rp ${price.toStringAsFixed(0)}';
  String get storeName => store?.name ?? 'Unknown Store';
  bool get isAvailable => quantity > 0;
  bool get isOutOfStock => quantity == 0;
  String get stockStatus {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= 10) return 'Low Stock';
    return 'In Stock';
  }
}

class StoreInfo {
  final int id;
  final String name;
  final String? address;

  StoreInfo({
    required this.id,
    required this.name,
    this.address,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
    );
  }
}

class MenuItemController extends GetxController {
  // Observable variables
  final menuItems = <MenuItemModel>[].obs;
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
  final selectedStoreFilter = 'all'.obs;
  final selectedStockFilter = 'all'.obs;

  // Selection
  final selectedMenuItems = <MenuItemModel>[].obs;
  final isAllSelected = false.obs;

  // Form data for add/edit
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  // Form state
  final isFormLoading = false.obs;
  final isEditMode = false.obs;
  final editingMenuItemId = ''.obs;
  final selectedImageBase64 = ''.obs;
  final selectedStoreId = ''.obs;

  // Store options for dropdown
  final storeOptions = <Map<String, dynamic>>[].obs;
  final isLoadingStores = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
    loadStoreOptions();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.onClose();
  }

  // Fetch menu items with pagination
  Future<void> fetchMenuItems({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh || page == 1) {
        isLoading.value = true;
        menuItems.clear();
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final response = await MenuItemService.getAllMenuItems(
          page: page, limit: itemsPerPage.value);

      // Handle backend response format
      List<dynamic> menuItemsData;
      if (response.containsKey('menuItems')) {
        menuItemsData = response['menuItems'];
      } else if (response.containsKey('data') && response['data'] is List) {
        menuItemsData = response['data'];
      } else if (response is List) {
        menuItemsData = response;
      } else {
        menuItemsData = [];
      }

      final menuItemsList =
          menuItemsData.map((json) => MenuItemModel.fromJson(json)).toList();

      if (page == 1) {
        menuItems.assignAll(menuItemsList);
      } else {
        menuItems.addAll(menuItemsList);
      }

      // Update pagination info
      currentPage.value = response['currentPage'] ?? page;
      totalPages.value = response['totalPages'] ?? 1;
      totalItems.value = response['totalItems'] ?? menuItemsList.length;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      _showErrorSnackbar('Failed to load menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load more menu items (pagination)
  Future<void> loadMoreMenuItems() async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchMenuItems(page: currentPage.value + 1);
    }
  }

  // Refresh menu items list
  Future<void> refreshMenuItems() async {
    await fetchMenuItems(page: 1, isRefresh: true);
  }

  // Search menu items
  void searchMenuItems(String query) {
    searchQuery.value = query;
    fetchMenuItems(page: 1, isRefresh: true);
  }

  // Filter menu items by store
  void filterMenuItemsByStore(String storeId) {
    selectedStoreFilter.value = storeId;
    if (storeId != 'all') {
      fetchMenuItemsByStore(storeId);
    } else {
      fetchMenuItems(page: 1, isRefresh: true);
    }
  }

  // Filter menu items by stock status
  void filterMenuItemsByStock(String stockFilter) {
    selectedStockFilter.value = stockFilter;
    fetchMenuItems(page: 1, isRefresh: true);
  }

  // Get menu items by store ID
  Future<void> fetchMenuItemsByStore(String storeId, {int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await MenuItemService.getMenuItemsByStoreId(storeId,
          page: page, limit: itemsPerPage.value);

      final menuItemsData = response['menuItems'] ?? response['data'] ?? [];
      final menuItemsList = (menuItemsData as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();

      menuItems.assignAll(menuItemsList);

      // Update pagination info
      currentPage.value = response['currentPage'] ?? page;
      totalPages.value = response['totalPages'] ?? 1;
      totalItems.value = response['totalItems'] ?? menuItemsList.length;
    } catch (e) {
      _showErrorSnackbar('Failed to load store menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get menu item by ID
  Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final response = await MenuItemService.getMenuItemById(id);
      return MenuItemModel.fromJson(response);
    } catch (e) {
      _showErrorSnackbar('Failed to get menu item: ${e.toString()}');
      return null;
    }
  }

  // Create new menu item
  Future<bool> createMenuItem() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedStoreId.value.isEmpty) {
      _showErrorSnackbar('Please select a store');
      return false;
    }

    try {
      isFormLoading.value = true;

      final price = double.tryParse(priceController.text) ?? 0.0;
      final quantity = int.tryParse(quantityController.text) ?? 0;

      await MenuItemService.createMenuItemWithImage(
        name: nameController.text,
        price: price,
        description: descriptionController.text,
        quantity: quantity,
        imageBase64: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
      );

      _showSuccessSnackbar('Menu item created successfully');
      clearForm();
      refreshMenuItems();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to create menu item: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Update menu item
  Future<bool> updateMenuItem() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    try {
      isFormLoading.value = true;

      final price = double.tryParse(priceController.text);
      final quantity = int.tryParse(quantityController.text);

      await MenuItemService.updateMenuItemWithImage(
        id: editingMenuItemId.value,
        name: nameController.text.isNotEmpty ? nameController.text : null,
        price: price,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        quantity: quantity,
        imageBase64: selectedImageBase64.value.isNotEmpty
            ? selectedImageBase64.value
            : null,
      );

      _showSuccessSnackbar('Menu item updated successfully');
      clearForm();
      refreshMenuItems();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to update menu item: ${e.toString()}');
      return false;
    } finally {
      isFormLoading.value = false;
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String id) async {
    try {
      await MenuItemService.deleteMenuItem(id);
      _showSuccessSnackbar('Menu item deleted successfully');
      refreshMenuItems();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete menu item: ${e.toString()}');
      return false;
    }
  }

  // Delete multiple menu items
  Future<bool> deleteMultipleMenuItems() async {
    if (selectedMenuItems.isEmpty) {
      _showErrorSnackbar('No menu items selected');
      return false;
    }

    try {
      for (final menuItem in selectedMenuItems) {
        await MenuItemService.deleteMenuItem(menuItem.id.toString());
      }

      _showSuccessSnackbar(
          '${selectedMenuItems.length} menu items deleted successfully');
      clearSelection();
      refreshMenuItems();
      return true;
    } catch (e) {
      _showErrorSnackbar('Failed to delete menu items: ${e.toString()}');
      return false;
    }
  }

  // Search menu items by query
  Future<void> searchMenuItemsApi(String query) async {
    try {
      isLoading.value = true;
      final response = await MenuItemService.searchMenuItems(query,
          page: 1, limit: itemsPerPage.value);

      final menuItemsData = response['menuItems'] ?? response['data'] ?? [];
      final menuItemsList = (menuItemsData as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();

      menuItems.assignAll(menuItemsList);
    } catch (e) {
      _showErrorSnackbar('Failed to search menu items: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load store options for dropdown
  Future<void> loadStoreOptions() async {
    try {
      isLoadingStores.value = true;
      // This would need to be implemented with a StoreService call
      // For now, we'll use a placeholder
      storeOptions.assignAll([
        {'id': '1', 'name': 'Store 1'},
        {'id': '2', 'name': 'Store 2'},
        // Add more stores as needed
      ]);
    } catch (e) {
      _showErrorSnackbar('Failed to load stores: ${e.toString()}');
    } finally {
      isLoadingStores.value = false;
    }
  }

  // Form management
  void setEditMode(MenuItemModel menuItem) {
    isEditMode.value = true;
    editingMenuItemId.value = menuItem.id.toString();
    nameController.text = menuItem.name;
    descriptionController.text = menuItem.description ?? '';
    priceController.text = menuItem.price.toString();
    quantityController.text = menuItem.quantity.toString();
    selectedStoreId.value = menuItem.storeId.toString();
    selectedImageBase64.value = menuItem.imageUrl ?? '';
  }

  void clearForm() {
    isEditMode.value = false;
    editingMenuItemId.value = '';
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    selectedStoreId.value = '';
    selectedImageBase64.value = '';
  }

  void setSelectedImage(String base64Image) {
    selectedImageBase64.value = base64Image;
  }

  void setSelectedStore(String storeId) {
    selectedStoreId.value = storeId;
  }

  // Selection management
  void toggleMenuItemSelection(MenuItemModel menuItem) {
    if (selectedMenuItems.contains(menuItem)) {
      selectedMenuItems.remove(menuItem);
    } else {
      selectedMenuItems.add(menuItem);
    }
    _updateSelectAllState();
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      selectedMenuItems.clear();
    } else {
      selectedMenuItems.assignAll(menuItems);
    }
    _updateSelectAllState();
  }

  void clearSelection() {
    selectedMenuItems.clear();
    isAllSelected.value = false;
  }

  void _updateSelectAllState() {
    isAllSelected.value =
        menuItems.isNotEmpty && selectedMenuItems.length == menuItems.length;
  }

  // Utility methods
  bool isMenuItemSelected(MenuItemModel menuItem) {
    return selectedMenuItems.contains(menuItem);
  }

  int get selectedCount => selectedMenuItems.length;

  List<MenuItemModel> get filteredMenuItems {
    var filtered = menuItems.where((menuItem) {
      // Store filter
      if (selectedStoreFilter.value != 'all' &&
          menuItem.storeId.toString() != selectedStoreFilter.value) {
        return false;
      }

      // Stock filter
      if (selectedStockFilter.value != 'all') {
        switch (selectedStockFilter.value) {
          case 'in_stock':
            if (!menuItem.isAvailable) return false;
            break;
          case 'out_of_stock':
            if (menuItem.isAvailable) return false;
            break;
          case 'low_stock':
            if (menuItem.quantity > 10) return false;
            break;
        }
      }

      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        return menuItem.name.toLowerCase().contains(query) ||
            (menuItem.description?.toLowerCase().contains(query) ?? false) ||
            menuItem.storeName.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    return filtered;
  }

  // Statistics
  int get totalMenuItemsCount => totalItems.value;
  int get availableItemsCount =>
      menuItems.where((item) => item.isAvailable).length;
  int get outOfStockItemsCount =>
      menuItems.where((item) => item.isOutOfStock).length;
  int get lowStockItemsCount => menuItems
      .where((item) => item.quantity <= 10 && item.quantity > 0)
      .length;

  double get averagePrice => menuItems.isEmpty
      ? 0.0
      : menuItems.fold(0.0, (sum, item) => sum + item.price) / menuItems.length;

  int get totalStockQuantity =>
      menuItems.fold(0, (sum, item) => sum + item.quantity);

  String get averagePriceDisplay => 'Rp ${averagePrice.toStringAsFixed(0)}';

  // Filter options
  List<String> get stockFilterOptions =>
      ['all', 'in_stock', 'out_of_stock', 'low_stock'];

  // Helper methods for stock status colors
  Color getStockStatusColor(MenuItemModel menuItem) {
    if (menuItem.isOutOfStock) return Colors.red;
    if (menuItem.quantity <= 10) return Colors.orange;
    return Colors.green;
  }

  String getStockStatusText(MenuItemModel menuItem) {
    if (menuItem.isOutOfStock) return 'Out of Stock';
    if (menuItem.quantity <= 10) return 'Low Stock';
    return 'In Stock';
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

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid quantity';
    }
    if (quantity < 0) {
      return 'Quantity cannot be negative';
    }
    return null;
  }

  String? validateDescription(String? value) {
    // Description is optional, but if provided should have some minimum length
    if (value != null && value.isNotEmpty && value.length < 10) {
      return 'Description should be at least 10 characters';
    }
    return null;
  }
}
