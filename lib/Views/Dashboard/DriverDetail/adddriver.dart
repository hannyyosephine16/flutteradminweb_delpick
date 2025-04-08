import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

import '../../../Common/GlobalStyle.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewDriverScreen extends StatefulWidget {
  AddNewDriverScreen({super.key});

  @override
  _AddNewDriverScreenState createState() => _AddNewDriverScreenState();
}

class _AddNewDriverScreenState extends State<AddNewDriverScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  String? _filePreview;

  // Fungsi untuk memilih file
  Future<void> _pickFile() async {
    // Memilih file dengan FilePicker (di Web)
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Mengambil file yang dipilih
      html.File file = html.File(result.files!.first.bytes!, result.files!.first.name);
      final reader = html.FileReader();

      // Membaca file sebagai URL data untuk preview
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _filePreview = reader.result as String?;
        });
      });
    }
  }

  // Fungsi untuk menambahkan driver
  void addDriver(BuildContext context) {
    bool success = false;

    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        vehicleController.text.isNotEmpty) {
      success = true;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Failed'),
          content: Text(success
              ? 'Data has been successfully added.'
              : 'Failed to add data. Please check your input.'),
          actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Add New Driver', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdown(
                            label: "Select Role",
                            title: "Select Role",
                            items: const ["Admin", "Customer", "Store", "Driver"],
                            onChanged: (value) {
                              // Handle selection
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "nama",
                            title: "Nama",
                            controller: nameController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: "email",
                            title: "Email",
                            controller: emailController,
                          ),
                          CustomTextField(
                            label: "no telp",
                            title: "Phone Number",
                            controller: phoneController,
                          ),
                          CustomTextField(
                            label: "password",
                            title: "Password",
                            controller: passwordController,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              addDriver(context); // Menambahkan driver dan menampilkan popup
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              backgroundColor: GlobalStyle.buttonColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Add', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: "Nomor Kendaraan",
                            title: "Vehicle Number",
                            controller: vehicleController,
                          ),
                          const Text(
                            'Photo Images (Dimension: 192*182)',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickFile, // Menangani klik pada ikon untuk memilih file
                            child: Container(
                              height: 215,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: _filePreview == null
                                    ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 40, color: Colors.black45),
                                    SizedBox(height: 8),
                                    Text('Browse to upload', style: TextStyle(color: Colors.black54)),
                                  ],
                                )
                                    : Image.memory(base64Decode(_filePreview!.split(',').last)), // Menampilkan gambar dari URL data
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// import '../../../Common/GlobalStyle.dart';
// import '../../../Common/widgets/texts/customdropdownfield.dart';
// import '../../../Common/widgets/texts/customtextfield.dart';
//
// class AddNewDriverScreen extends StatelessWidget {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController vehicleController = TextEditingController();
//
//
//   AddNewDriverScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.of(context).pop(); // Fungsi kembali
//           },
//         ),
//         title: const Text('Add New Driver', style: TextStyle(color: Colors.black)),
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
//
//                   children: [
//                     // Left Section
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CustomDropdown(
//                             label: "Select Role",
//                             title: "Select Role",
//                             items: const ["Admin", "Customer", "Store", "Driver"],
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
//                             // icon2: Icons.location_on,
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
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6)
//                               ),
//                               backgroundColor:GlobalStyle.buttonColor ,
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
//                           Container(
//                             height: 215,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
//                               borderRadius: BorderRadius.circular(5),
//                               color: Colors.white,
//                             ),
//                             child: const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.cloud_upload, size: 40, color: Colors.black45),
//                                   SizedBox(height: 8),
//                                   Text('Browse to upload', style: TextStyle(color: Colors.black54)),
//                                 ],
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
