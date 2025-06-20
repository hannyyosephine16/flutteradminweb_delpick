import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../UserControls/StoreController.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewStoreScreen extends StatefulWidget {
  const AddNewStoreScreen({super.key});
  @override
  State<AddNewStoreScreen> createState() => _AddNewStoreScreenState();
}

class _AddNewStoreScreenState extends State<AddNewStoreScreen> {
  final StoreController storeController = Get.find<StoreController>();
  bool showPassword = false;
  Uint8List? _imageBytes;
  bool _isHoveringUpload = false;
  @override
  void initState() {
    super.initState();
// Clear form when opening add store screen
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
        );
      } else if (pickedImage == null) {
        Get.snackbar(
          'Info',
          'No image selected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Image too large, choose an image smaller than 5MB!',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add New Store',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.store_mall_directory,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add New Store',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: storeController.formKey,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
// Owner Information Section
                                  Text(
                                    'Owner Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  CustomTextField(
                                    label: "Enter owner full name",
                                    title: "Owner Name *",
                                    icon: Icons.person,
                                    controller:
                                        storeController.ownerNameController,
                                    validator:
                                        storeController.validateOwnerName,
                                  ),

                                  CustomTextField(
                                    label: "Enter owner email address",
                                    title: "Owner Email *",
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    controller:
                                        storeController.ownerEmailController,
                                    validator:
                                        storeController.validateOwnerEmail,
                                  ),

                                  CustomTextField(
                                    label: "Enter owner phone number",
                                    title: "Owner Phone *",
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    controller:
                                        storeController.ownerPhoneController,
                                    validator:
                                        storeController.validateOwnerPhone,
                                  ),

                                  CustomTextField(
                                    label:
                                        "Enter password (minimum 6 characters)",
                                    title: "Password *",
                                    icon: Icons.lock,
                                    obscureText: !showPassword,
                                    controller:
                                        storeController.ownerPasswordController,
                                    validator: storeController.validatePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Store Information Section
                                  Text(
                                    'Store Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: "Enter store name",
                                    title: "Store Name *",
                                    icon: Icons.store,
                                    controller:
                                        storeController.storeNameController,
                                    validator:
                                        storeController.validateStoreName,
                                  ),

                                  CustomTextField(
                                    label: "Enter store address",
                                    title: "Address *",
                                    icon: Icons.location_on,
                                    controller:
                                        storeController.addressController,
                                    validator: storeController.validateAddress,
                                    maxLines: 3,
                                  ),

                                  CustomTextField(
                                    label: "Enter store description (optional)",
                                    title: "Description",
                                    icon: Icons.description,
                                    controller:
                                        storeController.descriptionController,
                                    maxLines: 3,
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          label: "Tap to select time",
                                          title: "Open Time *",
                                          icon: Icons.access_time,
                                          controller: storeController
                                              .openTimeController,
                                          readOnly: true,
                                          onTap: () => _selectTime(
                                              context,
                                              storeController
                                                  .openTimeController),
                                          validator: (value) => storeController
                                              .validateCoordinate(
                                                  value, 'Open time'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: CustomTextField(
                                          label: "Tap to select time",
                                          title: "Close Time *",
                                          icon: Icons.access_time_filled,
                                          controller: storeController
                                              .closeTimeController,
                                          readOnly: true,
                                          onTap: () => _selectTime(
                                              context,
                                              storeController
                                                  .closeTimeController),
                                          validator: (value) => storeController
                                              .validateCoordinate(
                                                  value, 'Close time'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          label: "Enter latitude (-90 to 90)",
                                          title: "Latitude *",
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
                                        child: CustomTextField(
                                          label:
                                              "Enter longitude (-180 to 180)",
                                          title: "Longitude *",
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

                                  const SizedBox(height: 24),

                                  Obx(() => Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: storeController
                                                      .isFormLoading.value
                                                  ? null
                                                  : _saveStore,
                                              icon: storeController
                                                      .isFormLoading.value
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ))
                                                  : const Icon(
                                                      Icons.check_circle),
                                              label: Text(storeController
                                                      .isFormLoading.value
                                                  ? 'Adding Store...'
                                                  : 'Add Store'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: storeController
                                                      .isFormLoading.value
                                                  ? null
                                                  : () {
                                                      storeController
                                                          .clearForm();
                                                      setState(() {
                                                        _imageBytes = null;
                                                      });
                                                    },
                                              icon: const Icon(Icons.clear),
                                              label: const Text('Clear Form'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Store Image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Upload a store image (Recommended: 400×300, Max: 5MB)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  MouseRegion(
                                    onEnter: (_) => setState(
                                        () => _isHoveringUpload = true),
                                    onExit: (_) => setState(
                                        () => _isHoveringUpload = false),
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        height: 280,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: _isHoveringUpload
                                              ? Colors.grey.shade100
                                              : Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isHoveringUpload
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade300,
                                            width: 2,
                                            style: BorderStyle.dashed,
                                          ),
                                        ),
                                        child: _imageBytes != null
                                            ? Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.memory(
                                                      _imageBytes!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        onPressed: _removeImage,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 8,
                                                        horizontal: 16,
                                                      ),
                                                      child: const Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Click to change image',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
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
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .cloud_upload_rounded,
                                                      size: 36,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Drag & drop or click to upload',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'JPG, PNG or GIF (Max 5MB)',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                  if (_imageBytes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade600,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue.shade700,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Adding a clear store image helps customers identify your store and improves the user experience.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.shade700,
                                            ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
// Don't dispose controllers here since they're managed by GetX
    super.dispose();
  }
}
