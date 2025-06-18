// lib/Views/Dashboard/CustomerDetail/EditCustomer.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:delpick_admin/src/CustomerService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId;

  const EditCustomerScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  bool _isFormValid = false;
  bool _isLoadingData = false;

  Uint8List? _imageBytes;
  String? _imageBase64;
  String? _currentImageUrl;
  bool _isHoveringUpload = false;
  bool _isProcessingImage = false;

  Map<String, String?> _validationErrors = {};
  Map<String, dynamic>? _originalCustomerData;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    _loadCustomerData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      print('🔄 Loading customer data for ID: ${widget.customerId}');

      final response = await CustomerService.getCustomerById(widget.customerId);

      if (response != null && response['data'] != null) {
        final customerData = response['data'];
        _originalCustomerData = Map<String, dynamic>.from(customerData);

        print('✅ Customer data loaded successfully');
        print('Customer: ${customerData['name']} (${customerData['email']})');

        setState(() {
          nameController.text = customerData['name'] ?? '';
          emailController.text = customerData['email'] ?? '';
          phoneController.text = customerData['phone'] ?? '';
          _currentImageUrl = customerData['avatar'];
        });

        _validateForm();
      } else {
        print('❌ Failed to load customer data');
        _showErrorSnackBar('Failed to load customer data');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error loading customer data: $e');
      _showErrorSnackBar(
          'Error loading customer data: ${e.toString().replaceFirst('Exception: ', '')}');
      Navigator.of(context).pop();
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _validateForm() {
    setState(() {
      _validationErrors = CustomerService.validateCustomerData(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
      );

      _isFormValid = _validationErrors.isEmpty &&
          nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          _hasDataChanged();
    });
  }

  bool _hasDataChanged() {
    if (_originalCustomerData == null) return false;

    final cleanCurrentPhone =
        CustomerService.cleanPhoneNumber(phoneController.text);
    final cleanOriginalPhone =
        CustomerService.cleanPhoneNumber(_originalCustomerData!['phone'] ?? '');

    return nameController.text.trim() !=
            (_originalCustomerData!['name'] ?? '') ||
        emailController.text.trim() !=
            (_originalCustomerData!['email'] ?? '') ||
        cleanCurrentPhone != cleanOriginalPhone ||
        _imageBase64 != null;
  }

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

        if (pickedImage.lengthInBytes > 5 * 1024 * 1024) {
          _showErrorSnackBar(
            'Image too large. Please select an image smaller than 5MB.',
          );
          return;
        }

        String contentType = _detectContentType(pickedImage);
        print('Detected content type: $contentType');

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

        String base64String = base64Encode(pickedImage);
        print('Base64 encoding completed (${base64String.length} characters)');

        final imageBase64WithPrefix = 'data:$contentType;base64,$base64String';

        if (CustomerService.isValidImageFormat(imageBase64WithPrefix)) {
          setState(() {
            _imageBytes = pickedImage;
            _imageBase64 = imageBase64WithPrefix;
            _currentImageUrl = null;
          });

          _showSuccessSnackBar('Image uploaded successfully!');
          print('✅ Image processed successfully');
          _validateForm();
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

  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) {
      return 'image/jpeg';
    }

    if (bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71) {
      return 'image/png';
    }

    if (bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255) {
      return 'image/jpeg';
    }

    if (bytes[0] == 71 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 56) {
      return 'image/gif';
    }

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

    if (bytes[0] == 66 && bytes[1] == 77) {
      return 'image/bmp';
    }

    return 'image/jpeg';
  }

  Future<void> _updateCustomer() async {
    if (!_isFormValid) {
      _showErrorSnackBar('Please fix all validation errors before submitting.');
      return;
    }

    if (!_hasDataChanged()) {
      _showInfoSnackBar('No changes detected.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 Starting customer update process...');

      final cleanPhone = CustomerService.cleanPhoneNumber(phoneController.text);

      final errors = CustomerService.validateCustomerData(
        name: nameController.text,
        email: emailController.text,
        phone: cleanPhone,
      );

      if (errors.isNotEmpty) {
        final errorMessage = errors.values.first!;
        _showErrorSnackBar(errorMessage);
        return;
      }

      final response = await CustomerService.updateCustomer(
        widget.customerId,
        nameController.text.trim(),
        emailController.text.trim(),
        cleanPhone,
        null,
        null,
        _imageBase64,
      );

      if (response != null) {
        print('✅ Customer updated successfully');
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Failed to update customer. Please try again.');
      }
    } catch (e) {
      print('❌ Error updating customer: $e');
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageBase64 = null;
    });
    _validateForm();
    _showInfoSnackBar('New image removed');
  }

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
          content: Text('Customer has been updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
          'Edit Customer',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading customer data...'),
                ],
              ),
            )
          : SingleChildScrollView(
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
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
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          label:
                                              "Enter full name (3-50 characters)",
                                          title: "Full Name *",
                                          icon: Icons.person,
                                          controller: nameController,
                                          errorText: _validationErrors['name'],
                                        ),
                                        CustomTextField(
                                          label: "Enter email address",
                                          title: "Email *",
                                          icon: Icons.email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          controller: emailController,
                                          errorText: _validationErrors['email'],
                                        ),
                                        CustomTextField(
                                          label:
                                              "Enter phone number (10-13 digits)",
                                          title: "Phone Number *",
                                          icon: Icons.phone,
                                          keyboardType: TextInputType.phone,
                                          controller: phoneController,
                                          errorText: _validationErrors['phone'],
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    (_isFormValid && !isLoading)
                                                        ? _updateCustomer
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
                                                    ? 'Updating...'
                                                    : 'Update Customer'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!_hasDataChanged() &&
                                            !_isLoadingData)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline,
                                                      color:
                                                          Colors.blue.shade700,
                                                      size: 18),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'No changes detected. Modify any field to enable update.',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .blue.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (!_isFormValid && _hasDataChanged())
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.orange.shade200),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.warning_amber,
                                                      color: Colors
                                                          .orange.shade700,
                                                      size: 18),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Please fix validation errors above before submitting.',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .orange.shade700,
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
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          'Upload a new profile picture (Max 5MB)',
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
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.grey.shade300,
                                                  width: 2,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: _imageBytes != null
                                                  ? _buildNewImagePreview()
                                                  : _currentImageUrl != null &&
                                                          _currentImageUrl!
                                                              .isNotEmpty
                                                      ? _buildCurrentImagePreview()
                                                      : _isProcessingImage
                                                          ? _buildLoadingIndicator()
                                                          : _buildUploadPrompt(),
                                            ),
                                          ),
                                        ),
                                        if (_imageBase64 != null)
                                          _buildNewImageInfo(),
                                        if (_currentImageUrl != null &&
                                            _imageBase64 == null)
                                          _buildCurrentImageInfo(),
                                        const SizedBox(height: 24),
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

  Widget _buildNewImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
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
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Change Photo',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white, size: 18),
                  onPressed: _removeImage,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  tooltip: 'Remove New Photo',
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('NEW',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentImagePreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            _currentImageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image,
                        size: 48, color: Colors.grey.shade500),
                    SizedBox(height: 8),
                    Text('Failed to load image',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Change Photo',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('CURRENT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
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

  Widget _buildNewImageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'New image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentImageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Current profile photo (click above to change)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

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
              'You can update the profile photo by uploading a new image. The current photo will be replaced.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
