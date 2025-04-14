import 'dart:convert';
import 'dart:typed_data';
import 'package:delpick_admin/src/CustomerService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../Common/widgets/texts/customtextfield.dart';
import '../../../src/ApiService.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId; // Add parameter for customer ID

  const EditCustomerScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isHoveringUpload = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load customer data when screen initializes
    _loadCustomerData();
  }

  // Updated _loadCustomerData method
  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil API untuk mendapatkan data customer
      final response = await CustomerService.getCustomerById(widget.customerId);

      print('Response dari API: $response');

      if (response != null && response['data'] != null) {
        final customerData = response['data'];

        // Isi controller dengan data customer
        setState(() {
          nameController.text = customerData['name'] ?? '';
          emailController.text = customerData['email'] ?? '';
          phoneController.text = customerData['phone'] ?? '';

          // Jika customer memiliki avatar, set image base64
          if (customerData['avatar'] != null) {
            // Kode untuk menangani avatar
            // Mungkin perlu penanganan khusus tergantung format data dari API
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data customer')),
        );
      }
    } catch (e) {
      print('Error saat memuat data customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memuat data customer: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //Pick Image
  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();

      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) { // 5MB
        setState(() {
          _imageBytes = pickedImage;
          _imageBase64 = base64Encode(pickedImage);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large, choose a smaller image!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to check if form is valid
  bool _isFormValid() {
    final email = emailController.text;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    // Name shouldn't be empty if filled
    if (nameController.text.isNotEmpty && nameController.text.trim().isEmpty) {
      return false;
    }

    // Email validation: must be valid if present
    if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
      return false;
    }

    // Phone shouldn't be empty if filled
    if (phoneController.text.isNotEmpty && phoneController.text.trim().isEmpty) {
      return false;
    }

    // Only require current password if changing password
    bool passwordValidation = true;
    if (newPasswordController.text.isNotEmpty) {
      passwordValidation = currentPasswordController.text.isNotEmpty;
    }

    return nameController.text.isNotEmpty &&
        email.isNotEmpty && emailRegex.hasMatch(email) &&
        phoneController.text.isNotEmpty &&
        passwordValidation;
  }

  // Function to update customer
  Future<void> _editCustomer() async {
    // Make sure we have at least the basic required fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, email, and phone are required fields!')),
      );
      return;
    }

    // If updating password, make sure current password is provided
    if (newPasswordController.text.isNotEmpty && currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is required to change password!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await CustomerService.updateCustomer(
          widget.customerId, // Use the ID passed to the widget
          nameController.text,
          emailController.text,
          phoneController.text,
          currentPasswordController.text,
          newPasswordController.text,
          _imageBase64 // Include base64 image if available
      );

      if (response != null) {
        _showSuccessDialog();

        // If we're just updating without changing password, we can clear the fields
        if (newPasswordController.text.isEmpty) {
          currentPasswordController.clear();
        } else {
          // If we changed the password, clear both password fields
          currentPasswordController.clear();
          newPasswordController.clear();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update customer')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
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
          content: const Text('Customer successfully updated!'),
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
          'Edit Customer',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            Icons.person_add,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Customer',
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
                                  label: "Enter Current password",
                                  title: "Current Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  icon2: showPassword ? Icons.visibility : Icons.visibility_off,
                                  // onIcon2Pressed: () {
                                  //   setState(() {
                                  //     showPassword = !showPassword;
                                  //   });
                                  // },
                                  controller: currentPasswordController,
                                ),
                                CustomTextField(
                                  label: "Enter New password (leave empty to keep current)",
                                  title: "New Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  icon2: showPassword ? Icons.visibility : Icons.visibility_off,
                                  // onIcon2Pressed: () {
                                  //   setState(() {
                                  //     showPassword = !showPassword;
                                  //   });
                                  // },
                                  controller: newPasswordController,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isLoading ? null : (_isFormValid() ? _editCustomer : null),
                                        icon: isLoading
                                            ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                        )
                                            : const Icon(Icons.check_circle),
                                        label: Text(isLoading ? 'Updating...' : 'Update Customer'),
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
                                            'JPG, PNG or GIF (Max 5MB)',
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

                                // Information box
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