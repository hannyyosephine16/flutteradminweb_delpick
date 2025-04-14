import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../src/DriverService.dart';
import '../../../Common/GlobalStyle.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class EditDriverScreen extends StatefulWidget {
  final String driverId;
  final Map<String, dynamic>? initialData;

  const EditDriverScreen({
    Key? key,
    required this.driverId,
    this.initialData,
  }) : super(key: key);

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  Uint8List? _imageBytes;
  String? _imageBase64;
  String? _imageUrl;
  bool _isHoveringUpload = false;
  bool _isLoading = false;
  String? _selectedStatus;
  bool _isSaving = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isImageChanged = false;

  @override
  void initState() {
    super.initState();

    // If we have initial data, populate the form immediately
    if (widget.initialData != null) {
      _populateFormFromData(widget.initialData!);
    } else {
      // Otherwise, fetch the driver data from API
      _fetchDriverData();
    }
  }

  void _populateFormFromData(Map<String, dynamic> data) {
    setState(() {
      nameController.text = data['username'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      vehicleController.text = data['vehicle_number'] ?? '';
      _selectedStatus = data['status'] == 'ON' ? 'active' : 'inactive';

      // If there's a profile image in the data, set it
      if (data['userData'] != null && data['userData']['profile_image'] != null) {
        _imageUrl = data['userData']['profile_image'];
      }
    });
  }

  Future<void> _fetchDriverData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await DriverService.getDriverById(widget.driverId);

      if (response != null && response.containsKey('data')) {
        final driverData = response['data'];
        final userData = driverData['user'];

        setState(() {
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          vehicleController.text = driverData['vehicle_number'] ?? '';
          _selectedStatus = driverData['status'] ?? 'inactive';

          if (userData['profile_image'] != null) {
            _imageUrl = userData['profile_image'];
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response format or driver not found');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error fetching driver data: $e');

      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load driver data: $_errorMessage")),
      );
    }
  }

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
          _isImageChanged = true;
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

  // Function to update driver
  Future<void> _saveDriver() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> driverData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'vehicle_number': vehicleController.text,
        'status': _selectedStatus,
      };

      // Only include password if it's not empty
      if (newPasswordController.text.isNotEmpty) {
        driverData['current_password'] = currentPasswordController.text;
        driverData['new_password'] = newPasswordController.text;
      }

      // Only include image if it has been changed
      if (_isImageChanged && _imageBase64 != null) {
        driverData['profile_image'] = _imageBase64;
      }

      await DriverService.updateDriver(widget.driverId, driverData);

      setState(() {
        _isSaving = false;
      });

      _showSuccessDialog();

      // Clear password fields after success
      currentPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update driver: $_errorMessage")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Driver successfully updated!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Return true to indicate successful update
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
          'Edit Driver',
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
                            'Edit Driver',
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
                                CustomDropdown(
                                  label: "Select Driver Status",
                                  title: "Status",
                                  items: const ["Active", "Inactive"],
                                  selectedItem: _selectedStatus == 'active' ? 'Active' : 'Inactive',
                                  icon: Icons.account_circle,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value?.toLowerCase();
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
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
                                  label: "Enter vehicle number",
                                  title: "Vehicle Number",
                                  icon: Icons.directions_car,
                                  controller: vehicleController,
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
                                        onPressed: _isSaving ? null : (_isFormValid() ? _saveDriver : null),
                                        icon: _isSaving
                                            ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                        )
                                            : const Icon(Icons.check_circle),
                                        label: Text(_isSaving ? 'Updating...' : 'Update Driver'),
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
                                                        _isImageChanged = true;
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
                                          : _imageUrl != null
                                          ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Display existing image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              _imageUrl!,
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
                                          'Adding a clear profile photo helps with driver identification and improves the user experience.',
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