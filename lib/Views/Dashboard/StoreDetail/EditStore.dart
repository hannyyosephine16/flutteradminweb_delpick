import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Common/GlobalStyle.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';
import '../../../UserControls/StoreController.dart';
import '../../../Models/StoreModel.dart';

class EditStoreScreen extends StatefulWidget {
  final StoreModel? store;
  final String? storeId;

  const EditStoreScreen({
    super.key,
    this.store,
    this.storeId,
  });

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen>
    with TickerProviderStateMixin {
  final StoreController _storeController = Get.find<StoreController>();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedImageBase64;
  bool _isLoading = false;

  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _initializeForm();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    print('🔧 Initializing form...');

    if (widget.store != null) {
      print('✅ Using passed store: ${widget.store!.name}');
      _populateFormFromStore(widget.store!);
    } else if (widget.storeId != null) {
      print('🔍 Loading store by ID: ${widget.storeId}');
      _loadStoreById(widget.storeId!);
    } else {
      print('➕ Creating new store');
      _storeController.clearForm();
      _storeController.isEditMode.value = false;
    }
  }

  void _populateFormFromStore(StoreModel store) {
    print('📝 Populating form with store data: ${store.name}');

    // ✅ FIXED: Set edit mode and store ID properly
    _storeController.isEditMode.value = true;
    _storeController.editingStoreId.value = store.id.toString();

    // ✅ FIXED: Populate owner data with proper null handling
    _storeController.ownerNameController.text = store.ownerName ?? '';
    _storeController.ownerEmailController.text = store.ownerEmail ?? '';
    _storeController.ownerPhoneController.text =
        store.ownerPhone.isNotEmpty ? store.ownerPhone : (store.phone ?? '');

    // ✅ FIXED: Clear password fields in edit mode
    _storeController.ownerPasswordController.clear();
    _storeController.confirmPasswordController.clear();

    // ✅ Store data population with null safety
    _storeController.storeNameController.text = store.name ?? '';
    _storeController.addressController.text = store.address ?? '';
    _storeController.descriptionController.text = store.description ?? '';
    _storeController.openTimeController.text = store.openTime ?? '';
    _storeController.closeTimeController.text = store.closeTime ?? '';
    _storeController.latitudeController.text =
        (store.latitude ?? 0.0).toString();
    _storeController.longitudeController.text =
        (store.longitude ?? 0.0).toString();

    // ✅ FIXED: Set status properly with null check
    _storeController.selectedStatus.value = store.status ?? 'active';

    // ✅ FIXED: Handle existing image with null safety
    if (store.hasImage && store.imageUrl != null) {
      _selectedImageBase64 = store.fullImageUrl;
      _storeController.selectedImageBase64.value =
          ''; // Don't send existing image unless changed
    } else {
      _selectedImageBase64 = null;
      _storeController.selectedImageBase64.value = '';
    }

    print('✅ Form populated successfully');
    print('   - Store ID: ${_storeController.editingStoreId.value}');
    print('   - Edit Mode: ${_storeController.isEditMode.value}');
    print('   - Store Name: ${_storeController.storeNameController.text}');
    print('   - Owner Name: ${_storeController.ownerNameController.text}');
    print('   - Status: ${_storeController.selectedStatus.value}');
  }

