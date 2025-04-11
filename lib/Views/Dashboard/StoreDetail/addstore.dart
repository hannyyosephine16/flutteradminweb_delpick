import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

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

  String? selectedRole;
  bool isLoading = false;
  bool showPassword = false;

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isHoveringUpload = false;

  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          _imageBytes = pickedImage;
          _imageName = 'profile_image.jpg'; // You can get actual name with proper plugin
        });
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveStore() {
    // Validation logic
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // TODO: Implement API call to save Store data

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    addressController.clear();
    setState(() {
      selectedRole = null;
      _imageBytes = null;
      _imageName = null;
    });
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
                            Icons.person_add,
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
                                CustomDropdown(
                                  label: "Select User Role",
                                  title: "Role",
                                  items: const ["Admin", "Store", "Owner", "Store"],
                                  selectedItem: selectedRole,
                                  icon: Icons.admin_panel_settings,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRole = value;
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
                                  label: "Enter password",
                                  title: "Password",
                                  icon: Icons.lock,
                                  obscureText: !showPassword,
                                  icon2: showPassword ? Icons.visibility : Icons.visibility_off,
                                  controller: passwordController,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _saveStore,
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
                                  icon: Icons.pin_drop,
                                  controller: addressController,
                                ),
                                CustomTextField(
                                  label: "Description Store",
                                  title: "Description",
                                  icon: Icons.motorcycle,
                                  controller: addressController,
                                ),
                                CustomTextField(
                                  label: "Open Time",
                                  title: "Open Time",
                                  icon: Icons.lock_clock,
                                  controller: addressController,
                                ),
                                CustomTextField(
                                  label: "Description Store",
                                  title: "Description",
                                  icon: Icons.lock_clock,
                                  controller: addressController,
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
                                                        _imageName = null;
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

                                if (_imageName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      'File: $_imageName',
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
                                          'Adding a clear profile photo helps with Store identification and improves the user experience.',
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
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'dart:convert';
//
// import '../../../Common/GlobalStyle.dart';
// import '../../../Common/widgets/texts/customdropdownfield.dart';
// import '../../../Common/widgets/texts/customtextfield.dart';
//
// class AddNewStoreScreen extends StatefulWidget {
//   AddNewStoreScreen({super.key});
//
//   @override
//   _AddNewStoreScreenState createState() => _AddNewStoreScreenState();
// }
//
// class _AddNewStoreScreenState extends State<AddNewStoreScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController vehicleController = TextEditingController();
//   String? _filePreview;
//
//   // Fungsi untuk memilih file
//   Future<void> _pickFile() async {
//     // Memilih file dengan FilePicker (di Web)
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//     if (result != null) {
//       // Mengambil file yang dipilih
//       html.File file = html.File(result.files!.first.bytes!, result.files!.first.name);
//       final reader = html.FileReader();
//
//       // Membaca file sebagai URL data untuk preview
//       reader.readAsDataUrl(file);
//       reader.onLoadEnd.listen((e) {
//         setState(() {
//           _filePreview = reader.result as String?;
//         });
//       });
//     }
//   }
//
//   // Fungsi untuk menambahkan Store
//   void addStore(BuildContext context) {
//     bool success = false;
//
//     if (nameController.text.isNotEmpty &&
//         emailController.text.isNotEmpty &&
//         phoneController.text.isNotEmpty &&
//         passwordController.text.isNotEmpty &&
//         vehicleController.text.isNotEmpty) {
//       success = true;
//     }
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(success ? 'Success' : 'Failed'),
//           content: Text(success
//               ? 'Data has been successfully added.'
//               : 'Failed to add data. Please check your input.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
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
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: const Text('Add New Store', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               color: Colors.white,
//               elevation: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(13.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Left Section
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomDropdown(
//                             label: "Select Role",
//                             title: "Select Role",
//                             items: const ["Admin", "Store", "Store", "Store"],
//                             onChanged: (value) {
//                               // Handle selection
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           CustomTextField(
//                             label: "nama",
//                             title: "Nama",
//                             controller: nameController,
//                           ),
//                           const SizedBox(height: 16),
//                           CustomTextField(
//                             label: "email",
//                             title: "Email",
//                             controller: emailController,
//                           ),
//                           CustomTextField(
//                             label: "no telp",
//                             title: "Phone Number",
//                             controller: phoneController,
//                           ),
//                           CustomTextField(
//                             label: "password",
//                             title: "Password",
//                             controller: passwordController,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () {
//                               addStore(context); // Menambahkan Store dan menampilkan popup
//                             },
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6)),
//                               backgroundColor: GlobalStyle.buttonColor,
//                               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                             ),
//                             child: const Text('Add', style: TextStyle(color: Colors.white)),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(width: 16),
//
//                     // Right Section
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomTextField(
//                             label: "Nomor Kendaraan",
//                             title: "Vehicle Number",
//                             controller: vehicleController,
//                           ),
//                           const Text(
//                             'Photo Images (Dimension: 192*182)',
//                             style: TextStyle(fontSize: 14, color: Colors.black54),
//                           ),
//                           const SizedBox(height: 8),
//                           GestureDetector(
//                             onTap: _pickFile, // Menangani klik pada ikon untuk memilih file
//                             child: Container(
//                               height: 215,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
//                                 borderRadius: BorderRadius.circular(5),
//                                 color: Colors.white,
//                               ),
//                               child: Center(
//                                 child: _filePreview == null
//                                     ? const Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.cloud_upload, size: 40, color: Colors.black45),
//                                     SizedBox(height: 8),
//                                     Text('Browse to upload', style: TextStyle(color: Colors.black54)),
//                                   ],
//                                 )
//                                     : Image.memory(base64Decode(_filePreview!.split(',').last)), // Menampilkan gambar dari URL data
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// //
// // import '../../../Common/GlobalStyle.dart';
// // import '../../../Common/widgets/texts/customdropdownfield.dart';
// // import '../../../Common/widgets/texts/customtextfield.dart';
// //
// // class AddNewStoreScreen extends StatelessWidget {
// //   final TextEditingController nameController = TextEditingController();
// //   final TextEditingController emailController = TextEditingController();
// //   final TextEditingController phoneController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   final TextEditingController vehicleController = TextEditingController();
// //
// //
// //   AddNewStoreScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () {
// //             Navigator.of(context).pop(); // Fungsi kembali
// //           },
// //         ),
// //         title: const Text('Add New Store', style: TextStyle(color: Colors.black)),
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Card(
// //               color: Colors.white,
// //               elevation: 2,
// //               child: Padding(
// //                 padding: const EdgeInsets.all(13.0),
// //                 child: Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //
// //                   children: [
// //                     // Left Section
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           CustomDropdown(
// //                             label: "Select Role",
// //                             title: "Select Role",
// //                             items: const ["Admin", "Store", "Store", "Store"],
// //                             onChanged: (value) {
// //                               // Handle selection
// //                             },
// //                           ),
// //                           const SizedBox(height: 16),
// //                           CustomTextField(
// //                             label: "nama",
// //                             title: "Nama",
// //                             controller: nameController,
// //                           ),
// //                           const SizedBox(height: 16),
// //                           CustomTextField(
// //                             label: "email",
// //                             title: "Email",
// //                             // icon2: Icons.location_on,
// //                             controller: emailController,
// //                           ),
// //                           CustomTextField(
// //                             label: "no telp",
// //                             title: "Phone Number",
// //                             controller: phoneController,
// //                           ),
// //                           CustomTextField(
// //                             label: "password",
// //                             title: "Password",
// //                             controller: passwordController,
// //                           ),
// //                           const SizedBox(height: 16),
// //                           ElevatedButton(
// //                             onPressed: () {},
// //                             style: ElevatedButton.styleFrom(
// //                               shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(6)
// //                               ),
// //                               backgroundColor:GlobalStyle.buttonColor ,
// //                               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
// //                             ),
// //                             child: const Text('Add', style: TextStyle(color: Colors.white)),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     const SizedBox(width: 16),
// //
// //                     // Right Section
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           CustomTextField(
// //                             label: "Nomor Kendaraan",
// //                             title: "Vehicle Number",
// //                             controller: vehicleController,
// //                           ),
// //                           const Text(
// //                             'Photo Images (Dimension: 192*182)',
// //                             style: TextStyle(fontSize: 14, color: Colors.black54),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Container(
// //                             height: 215,
// //                             decoration: BoxDecoration(
// //                               border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
// //                               borderRadius: BorderRadius.circular(5),
// //                               color: Colors.white,
// //                             ),
// //                             child: const Center(
// //                               child: Column(
// //                                 mainAxisAlignment: MainAxisAlignment.center,
// //                                 children: [
// //                                   Icon(Icons.cloud_upload, size: 40, color: Colors.black45),
// //                                   SizedBox(height: 8),
// //                                   Text('Browse to upload', style: TextStyle(color: Colors.black54)),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
