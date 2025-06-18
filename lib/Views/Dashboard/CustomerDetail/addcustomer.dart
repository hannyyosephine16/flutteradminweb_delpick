import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:delpick_admin/src/CustomerService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({super.key});

  @override
  State<AddNewCustomerScreen> createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool _isFormValid = false;

  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isHoveringUpload = false;
  bool _isProcessingImage = false;

  // Validation error messages
  Map<String, String?> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    // Add listeners to validate form in real-time
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Validate form fields in real-time
  void _validateForm() {
    setState(() {
      _validationErrors = CustomerService.validateCustomerData(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
      );

      _isFormValid = _validationErrors.isEmpty &&
          nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  /// Pick and process image
  Future<void> _pickImage() async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
      print('======= IMAGE PICKING PROCESS STARTED =======');
      final pickedImage = await ImagePickerWeb.getImageAsBytes();

      if (pickedImage != null) {
        print('Image picked successfully');
        print(
            'Image size: ${(pickedImage.lengthInBytes / 1024).toStringAsFixed(2)} KB');

        // Check file size (5MB limit)
        if (pickedImage.lengthInBytes > 5 * 1024 * 1024) {
          _showErrorSnackBar(
            'Image too large. Please select an image smaller than 5MB.',
          );
          return;
        }

        // Detect content type
        String contentType = _detectContentType(pickedImage);
        print('Detected content type: $contentType');

        // Validate content type
        if (![
          'image/jpeg',
          'image/jpg',
          'image/png',
          'image/gif',
          'image/webp',
          'image/bmp'
        ].contains(contentType)) {
          _showErrorSnackBar(
            'Unsupported image format. Please use JPG, PNG, GIF, WebP, or BMP.',
          );
          return;
        }

        // Encode to base64
        String base64String = base64Encode(pickedImage);
        print('Base64 encoding completed (${base64String.length} characters)');

        // Create complete data URL
        final imageBase64WithPrefix = 'data:$contentType;base64,$base64String';

        // Validate the result
        if (CustomerService.isValidImageFormat(imageBase64WithPrefix)) {
          setState(() {
            _imageBytes = pickedImage;
            _imageBase64 = imageBase64WithPrefix;
          });

          _showSuccessSnackBar('Image uploaded successfully!');
          print('✅ Image processed successfully');
        } else {
          _showErrorSnackBar('Failed to process image. Please try again.');
          print('❌ Invalid image format after processing');
        }
      } else {
        print('No image selected');
        _showInfoSnackBar('No image selected');
      }
    } catch (e) {
      print('❌ Error during image picking: $e');
      String errorMessage = 'Error selecting image';

      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied to access files';
      } else if (e.toString().contains('canceled')) {
        errorMessage = 'Image selection cancelled';
      } else if (e.toString().contains('format') ||
          e.toString().contains('decode')) {
        errorMessage = 'Unsupported image format';
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
      print('======= IMAGE PICKING PROCESS COMPLETED =======\n');
    }
  }

  /// Detect image content type from file signature
  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) {
      return 'image/jpeg'; // Default
    }

    // PNG signature: 89 50 4E 47
    if (bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71) {
      return 'image/png';
    }

    // JPEG signature: FF D8 FF
    if (bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255) {
      return 'image/jpeg';
    }

    // GIF signature: 47 49 46 38
    if (bytes[0] == 71 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 56) {
      return 'image/gif';
    }

    // WEBP signature: 52 49 46 46 ... 57 45 42 50
    if (bytes.length >= 12 &&
        bytes[0] == 82 &&
        bytes[1] == 73 &&
        bytes[2] == 70 &&
        bytes[3] == 70 &&
        bytes[8] == 87 &&
        bytes[9] == 69 &&
        bytes[10] == 66 &&
        bytes[11] == 80) {
      return 'image/webp';
    }

    // BMP signature: 42 4D
    if (bytes[0] == 66 && bytes[1] == 77) {
      return 'image/bmp';
    }

    return 'image/jpeg'; // Default
  }

  /// Save customer using the corrected service
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      _showErrorSnackBar('Please fix all validation errors before submitting.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 Starting customer creation process...');

      // Clean phone number
      final cleanPhone = CustomerService.cleanPhoneNumber(phoneController.text);

      // Final validation
      final errors = CustomerService.validateCustomerData(
        name: nameController.text,
        email: emailController.text,
        phone: cleanPhone,
        password: passwordController.text,
      );

      if (errors.isNotEmpty) {
        final errorMessage = errors.values.first!;
        _showErrorSnackBar(errorMessage);
        return;
      }

      // Call the corrected service method
      final response = await CustomerService.createCustomer(
        nameController.text.trim(),
        emailController.text.trim(),
        cleanPhone,
        passwordController.text,
        _imageBase64, // Can be null
      );

      if (response != null) {
        print('✅ Customer created successfully');
        _showSuccessDialog();
        _resetForm();
      } else {
        _showErrorSnackBar('Failed to create customer. Please try again.');
      }
    } catch (e) {
      print('❌ Error creating customer: $e');
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Reset form after successful creation
  void _resetForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    setState(() {
      _imageBytes = null;
      _imageBase64 = null;
      _validationErrors.clear();
      _isFormValid = false;
    });
  }

  /// Remove selected image
  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageBase64 = null;
    });
    _showInfoSnackBar('Image removed');
  }

  /// Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Success'),
            ],
          ),
          content: Text('Customer has been created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show info snackbar
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
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
          'Add New Customer',
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
          child: Form(
            key: _formKey,
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
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
                              'Add New Customer',
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
                                  // Name field
                                  CustomTextField(
                                    label: "Enter full name (3-50 characters)",
                                    title: "Full Name *",
                                    icon: Icons.person,
                                    controller: nameController,
                                    errorText: _validationErrors['name'],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Name is required';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'Name must be at least 3 characters';
                                      }
                                      if (value.trim().length > 50) {
                                        return 'Name must not exceed 50 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Email field
                                  CustomTextField(
                                    label: "Enter email address",
                                    title: "Email *",
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    errorText: _validationErrors['email'],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!RegExp(
                                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                          .hasMatch(value)) {
                                        return 'Invalid email format';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Phone field
                                  CustomTextField(
                                    label: "Enter phone number (10-13 digits)",
                                    title: "Phone Number *",
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    controller: phoneController,
                                    errorText: _validationErrors['phone'],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Phone is required';
                                      }
                                      final cleanPhone = value.replaceAll(
                                          RegExp(r'[^\d]'), '');
                                      if (!RegExp(r'^[0-9]{10,13}$')
                                          .hasMatch(cleanPhone)) {
                                        return 'Phone must be 10-13 digits only';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Password field
                                  CustomTextField(
                                    label: "Enter password (6-50 characters)",
                                    title: "Password *",
                                    icon: Icons.lock,
                                    obscureText: !showPassword,
                                    icon2: showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    // Uncomment if CustomTextField supports onIcon2Pressed
                                    // onIcon2Pressed: () {
                                    //   setState(() {
                                    //     showPassword = !showPassword;
                                    //   });
                                    // },
                                    controller: passwordController,
                                    errorText: _validationErrors['password'],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      if (value.length > 50) {
                                        return 'Password must not exceed 50 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Submit button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              (_isFormValid && !isLoading)
                                                  ? _saveCustomer
                                                  : null,
                                          icon: isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Icon(Icons.check_circle),
                                          label: Text(isLoading
                                              ? 'Creating...'
                                              : 'Add Customer'),
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

                                  // Form validation status
                                  if (!_isFormValid &&
                                      (nameController.text.isNotEmpty ||
                                          emailController.text.isNotEmpty ||
                                          phoneController.text.isNotEmpty ||
                                          passwordController.text.isNotEmpty))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.orange.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_amber,
                                                color: Colors.orange.shade700,
                                                size: 18),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Please fix validation errors above before submitting.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                    'Profile Photo (Optional)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Upload a profile picture (Max 5MB)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Image upload area
                                  MouseRegion(
                                    onEnter: (_) => setState(
                                        () => _isHoveringUpload = true),
                                    onExit: (_) => setState(
                                        () => _isHoveringUpload = false),
                                    child: GestureDetector(
                                      onTap: _isProcessingImage
                                          ? null
                                          : _pickImage,
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
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: _imageBytes != null
                                            ? _buildImagePreview()
                                            : _isProcessingImage
                                                ? _buildLoadingIndicator()
                                                : _buildUploadPrompt(),
                                      ),
                                    ),
                                  ),

                                  // Image info
                                  if (_imageBase64 != null) _buildImageInfo(),

                                  const SizedBox(height: 24),

                                  // Information box
                                  _buildInfoBox(),
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
      ),
    );
  }

  /// Build image preview widget
  Widget _buildImagePreview() {
    return Stack(
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
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Change Photo',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white, size: 18),
                  onPressed: _removeImage,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  tooltip: 'Remove Photo',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build loading indicator widget
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Processing image...',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build upload prompt widget
  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
          'JPG, PNG, GIF, WebP, BMP (Max 5MB)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build image info widget
  Widget _buildImageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build information box widget
  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
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
    );
  }
}
