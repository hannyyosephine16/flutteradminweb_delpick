import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../src/StoreService.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewStoreScreen extends StatefulWidget {
  const AddNewStoreScreen({super.key});
  @override
  State<AddNewStoreScreen> createState() => _AddNewStoreScreenState();
}

class _AddNewStoreScreenState extends State<AddNewStoreScreen> {
  // Owner data controllers
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerPasswordController = TextEditingController();

  // Store data controllers
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController openTimeController = TextEditingController();
  final TextEditingController closeTimeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isHoveringUpload = false;

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });
    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();

      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) {
        final base64String = base64Encode(pickedImage);
        final imageBase64WithPrefix = 'data:image/jpeg;base64,' + base64String;

        setState(() {
          _imageBytes = pickedImage;
          _imageBase64 = imageBase64WithPrefix;
        });

        print('Image successfully converted to base64 with prefix');
      } else if (pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Image too large, choose an image smaller than 5MB!')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveStore() async {
    if (ownerNameController.text.isEmpty ||
        ownerEmailController.text.isEmpty ||
        ownerPhoneController.text.isEmpty ||
        ownerPasswordController.text.isEmpty ||
        storeNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        openTimeController.text.isEmpty ||
        closeTimeController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final latitude = double.tryParse(latitudeController.text);
    final longitude = double.tryParse(longitudeController.text);

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid latitude and longitude')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await StoreService.createStore(
        name: storeNameController.text,
        email: ownerEmailController.text,
        password: ownerPasswordController.text,
        phone: ownerPhoneController.text,
        address: addressController.text,
        description: descriptionController.text.isNotEmpty
            ? descriptionController.text
            : null,
        imageBase64: _imageBase64,
        openTime: openTimeController.text,
        closeTime: closeTimeController.text,
        latitude: latitude,
        longitude: longitude,
      );

      print('Response from server: $response');

      if (response != null) {
        _showSuccessDialog();
        _clearForm();
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add store')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearForm() {
    ownerNameController.clear();
    ownerEmailController.clear();
    ownerPhoneController.clear();
    ownerPasswordController.clear();
    storeNameController.clear();
    addressController.clear();
    descriptionController.clear();
    openTimeController.clear();
    closeTimeController.clear();
    latitudeController.clear();
    longitudeController.clear();
    setState(() {
      _imageBytes = null;
      _imageBase64 = null;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Store successfully added!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                                  title: "Owner Name",
                                  icon: Icons.person,
                                  controller: ownerNameController,
                                ),
                                CustomTextField(
                                  label: "Enter owner email address",
                                  title: "Owner Email",
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: ownerEmailController,
                                ),
                                CustomTextField(
                                  label: "Enter owner phone number",
                                  title: "Owner Phone",
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  controller: ownerPhoneController,
                                ),
                                CustomTextField(
                                  label: "Enter password",
                                  title: "Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  controller: ownerPasswordController,
                                  icon2: showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                                  title: "Store Name",
                                  icon: Icons.store,
                                  controller: storeNameController,
                                ),
                                CustomTextField(
                                  label: "Enter store address",
                                  title: "Address",
                                  icon: Icons.location_on,
                                  controller: addressController,
                                  maxLines: 3,
                                ),
                                CustomTextField(
                                  label: "Enter store description (optional)",
                                  title: "Description",
                                  icon: Icons.description,
                                  controller: descriptionController,
                                  maxLines: 3,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Enter open time (HH:mm)",
                                        title: "Open Time",
                                        icon: Icons.access_time,
                                        controller: openTimeController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Enter close time (HH:mm)",
                                        title: "Close Time",
                                        icon: Icons.access_time_filled,
                                        controller: closeTimeController,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Enter latitude",
                                        title: "Latitude",
                                        icon: Icons.gps_fixed,
                                        keyboardType: TextInputType.number,
                                        controller: latitudeController,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Enter longitude",
                                        title: "Longitude",
                                        icon: Icons.gps_fixed,
                                        keyboardType: TextInputType.number,
                                        controller: longitudeController,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            isLoading ? null : _saveStore,
                                        icon: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ))
                                            : const Icon(Icons.check_circle),
                                        label: Text(isLoading
                                            ? 'Adding...'
                                            : 'Add Store'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  'Upload a store image (Recommended: 400×300)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => _isHoveringUpload = true),
                                  onExit: (_) =>
                                      setState(() => _isHoveringUpload = false),
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      height: 280,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: _isHoveringUpload
                                            ? Colors.grey.shade100
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isHoveringUpload
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade300,
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: _imageBytes != null
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.memory(
                                                    _imageBytes!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
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
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        const Text(
                                                          'Change Image',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              _imageBytes =
                                                                  null;
                                                              _imageBase64 =
                                                                  null;
                                                            });
                                                          },
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
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
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                  ),
                                ),
                                if (_imageBase64 != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      'Image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
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
                                      color: Colors.blue.shade200,
                                    ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
