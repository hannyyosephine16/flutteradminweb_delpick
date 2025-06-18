import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../src/DriverService.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewDriverScreen extends StatefulWidget {
  const AddNewDriverScreen({super.key});
  @override
  State<AddNewDriverScreen> createState() => _AddNewDriverScreenState();
}

class _AddNewDriverScreenState extends State<AddNewDriverScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;
  Uint8List? _imageBytes;
  String? _imageBase64;
  String? _imageName;
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

        print('Gambar berhasil dikonversi ke base64 dengan prefix');
      } else if (pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Gambar terlalu besar, pilih gambar yang lebih kecil dari 5MB!')),
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

  Future<void> _saveDriver() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        licenseController.text.isEmpty ||
        vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      if (_imageBase64 != null) {
        print('Format base64 gambar: ${_imageBase64!.substring(0, 30)}...');
        if (!_imageBase64!.startsWith('data:image/')) {
          print(
              'Warning: Format base64 gambar tidak dimulai dengan "data:image/"');
        }
      } else {
        print('Tidak ada gambar yang dipilih');
      }

      final response = await DriverService.createDriver(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        phone: phoneController.text,
        licenseNumber: licenseController.text,
        vehiclePlate: vehicleController.text,
        avatar: _imageBase64,
      );

      print('Response dari server: $response');

      if (response != null) {
        _showSuccessDialog();
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        licenseController.clear();
        vehicleController.clear();
        setState(() {
          _imageBytes = null;
          _imageBase64 = null;
        });
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan driver')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add driver: $e'),
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Driver berhasil ditambahkan!'),
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
          'Add New Driver',
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
                            Icons.person_add,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add New Driver',
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
                                CustomTextField(
                                  label: "Enter full name",
                                  title: "Full Name",
                                  icon: Icons.person,
                                  controller: nameController,
                                ),
                                CustomTextField(
                                  label: "Enter email address",
                                  title: "Email",
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                ),
                                CustomTextField(
                                  label: "Enter phone number",
                                  title: "Phone Number",
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                ),
                                CustomTextField(
                                  label: "Enter password",
                                  title: "Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  controller: passwordController,
                                  icon2: showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                CustomTextField(
                                  label: "Enter license number",
                                  title: "License Number",
                                  icon: Icons.badge,
                                  controller: licenseController,
                                ),
                                CustomTextField(
                                  label: "Enter vehicle plate number",
                                  title: "Vehicle Plate",
                                  icon: Icons.motorcycle,
                                  controller: vehicleController,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            isLoading ? null : _saveDriver,
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
                                            : 'Add Driver'),
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
                                                      'JPG, PNG or GIF (Max 2MB)',
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
