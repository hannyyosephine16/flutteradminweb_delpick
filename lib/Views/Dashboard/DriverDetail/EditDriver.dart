// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import '../../../src/DriverService.dart';
// import '../../../Common/GlobalStyle.dart';
// import '../../../Common/widgets/texts/customdropdownfield.dart';
// import '../../../Common/widgets/texts/customtextfield.dart';
//
// class EditDriverScreen extends StatefulWidget {
//   final String driverId;
//   final Map<String, dynamic>? initialData;
//
//   const EditDriverScreen({
//     Key? key,
//     required this.driverId,
//     this.initialData,
//   }) : super(key: key);
//
//   @override
//   State<EditDriverScreen> createState() => _EditDriverScreenState();
// }
//
// class _EditDriverScreenState extends State<EditDriverScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController licenseController = TextEditingController();
//   final TextEditingController currentPasswordController =
//       TextEditingController();
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController vehicleController = TextEditingController();
//
//   bool isLoading = false;
//   bool showPassword = false;
//
//   Uint8List? _imageBytes;
//   String? _imageBase64;
//   String? _imageUrl;
//   bool _isHoveringUpload = false;
//   bool _isLoading = false;
//   String? _selectedStatus;
//   bool _isSaving = false;
//   bool _hasError = false;
//   String _errorMessage = '';
//   bool _isImageChanged = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.initialData != null) {
//       _populateFormFromData(widget.initialData!);
//     } else {
//       _fetchDriverData();
//     }
//   }
//
//   void _populateFormFromData(Map<String, dynamic> data) {
//     setState(() {
//       nameController.text = data['username'] ?? '';
//       emailController.text = data['email'] ?? '';
//       phoneController.text = data['phone'] ?? '';
//       licenseController.text = data['license_number'] ?? '';
//       vehicleController.text = data['vehicle_number'] ?? '';
//       _selectedStatus = data['status'] == 'ON' ? 'active' : 'inactive';
//
//       if (data['userData'] != null &&
//           data['userData']['profile_image'] != null) {
//         _imageUrl = data['userData']['profile_image'];
//       }
//     });
//   }
//
//   Future<void> _fetchDriverData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
//
//     try {
//       final driver = await DriverService.getDriverById(widget.driverId);
//
//       if (driver != null) {
//         setState(() {
//           nameController.text = driver.displayName;
//           emailController.text = driver.displayEmail;
//           phoneController.text = driver.displayPhone;
//           licenseController.text = driver.licenseNumber;
//           vehicleController.text = driver.vehiclePlate;
//           _selectedStatus = driver.status;
//
//           if (driver.user?.avatar != null) {
//             _imageUrl = driver.user!.avatar;
//           }
//
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Driver not found');
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print('Error fetching driver data: $e');
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to load driver data: $_errorMessage")),
//       );
//     }
//   }
//
//   Future<void> _pickImage() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final pickedImage = await ImagePickerWeb.getImageAsBytes();
//
//       if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) {
//         setState(() {
//           _imageBytes = pickedImage;
//           _imageBase64 = 'data:image/jpeg;base64,' + base64Encode(pickedImage);
//           _isImageChanged = true;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Image too large, choose a smaller image!')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   bool _isFormValid() {
//     final email = emailController.text;
//     final emailRegex =
//         RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//
//     if (nameController.text.isNotEmpty && nameController.text.trim().isEmpty) {
//       return false;
//     }
//
//     if (email.isNotEmpty && !emailRegex.hasMatch(email)) {
//       return false;
//     }
//
//     if (phoneController.text.isNotEmpty &&
//         phoneController.text.trim().isEmpty) {
//       return false;
//     }
//
//     bool passwordValidation = true;
//     if (newPasswordController.text.isNotEmpty) {
//       passwordValidation = currentPasswordController.text.isNotEmpty;
//     }
//
//     return nameController.text.isNotEmpty &&
//         email.isNotEmpty &&
//         emailRegex.hasMatch(email) &&
//         phoneController.text.isNotEmpty &&
//         licenseController.text.isNotEmpty &&
//         vehicleController.text.isNotEmpty &&
//         passwordValidation;
//   }
//
//   Future<void> _saveDriver() async {
//     if (nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         phoneController.text.isEmpty ||
//         licenseController.text.isEmpty ||
//         vehicleController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }
//
//     setState(() {
//       _isSaving = true;
//     });
//
//     try {
//       await DriverService.updateDriver(
//         id: widget.driverId,
//         name: nameController.text,
//         email: emailController.text,
//         phone: phoneController.text,
//         licenseNumber: licenseController.text,
//         vehiclePlate: vehicleController.text,
//         status: _selectedStatus,
//         avatar: _isImageChanged && _imageBase64 != null ? _imageBase64 : null,
//       );
//
//       setState(() {
//         _isSaving = false;
//       });
//
//       _showSuccessDialog();
//
//       currentPasswordController.clear();
//       newPasswordController.clear();
//     } catch (e) {
//       setState(() {
//         _isSaving = false;
//         _hasError = true;
//         _errorMessage = e.toString();
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update driver: $_errorMessage")),
//       );
//     }
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Success'),
//           content: const Text('Driver successfully updated!'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Edit Driver',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context)
//                                   .primaryColor
//                                   .withOpacity(0.1),
//                               border: Border(
//                                 bottom: BorderSide(
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.2),
//                                   width: 1,
//                                 ),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.person_add,
//                                   color: Theme.of(context).primaryColor,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   'Edit Driver',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(24.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       CustomDropdown(
//                                         label: "Select Driver Status",
//                                         title: "Status",
//                                         items: const [
//                                           "Active",
//                                           "Inactive",
//                                           "Busy"
//                                         ],
//                                         selectedItem:
//                                             _selectedStatus == 'active'
//                                                 ? 'Active'
//                                                 : _selectedStatus == 'busy'
//                                                     ? 'Busy'
//                                                     : 'Inactive',
//                                         icon: Icons.account_circle,
//                                         onChanged: (value) {
//                                           setState(() {
//                                             _selectedStatus =
//                                                 value?.toLowerCase();
//                                           });
//                                         },
//                                       ),
//                                       const SizedBox(height: 8),
//                                       CustomTextField(
//                                         label: "Enter full name",
//                                         title: "Full Name",
//                                         icon: Icons.person,
//                                         controller: nameController,
//                                       ),
//                                       CustomTextField(
//                                         label: "Enter email address",
//                                         title: "Email",
//                                         icon: Icons.email,
//                                         keyboardType:
//                                             TextInputType.emailAddress,
//                                         controller: emailController,
//                                       ),
//                                       CustomTextField(
//                                         label: "Enter phone number",
//                                         title: "Phone Number",
//                                         icon: Icons.phone,
//                                         keyboardType: TextInputType.phone,
//                                         controller: phoneController,
//                                       ),
//                                       CustomTextField(
//                                         label: "Enter license number",
//                                         title: "License Number",
//                                         icon: Icons.badge,
//                                         controller: licenseController,
//                                       ),
//                                       CustomTextField(
//                                         label: "Enter vehicle number",
//                                         title: "Vehicle Number",
//                                         icon: Icons.directions_car,
//                                         controller: vehicleController,
//                                       ),
//                                       const SizedBox(height: 24),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: ElevatedButton.icon(
//                                               onPressed: _isSaving
//                                                   ? null
//                                                   : (_isFormValid()
//                                                       ? _saveDriver
//                                                       : null),
//                                               icon: _isSaving
//                                                   ? const SizedBox(
//                                                       width: 20,
//                                                       height: 20,
//                                                       child:
//                                                           CircularProgressIndicator(
//                                                         color: Colors.white,
//                                                         strokeWidth: 2,
//                                                       ))
//                                                   : const Icon(
//                                                       Icons.check_circle),
//                                               label: Text(_isSaving
//                                                   ? 'Updating...'
//                                                   : 'Update Driver'),
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     Theme.of(context)
//                                                         .primaryColor,
//                                                 foregroundColor: Colors.white,
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 16),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 40),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Profile Photo',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       const Text(
//                                         'Upload a profile picture (Recommended: 192×182)',
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Colors.black54,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       MouseRegion(
//                                         onEnter: (_) => setState(
//                                             () => _isHoveringUpload = true),
//                                         onExit: (_) => setState(
//                                             () => _isHoveringUpload = false),
//                                         child: GestureDetector(
//                                           onTap: _pickImage,
//                                           child: Container(
//                                             height: 280,
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               color: _isHoveringUpload
//                                                   ? Colors.grey.shade100
//                                                   : Colors.grey.shade50,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               border: Border.all(
//                                                 color: _isHoveringUpload
//                                                     ? Theme.of(context)
//                                                         .primaryColor
//                                                     : Colors.grey.shade300,
//                                                 width: 2,
//                                                 style: BorderStyle.solid,
//                                               ),
//                                             ),
//                                             child: _imageBytes != null
//                                                 ? Stack(
//                                                     alignment: Alignment.center,
//                                                     children: [
//                                                       ClipRRect(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(10),
//                                                         child: Image.memory(
//                                                           _imageBytes!,
//                                                           fit: BoxFit.cover,
//                                                           width:
//                                                               double.infinity,
//                                                           height:
//                                                               double.infinity,
//                                                         ),
//                                                       ),
//                                                       Positioned(
//                                                         bottom: 0,
//                                                         left: 0,
//                                                         right: 0,
//                                                         child: Container(
//                                                           color: Colors.black
//                                                               .withOpacity(0.6),
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                             vertical: 12,
//                                                             horizontal: 16,
//                                                           ),
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               const Icon(
//                                                                 Icons.edit,
//                                                                 color: Colors
//                                                                     .white,
//                                                                 size: 16,
//                                                               ),
//                                                               const SizedBox(
//                                                                   width: 8),
//                                                               const Text(
//                                                                 'Change Photo',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontSize: 14,
//                                                                 ),
//                                                               ),
//                                                               const Spacer(),
//                                                               IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons.delete,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   size: 18,
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   setState(() {
//                                                                     _imageBytes =
//                                                                         null;
//                                                                     _imageBase64 =
//                                                                         null;
//                                                                     _isImageChanged =
//                                                                         true;
//                                                                   });
//                                                                 },
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .zero,
//                                                                 constraints:
//                                                                     const BoxConstraints(),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   )
//                                                 : _imageUrl != null
//                                                     ? Stack(
//                                                         alignment:
//                                                             Alignment.center,
//                                                         children: [
//                                                           ClipRRect(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10),
//                                                             child:
//                                                                 Image.network(
//                                                               _imageUrl!,
//                                                               fit: BoxFit.cover,
//                                                               width: double
//                                                                   .infinity,
//                                                               height: double
//                                                                   .infinity,
//                                                             ),
//                                                           ),
//                                                           Positioned(
//                                                             bottom: 0,
//                                                             left: 0,
//                                                             right: 0,
//                                                             child: Container(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                       0.6),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                 vertical: 12,
//                                                                 horizontal: 16,
//                                                               ),
//                                                               child: Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 children: [
//                                                                   const Icon(
//                                                                     Icons.edit,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     size: 16,
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       width: 8),
//                                                                   const Text(
//                                                                     'Change Photo',
//                                                                     style:
//                                                                         TextStyle(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontSize:
//                                                                           14,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       )
//                                                     : isLoading
//                                                         ? const Center(
//                                                             child:
//                                                                 CircularProgressIndicator(),
//                                                           )
//                                                         : Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Container(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         16),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Theme.of(
//                                                                           context)
//                                                                       .primaryColor
//                                                                       .withOpacity(
//                                                                           0.1),
//                                                                   shape: BoxShape
//                                                                       .circle,
//                                                                 ),
//                                                                 child: Icon(
//                                                                   Icons
//                                                                       .cloud_upload_rounded,
//                                                                   size: 36,
//                                                                   color: Theme.of(
//                                                                           context)
//                                                                       .primaryColor,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 16),
//                                                               Text(
//                                                                 'Drag & drop or click to upload',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Theme.of(
//                                                                           context)
//                                                                       .primaryColor,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                   height: 8),
//                                                               Text(
//                                                                 'JPG, PNG or GIF (Max 5MB)',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Colors
//                                                                       .grey
//                                                                       .shade600,
//                                                                   fontSize: 12,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 24),
//                                       Container(
//                                         padding: const EdgeInsets.all(12),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue.shade50,
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           border: Border.all(
//                                             color: Colors.blue.shade200,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Icon(
//                                               Icons.info_outline,
//                                               color: Colors.blue.shade700,
//                                               size: 18,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Expanded(
//                                               child: Text(
//                                                 'Adding a clear profile photo helps with driver identification and improves the user experience.',
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.blue.shade700,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../src/DriverService.dart';
import '../../../Models/DriverModel.dart';
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
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();

  bool isLoading = false;
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
  DriverModel? _currentDriver;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _populateFormFromData(widget.initialData!);
    } else {
      _fetchDriverData();
    }
  }

  // ✅ FIXED: Proper data population from DriverSection format
  void _populateFormFromData(Map<String, dynamic> data) {
    setState(() {
      // Map from DriverSection format to form fields
      nameController.text = data['username'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      licenseController.text = data['license_number'] ?? '';
      vehicleController.text = data['vehicle_plate'] ?? '';

      // ✅ FIXED: Direct status mapping (backend uses 'active', 'inactive', 'busy')
      _selectedStatus = data['status'] ?? 'inactive';

      // ✅ FIXED: Handle avatar from userData or driverData
      final userData = data['userData'] as Map<String, dynamic>?;
      if (userData != null && userData['avatar'] != null) {
        _imageUrl = _buildImageUrl(userData['avatar']);
      }
    });
  }

  // ✅ NEW: Build full image URL
  String _buildImageUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return '';

    // If already a full URL, return as is
    if (avatarPath.startsWith('http')) return avatarPath;

    // Build full URL from relative path
    return 'http://localhost:5000$avatarPath';
  }

  // ✅ FIXED: Fetch driver data using DriverService
  Future<void> _fetchDriverData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🔄 Fetching driver data for ID: ${widget.driverId}');

      final driver = await DriverService.getDriverById(widget.driverId);

      setState(() {
        _currentDriver = driver;

        // Populate form with DriverModel data
        nameController.text = driver.displayName;
        emailController.text = driver.displayEmail;
        phoneController.text = driver.displayPhone;
        licenseController.text = driver.licenseNumber;
        vehicleController.text = driver.vehiclePlate;
        _selectedStatus = driver.status;

        // Set image URL if available
        if (driver.user?.avatar != null) {
          _imageUrl = _buildImageUrl(driver.user!.avatar);
        }

        _isLoading = false;
      });

      print('✅ Driver data loaded successfully');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });

      print('❌ Error fetching driver data: $e');
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

      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) {
        setState(() {
          _imageBytes = pickedImage;
          _imageBase64 = 'data:image/jpeg;base64,' + base64Encode(pickedImage);
          _isImageChanged = true;
        });
        print('✅ Image selected successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Image too large, choose a smaller image!')),
        );
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ ENHANCED: Form validation
  bool _isFormValid() {
    final email = emailController.text.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    // Check all required fields
    if (nameController.text.trim().isEmpty ||
        email.isEmpty ||
        phoneController.text.trim().isEmpty ||
        licenseController.text.trim().isEmpty ||
        vehicleController.text.trim().isEmpty ||
        _selectedStatus == null) {
      return false;
    }

    // Validate email format
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    return true;
  }

  // ✅ FIXED: Save driver using DriverService
  Future<void> _saveDriver() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all required fields correctly")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      print('🔄 Updating driver ${widget.driverId}...');
      print(
          '📤 Data: name=${nameController.text}, email=${emailController.text}, status=$_selectedStatus');

      final updatedDriver = await DriverService.updateDriver(
        id: widget.driverId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        licenseNumber: licenseController.text.trim(),
        vehiclePlate: vehicleController.text.trim(),
        status: _selectedStatus!,
        avatar: _isImageChanged && _imageBase64 != null ? _imageBase64 : null,
      );

      setState(() {
        _currentDriver = updatedDriver;
        _isSaving = false;
        _isImageChanged = false; // Reset image changed flag
      });

      print('✅ Driver updated successfully');
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      print('❌ Error updating driver: $e');
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
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context)
                    .pop(true); // Return to previous screen with success result
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ✅ NEW: Get status display name
  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'busy':
        return 'Busy';
      case 'inactive':
      default:
        return 'Inactive';
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
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading driver data',
                        style:
                            TextStyle(fontSize: 18, color: Colors.red.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchDriverData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
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
                                      Icons.edit,
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
                                    const Spacer(),
                                    if (_currentDriver != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                              _currentDriver!.status),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusDisplayName(
                                                  _currentDriver!.status)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Form Content
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Form Fields
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // ✅ FIXED: Status dropdown with correct options
                                          CustomDropdown(
                                            label: "Select Driver Status",
                                            title: "Status",
                                            items: const [
                                              "Active",
                                              "Inactive",
                                              "Busy"
                                            ],
                                            selectedItem: _getStatusDisplayName(
                                                _selectedStatus ?? 'inactive'),
                                            icon: Icons.account_circle,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedStatus =
                                                    value?.toLowerCase();
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
                                            keyboardType:
                                                TextInputType.emailAddress,
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
                                            label: "Enter license number",
                                            title: "License Number",
                                            icon: Icons.badge,
                                            controller: licenseController,
                                          ),
                                          CustomTextField(
                                            label: "Enter vehicle plate number",
                                            title: "Vehicle Plate",
                                            icon: Icons.directions_car,
                                            controller: vehicleController,
                                          ),

                                          const SizedBox(height: 24),

                                          // Save Button
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: _isSaving
                                                      ? null
                                                      : (_isFormValid()
                                                          ? _saveDriver
                                                          : null),
                                                  icon: _isSaving
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
                                                  label: Text(_isSaving
                                                      ? 'Updating...'
                                                      : 'Update Driver'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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

                                    // Profile Photo Section
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
                                            'Upload a profile picture (Recommended: 192×182)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Image Upload Area
                                          MouseRegion(
                                            onEnter: (_) => setState(
                                                () => _isHoveringUpload = true),
                                            onExit: (_) => setState(() =>
                                                _isHoveringUpload = false),
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
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.grey.shade300,
                                                    width: 2,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                                child: _buildImageWidget(),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 24),

                                          // Info Box
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                                      color:
                                                          Colors.blue.shade700,
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

  // ✅ NEW: Build image widget based on state
  Widget _buildImageWidget() {
    if (_imageBytes != null) {
      // Show newly selected image
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
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Change Photo',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        const Icon(Icons.delete, color: Colors.white, size: 18),
                    onPressed: () {
                      setState(() {
                        _imageBytes = null;
                        _imageBase64 = null;
                        _isImageChanged = true;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      // Show existing image from server
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _imageUrl!,
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
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Change Photo',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (isLoading) {
      // Show loading indicator
      return const Center(child: CircularProgressIndicator());
    } else {
      // Show upload placeholder
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
            'JPG, PNG or GIF (Max 5MB)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  // ✅ NEW: Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'busy':
        return const Color(0xFFFF9800); // Orange
      case 'inactive':
      default:
        return const Color(0xFF757575); // Grey
    }
  }
}