  Future<void> _loadStoreById(String storeId) async {
    setState(() => _isLoading = true);
    try {
      print('🔍 Loading store by ID: $storeId');
      final store = await _storeController.getStoreById(storeId);
      if (store != null) {
        print('✅ Store loaded: ${store.name}');
        _populateFormFromStore(store);
      } else {
        print('❌ Store not found');
        _showErrorMessage('Store not found');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error loading store: $e');
      _showErrorMessage('Failed to load store: $e');
      Navigator.of(context).pop();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) return;

        final file = files[0];

        if (file.size > 5 * 1024 * 1024) {
          _showErrorMessage('Image size must be less than 5MB');
          return;
        }

        if (!file.type.startsWith('image/')) {
          _showErrorMessage('Please select a valid image file');
          return;
        }

        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final imageUrl = reader.result as String;
          setState(() {
            _selectedImageBase64 = imageUrl;
          });
          // ✅ FIXED: Set the base64 image for upload
          _storeController.setSelectedImage(imageUrl);
        });
      });
    } catch (e) {
      _showErrorMessage('Failed to select image: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print('📤 Submitting form...');
    print('   - Edit Mode: ${_storeController.isEditMode.value}');
    print('   - Store ID: ${_storeController.editingStoreId.value}');
    print('   - Store Name: ${_storeController.storeNameController.text}');
    print('   - Owner Name: ${_storeController.ownerNameController.text}');
    print('   - Status: ${_storeController.selectedStatus.value}');

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_storeController.isEditMode.value) {
        print('✏️ Updating store...');
        success = await _storeController.updateStore();
      } else {
        print('➕ Creating store...');
        success = await _storeController.createStore();
      }

      if (success) {
        print('✅ Operation successful');
        _showSuccessMessage(_storeController.isEditMode.value
            ? 'Store updated successfully'
            : 'Store created successfully');

        // ✅ FIXED: Delay to show success message before navigating
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pop(true);
      } else {
        print('❌ Operation failed');
        _showErrorMessage('Operation failed');
      }
    } catch (e) {
      print('❌ Form submission error: $e');
      _showErrorMessage('Operation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null
                  ? Icon(icon, color: GlobalStyle.buttonColor)
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: GlobalStyle.buttonColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GlobalStyle.buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: GlobalStyle.buttonColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GlobalStyle.buttonColor.withOpacity(0.3),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: GlobalStyle.buttonColor),
              const SizedBox(width: 8),
              const Text(
                'Store Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended: 400x300 pixels',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImageBase64 != null
                    ? GlobalStyle.buttonColor.withOpacity(0.3)
                    : Colors.grey.shade300,
                width: 2,
              ),
              color: Colors.grey.shade50,
            ),
            child: _selectedImageBase64 != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _selectedImageBase64!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image loading failed',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageBase64 = null;
                            });
                            _storeController.setSelectedImage('');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GlobalStyle.buttonColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: GlobalStyle.buttonColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload Store Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PNG, JPG up to 5MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectImage,
              icon: Icon(
                  _selectedImageBase64 != null ? Icons.refresh : Icons.upload),
              label: Text(_selectedImageBase64 != null
                  ? 'Change Image'
                  : 'Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: GlobalStyle.buttonColor,
                side: BorderSide(color: GlobalStyle.buttonColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Obx(() => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlobalStyle.buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _storeController.isEditMode.value
                        ? Icons.edit
                        : Icons.add_business,
                    color: GlobalStyle.buttonColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _storeController.isEditMode.value
                      ? 'Edit Store'
                      : 'Add New Store',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: GlobalStyle.buttonColor),
                  const SizedBox(height: 16),
                  Text(
                    _storeController.isEditMode.value
                        ? 'Updating store...'
                        : 'Loading store data...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section - Form Fields
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Owner Information Section
                                _buildSectionHeader(
                                    'Owner Information', Icons.person),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.ownerNameController,
                                  label: "Owner Name",
                                  hint: "Enter owner full name",
                                  icon: Icons.person_outline,
                                  validator: _storeController.validateOwnerName,
                                ),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.ownerEmailController,
                                  label: "Owner Email",
                                  hint: "owner@example.com",
                                  icon: Icons.email_outlined,
                                  validator:
                                      _storeController.validateOwnerEmail,
                                ),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.ownerPhoneController,
                                  label: "Owner Phone",
                                  hint: "+62 812 3456 7890",
                                  icon: Icons.phone_outlined,
                                  validator:
                                      _storeController.validateOwnerPhone,
                                ),

                                // Password fields (only show in create mode)
                                Obx(
                                  () => !_storeController.isEditMode.value
                                      ? Column(
                                          children: [
                                            _buildStyledTextField(
                                              controller: _storeController
                                                  .ownerPasswordController,
                                              label: "Password",
                                              hint: "Enter secure password",
                                              icon: Icons.lock_outline,
                                              obscureText: true,
                                              validator: _storeController
                                                  .validatePassword,
                                            ),
                                            _buildStyledTextField(
                                              controller: _storeController
                                                  .confirmPasswordController,
                                              label: "Confirm Password",
                                              hint: "Re-enter password",
                                              icon: Icons.lock_outline,
                                              obscureText: true,
                                              validator: _storeController
                                                  .validateConfirmPassword,
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 32),

                                // Store Information Section
                                _buildSectionHeader(
                                    'Store Information', Icons.store),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.storeNameController,
                                  label: "Store Name",
                                  hint: "Enter store name",
                                  icon: Icons.storefront,
                                  validator: _storeController.validateStoreName,
                                ),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.addressController,
                                  label: "Store Address",
                                  hint: "Enter complete address",
                                  icon: Icons.location_on_outlined,
                                  maxLines: 3,
                                  validator: _storeController.validateAddress,
                                ),

                                _buildStyledTextField(
                                  controller:
                                      _storeController.descriptionController,
                                  label: "Description (Optional)",
                                  hint: "Describe your store...",
                                  icon: Icons.description_outlined,
                                  maxLines: 3,
                                ),

                                // Operating Hours
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStyledTextField(
                                        controller:
                                            _storeController.openTimeController,
                                        label: "Opening Time",
                                        hint: "08:00",
                                        icon: Icons.access_time,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildStyledTextField(
                                        controller: _storeController
                                            .closeTimeController,
                                        label: "Closing Time",
                                        hint: "22:00",
                                        icon: Icons.access_time,
                                      ),
                                    ),
                                  ],
                                ),

                                // Location Coordinates
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStyledTextField(
                                        controller:
                                            _storeController.latitudeController,
                                        label: "Latitude",
                                        hint: "e.g. -6.2088",
                                        icon: Icons.my_location,
                                        validator: (value) =>
                                            _storeController.validateCoordinate(
                                                value, 'Latitude'),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildStyledTextField(
                                        controller: _storeController
                                            .longitudeController,
                                        label: "Longitude",
                                        hint: "e.g. 106.8456",
                                        icon: Icons.place,
                                        validator: (value) =>
                                            _storeController.validateCoordinate(
                                                value, 'Longitude'),
                                      ),
                                    ),
                                  ],
                                ),

                                // Status dropdown (only in edit mode)
                                Obx(
                                  () => _storeController.isEditMode.value
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Store Status',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _storeController
                                                        .selectedStatus.value,
                                                    isExpanded: true,
                                                    items: _statusOptions
                                                        .map((String status) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: status,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 8,
                                                              height: 8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: status ==
                                                                        'active'
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .orange,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(status
                                                                .toUpperCase()),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        _storeController
                                                            .setSelectedStatus(
                                                                value);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 32),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: Obx(() => Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              GlobalStyle.buttonColor,
                                              GlobalStyle.buttonColor
                                                  .withOpacity(0.8),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: GlobalStyle.buttonColor
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _storeController
                                                  .isFormLoading.value
                                              ? null
                                              : _submitForm,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: _storeController
                                                  .isFormLoading.value
                                              ? const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Processing...',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      _storeController
                                                              .isEditMode.value
                                                          ? Icons.save
                                                          : Icons.add_business,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _storeController
                                                              .isEditMode.value
                                                          ? 'Update Store'
                                                          : 'Create Store',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),

                        // Right Section - Image Upload
                        Expanded(
                          flex: 1,
                          child: _buildImageSection(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
