import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';
import '../../../src/StoreService.dart';

class AddNewStoreScreen extends StatefulWidget {
  const AddNewStoreScreen({super.key});

  @override
  State<AddNewStoreScreen> createState() => _AddNewStoreScreenState();
}

class _AddNewStoreScreenState extends State<AddNewStoreScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController openTimeController = TextEditingController();
  final TextEditingController closeTimeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController(); // Fixed: longitudeController, not longtitudeController

  String? selectedRole;
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

      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) { // 5MB
        // Konversi ke base64 dan tambahkan prefix yang sesuai
        final base64String = base64Encode(pickedImage);
        // Tentukan format gambar (umumnya JPEG)
        final imageBase64WithPrefix = 'data:image/jpeg;base64,' + base64String;

        setState(() {
          _imageBytes = pickedImage;  // Simpan bytes untuk ditampilkan
          _imageBase64 = imageBase64WithPrefix;  // Base64 dengan prefix yang sesuai untuk backend
        });

        print('Gambar berhasil dikonversi ke base64 dengan prefix');
      } else if (pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar terlalu besar, pilih gambar yang lebih kecil dari 5MB!')),
        );
      }
    } catch (e) {
      print('Error saat memilih gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memilih gambar: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveStore() async {
    // Validation logic
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        addressController.text.isEmpty ||
        storeNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        openTimeController.text.isEmpty ||
        closeTimeController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Debug: periksa apakah gambar dalam format yang benar
      if (_imageBase64 != null) {
        print('Format base64 gambar: ${_imageBase64!.substring(0, 30)}...'); // Tampilkan awal string saja
        if (!_imageBase64!.startsWith('data:image/')) {
          print('Warning: Format base64 gambar tidak dimulai dengan "data:image/"');
        }
      } else {
        print('Tidak ada gambar yang dipilih');
        // Menampilkan pesan jika tidak ada gambar yang dipilih
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih gambar toko')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Memanggil StoreService.createStore dengan data yang benar
      final response = await StoreService.createStore(
        nameController.text,  // name
        emailController.text, // email
        passwordController.text, // password
        phoneController.text, // phone
        storeNameController.text, // storeName
        addressController.text, // address
        descriptionController.text, // description
        openTimeController.text, // openTime
        closeTimeController.text, // closeTime
        latitudeController.text, // latitude
        longitudeController.text, // longitude
        _imageBase64, // imageBase64
      );

      print('Response dari server: $response');

      if (response != null) {
        // Jika berhasil menambah store, tampilkan popup
        _showSuccessDialog();
        // Reset form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        addressController.clear();
        storeNameController.clear();
        descriptionController.clear();
        openTimeController.clear();
        closeTimeController.clear();
        latitudeController.clear();
        longitudeController.clear();
        setState(() {
          _imageBytes = null;
          _imageBase64 = null;
        });
        // Navigate back after successful creation
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan store')),
        );
      }
    } catch (e) {
      // Show error message with detailed error
      print('Error detail: $e');
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Store berhasil ditambahkan!'), // Fixed: "Store" not "Driver"
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.store,
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

                    // Form content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left section - Form fields
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  label: "Enter full name",
                                  title: "Full Name",
                                  icon: Icons.person,
                                  controller: nameController,
                                ), //Full Name
                                CustomTextField(
                                  label: "Enter email address",
                                  title: "Email",
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                ), //Email
                                CustomTextField(
                                  label: "Enter phone number",
                                  title: "Phone Number",
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                ), //Phone
                                CustomTextField(
                                  label: "Enter password",
                                  title: "Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  icon2: showPassword ? Icons.visibility : Icons.visibility_off,
                                  controller: passwordController,
                                ), //Password
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _saveStore, // Fixed: Call the actual save method
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Add Store'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
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

                          // Right section - Upload image
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  label: "Store name",
                                  title: "Store Name",
                                  icon: Icons.store_mall_directory,
                                  controller: storeNameController,
                                ),
                                CustomTextField(
                                  label: "Address Store",
                                  title: "Address Store",
                                  icon: Icons.add_road,
                                  controller: addressController,
                                ),
                                CustomTextField(
                                  label: "Description Store",
                                  title: "Description",
                                  icon: Icons.border_color,
                                  controller: descriptionController,
                                ),
                                CustomTextField(
                                  label: "Open Time",
                                  title: "Open Time",
                                  icon: Icons.access_time,
                                  controller: openTimeController,
                                ),
                                CustomTextField(
                                  label: "Close Time",
                                  title: "Close Time",
                                  icon: Icons.access_time_filled,
                                  controller: closeTimeController,
                                ),
                                CustomTextField(
                                  label: "Latitude",
                                  title: "Latitude",
                                  icon: Icons.pin_drop_rounded,
                                  controller: latitudeController,
                                ),
                                CustomTextField(
                                  label: "Longitude",
                                  title: "Longitude",
                                  icon: Icons.pin_drop_rounded,
                                  controller: longitudeController, // Fixed: use longitudeController
                                ),
                                const Text(
                                  'Profile Photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Upload a profile picture (Recommended: 192×182)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Image upload area
                                MouseRegion(
                                  onEnter: (_) => setState(() => _isHoveringUpload = true),
                                  onExit: (_) => setState(() => _isHoveringUpload = false),
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
                                          // Display selected image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.memory(
                                              _imageBytes!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          // Overlay for change button
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              color: Colors.black.withOpacity(0.6),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Change Photo',
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
                                                        _imageBytes = null;
                                                        _imageBase64 = null;
                                                      });
                                                    },
                                                    padding: EdgeInsets.zero,
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
                                        child: CircularProgressIndicator(),
                                      )
                                          : Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.cloud_upload_rounded,
                                              size: 36,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Drag & drop or click to upload',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'JPG, PNG or GIF (Max 2MB)',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
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

                                // Information box
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
                                          'Adding a clear profile photo helps with customer identification and improves the user experience.',
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