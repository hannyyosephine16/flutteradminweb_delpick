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
import '../../../Common/widgets/texts/customtextfield.dart';

class EditDriverScreen extends StatefulWidget {
  final DriverModel driver;

  const EditDriverScreen({
    super.key,
    required this.driver,
  });

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
  bool showPassword = false;
  Uint8List? _imageBytes;
  String? _imageBase64;
  String? _imageName;
  bool _isHoveringUpload = false;
  String selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // ✅ Initialize form fields with existing driver data
    nameController.text = widget.driver.displayName;
    emailController.text = widget.driver.displayEmail;
    phoneController.text = widget.driver.displayPhone;
    licenseController.text = widget.driver.licenseNumber;
    vehicleController.text = widget.driver.vehiclePlate;
    selectedStatus = widget.driver.status;

    // ✅ Set existing avatar if available
    if (widget.driver.displayAvatar.isNotEmpty) {
      // Note: We can't convert URL back to bytes, so we'll show a placeholder
      // The user can upload a new image if they want to change it
      print('Existing avatar URL: ${widget.driver.displayAvatar}');
    }
  }

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

        print('✅ New image selected and converted to base64');
      } else if (pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Image too large, please select an image smaller than 5MB!')),
        );
      }
    } catch (e) {
      print('❌ Error selecting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateDriver() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
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
      print('🔄 Updating driver ${widget.driver.id}...');
      print('   Name: ${nameController.text}');
      print('   Email: ${emailController.text}');
      print('   Phone: ${phoneController.text}');
      print('   License: ${licenseController.text}');
      print('   Vehicle: ${vehicleController.text}');
      print('   Status: $selectedStatus');
      print('   New Image: ${_imageBase64 != null}');

      final updatedDriver = await DriverService.updateDriver(
        id: widget.driver.id.toString(),
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        licenseNumber: licenseController.text,
        vehiclePlate: vehicleController.text,
        status: selectedStatus,
        avatar: _imageBase64, // Only send if new image is selected
      );

      print('✅ Driver updated successfully: ${updatedDriver.displayName}');

      _showSuccessDialog();

      // Return the updated driver to previous screen
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop(updatedDriver);
      });
    } catch (e) {
      print('❌ Error updating driver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update driver: $e'),
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
          content: const Text('Driver updated successfully!'),
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

  Widget _buildCurrentAvatar() {
    if (_imageBytes != null) {
      // Show new selected image
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (widget.driver.displayAvatar.isNotEmpty) {
      // Show existing avatar URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.driver.displayAvatar.startsWith('http')
              ? widget.driver.displayAvatar
              : 'https://delpick.horas-code.my.id${widget.driver.displayAvatar}',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey.shade400,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      // Show placeholder
      return Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.grey.shade400,
        ),
      );
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
        title: Text(
          'Edit Driver - ${widget.driver.displayName}',
          style: const TextStyle(
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
                            Icons.edit,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Driver Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.driver.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.driver.isActive
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Current: ${widget.driver.statusDisplay}',
                              style: TextStyle(
                                color: widget.driver.isActive
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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

                                // ✅ Status Dropdown
                                const SizedBox(height: 16),
                                const Text(
                                  'Driver Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedStatus,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      prefixIcon: Icon(Icons.info_outline),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'active',
                                        child: Text('Active'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text('Inactive'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'busy',
                                        child: Text('Busy'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedStatus = value;
                                        });
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            isLoading ? null : _updateDriver,
                                        icon: isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ))
                                            : const Icon(Icons.update),
                                        label: Text(isLoading
                                            ? 'Updating...'
                                            : 'Update Driver'),
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
                                  'Upload a new profile picture (Optional)',
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
                                      child: (_imageBytes != null ||
                                              widget.driver.displayAvatar
                                                  .isNotEmpty)
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                _buildCurrentAvatar(),
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
                                                        Text(
                                                          _imageBytes != null
                                                              ? 'Change Photo'
                                                              : 'Update Photo',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        if (_imageBytes !=
                                                            null) ...[
                                                          const Spacer(),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.white,
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
                                      'New image selected: ${(_imageBytes!.lengthInBytes / 1024).toStringAsFixed(2)} KB',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade600,
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
                                          'Leave photo unchanged if you don\'t want to update it. Only upload a new photo if you want to change the current one.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ✅ Driver Info Summary
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Driver Information',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ID: ${widget.driver.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Rating: ${widget.driver.ratingWithStars}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Reviews: ${widget.driver.reviewsDisplay}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Created: ${widget.driver.createdAtDisplay}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    vehicleController.dispose();
    super.dispose();
  }
}
