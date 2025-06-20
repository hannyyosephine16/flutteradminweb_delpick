import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../UserControls/StoreController.dart';

class AddNewStoreScreen extends StatefulWidget {
  const AddNewStoreScreen({super.key});

  @override
  State<AddNewStoreScreen> createState() => _AddNewStoreScreenState();
}

class _AddNewStoreScreenState extends State<AddNewStoreScreen> {
  final StoreController storeController = Get.find<StoreController>();
  bool showPassword = false;
  bool showConfirmPassword = false;
  Uint8List? _imageBytes;
  bool _isHoveringUpload = false;

  @override
  void initState() {
    super.initState();
    storeController.clearForm();
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) {
        final base64String = base64Encode(pickedImage);
        final imageBase64WithPrefix = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _imageBytes = pickedImage;
        });

        storeController.setSelectedImage(imageBase64WithPrefix);

        Get.snackbar(
          'Success',
          'Image selected successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else if (pickedImage == null) {
        Get.snackbar(
          'Info',
          'No image selected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Image too large. Please choose an image smaller than 5MB!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
    });
    storeController.setSelectedImage('');
  }

  Future<void> _saveStore() async {
    if (!storeController.formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await storeController.createStore();
    if (success) {
      setState(() {
        _imageBytes = null;
      });
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add New Store',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.store_mall_directory,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create New Store',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Add a new store to your platform',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Content
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: storeController.formKey,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column - Form Fields
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Owner Information Section
                                  _buildSectionHeader('Owner Information',
                                      Icons.person_outline),
                                  const SizedBox(height: 20),

                                  _buildCustomTextField(
                                    label: "Enter owner full name",
                                    title: "Owner Name",
                                    icon: Icons.person,
                                    controller:
                                        storeController.ownerNameController,
                                    validator:
                                        storeController.validateOwnerName,
                                  ),

                                  _buildCustomTextField(
                                    label: "Enter owner email address",
                                    title: "Owner Email",
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    controller:
                                        storeController.ownerEmailController,
                                    validator:
                                        storeController.validateOwnerEmail,
                                  ),

                                  _buildCustomTextField(
                                    label: "Enter owner phone number",
                                    title: "Owner Phone",
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    controller:
                                        storeController.ownerPhoneController,
                                    validator:
                                        storeController.validateOwnerPhone,
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label:
                                              "Enter password (minimum 6 characters)",
                                          title: "Password",
                                          icon: Icons.lock,
                                          obscureText: true,
                                          controller: storeController
                                              .ownerPasswordController,
                                          validator:
                                              storeController.validatePassword,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label: "Confirm your password",
                                          title: "Confirm Password",
                                          icon: Icons.lock_outline,
                                          obscureText: true,
                                          controller: storeController
                                              .confirmPasswordController,
                                          validator: storeController
                                              .validateConfirmPassword,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 32),

                                  // Store Information Section
                                  _buildSectionHeader('Store Information',
                                      Icons.store_outlined),
                                  const SizedBox(height: 20),

                                  _buildCustomTextField(
                                    label: "Enter store name",
                                    title: "Store Name",
                                    icon: Icons.store,
                                    controller:
                                        storeController.storeNameController,
                                    validator:
                                        storeController.validateStoreName,
                                  ),

                                  _buildCustomTextField(
                                    label: "Enter complete store address",
                                    title: "Address",
                                    icon: Icons.location_on,
                                    controller:
                                        storeController.addressController,
                                    validator: storeController.validateAddress,
                                    maxLines: 3,
                                    height: 90,
                                  ),

                                  _buildCustomTextField(
                                    label: "Enter store description (optional)",
                                    title: "Description",
                                    icon: Icons.description,
                                    controller:
                                        storeController.descriptionController,
                                    maxLines: 3,
                                    height: 90,
                                    isRequired: false,
                                  ),

                                  // Operating Hours
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label: "Tap to select opening time",
                                          title: "Open Time",
                                          icon: Icons.access_time,
                                          controller: storeController
                                              .openTimeController,
                                          readOnly: true,
                                          onTap: () => _selectTime(
                                              context,
                                              storeController
                                                  .openTimeController),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Open time is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label: "Tap to select closing time",
                                          title: "Close Time",
                                          icon: Icons.access_time_filled,
                                          controller: storeController
                                              .closeTimeController,
                                          readOnly: true,
                                          onTap: () => _selectTime(
                                              context,
                                              storeController
                                                  .closeTimeController),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Close time is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Location Coordinates
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label: "Enter latitude (-90 to 90)",
                                          title: "Latitude",
                                          icon: Icons.gps_fixed,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          controller: storeController
                                              .latitudeController,
                                          validator: (value) => storeController
                                              .validateCoordinate(
                                                  value, 'Latitude'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildCustomTextField(
                                          label:
                                              "Enter longitude (-180 to 180)",
                                          title: "Longitude",
                                          icon: Icons.gps_fixed,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          controller: storeController
                                              .longitudeController,
                                          validator: (value) => storeController
                                              .validateCoordinate(
                                                  value, 'Longitude'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 48),

                            // Right Column - Image Upload
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      'Store Image', Icons.image_outlined),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload a clear store image to help customers identify your store',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Image Upload Area
                                  MouseRegion(
                                    onEnter: (_) => setState(
                                        () => _isHoveringUpload = true),
                                    onExit: (_) => setState(
                                        () => _isHoveringUpload = false),
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        height: 320,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: _isHoveringUpload
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.05)
                                              : Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: _isHoveringUpload
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade300,
                                            width: _isHoveringUpload ? 2 : 1,
                                          ),
                                        ),
                                        child: _imageBytes != null
                                            ? Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: Image.memory(
                                                      _imageBytes!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 12,
                                                    right: 12,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade500,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        onPressed: _removeImage,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        constraints:
                                                            const BoxConstraints(
                                                          minWidth: 40,
                                                          minHeight: 40,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.8),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 16,
                                                        horizontal: 20,
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.edit_outlined,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Click to change image',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      size: 48,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    'Drag & drop or click to upload',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Recommended: 400×300 pixels',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'JPG, PNG or GIF (Max 5MB)',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),

                                  // Image Status Info
                                  if (_imageBytes != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green.shade600,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 24),

                                  // Help Box
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.blue.shade600,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tips for great store images:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '• Use clear, well-lit photos\n• Show your store front or logo\n• Avoid blurry or dark images\n• Square or landscape format works best',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue.shade600,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Obx(() => Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: storeController.isFormLoading.value
                                      ? null
                                      : () {
                                          storeController.clearForm();
                                          setState(() {
                                            _imageBytes = null;
                                            showPassword = false;
                                            showConfirmPassword = false;
                                          });
                                        },
                                  icon: const Icon(Icons.refresh_outlined),
                                  label: const Text('Clear Form'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: storeController.isFormLoading.value
                                      ? null
                                      : _saveStore,
                                  icon: storeController.isFormLoading.value
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add_business_outlined),
                                  label: Text(
                                    storeController.isFormLoading.value
                                        ? 'Creating Store...'
                                        : 'Create Store',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required String title,
    IconData? icon,
    IconData? icon2,
    double? height,
    bool obscureText = false,
    TextEditingController? controller,
    void Function(String)? onChanged,
    int? maxLines,
    FocusNode? focusNode,
    String? errorText,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: height ?? 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              focusNode: focusNode,
              obscureText: obscureText,
              maxLines: maxLines ?? 1,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              validator: validator,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                hintText: label,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: icon != null
                    ? Icon(
                        icon,
                        color: Colors.grey.shade500,
                        size: 20,
                      )
                    : null,
                suffixIcon: icon2 != null
                    ? Icon(
                        icon2,
                        color: Colors.grey.shade500,
                        size: 20,
                      )
                    : null,
              ),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
