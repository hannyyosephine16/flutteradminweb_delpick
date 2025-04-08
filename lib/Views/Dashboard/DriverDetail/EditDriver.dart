import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../Common/GlobalStyle.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class EditDriverScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();


  EditDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Fungsi kembali
          },
        ),
        title: const Text('Edit Driver', style: TextStyle(color: Colors.black)),
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
                            // icon2: Icons.location_on,
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              backgroundColor:GlobalStyle.buttonColor ,
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
                          TextButton(
                            onPressed: () async {
                              // Membuat input elemen file
                              final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                              uploadInput.accept = 'image/*'; // Hanya menerima gambar
                              uploadInput.click();

                              // Mendengarkan perubahan (file dipilih)
                              uploadInput.onChange.listen((e) async {
                                final files = uploadInput.files;
                                if (files!.isEmpty) {
                                  return;
                                }

                                // Mengambil file pertama yang dipilih
                                final file = files[0];
                                print("File name: ${file.name}");
                                print("File size: ${file.size}");

                                // Menampilkan pratinjau gambar
                                final reader = html.FileReader();
                                reader.readAsDataUrl(file);  // Membaca file sebagai URL
                                reader.onLoadEnd.listen((e) {
                                  // Menampilkan pratinjau gambar di layar
                                  final imageUrl = reader.result as String;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Image Preview"),
                                        content: Image.network(imageUrl),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                });
                              });
                            },
                            child: Text("Select and Preview Image"),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 215,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload, size: 40, color: Colors.black45),
                                  SizedBox(height: 8),
                                  Text('Browse to upload', style: TextStyle(color: Colors.black54)),
                                ],
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



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import '../../../Common/widgets/button/ButtonWidget.dart';
// import '../../../src/ApiService.dart';
//
// class EditCustomer extends StatefulWidget {
//   const EditCustomer({super.key});
//
//   @override
//   State<EditCustomer> createState() => EditCustomerState();
// }
//
// class EditCustomerState extends State<EditCustomer> {
//   final formKey = GlobalKey<FormState>();
//   String username = '';
//   String email = '';
//   String notelp = '';
//   String currpass = '';
//   String newpassword = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Edit Customer',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.blue,
//         elevation: 2,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop(); // Fungsi kembali
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               buildUsername(),
//               const SizedBox(height: 16),
//               buildEmail(),
//               const SizedBox(height: 16),
//               buildTelp(),
//               const SizedBox(height: 16),
//               buildCurrPass(),
//               const SizedBox(height: 16),
//               buildNewPass(),
//               const SizedBox(height: 32),
//               buildSubmitEdit(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Widget untuk input Username
//   Widget buildUsername() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'Username',
//       labelStyle: TextStyle(color: Colors.blue),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.grey[200],
//     ),
//     onChanged: (value) => setState(() => username = value),
//     validator: (value) {
//       if (value == null || value.isEmpty) {
//         return 'Username tidak boleh kosong';
//       }
//       if (value.length < 3) {
//         return 'Username harus lebih dari 3 karakter';
//       }
//       return null;
//     },
//     maxLength: 30,
//     onSaved: (value) => setState(() => username = value ?? ''),
//   );
//
//   // Widget untuk input Email
//   Widget buildEmail() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'Email',
//       labelStyle: TextStyle(color: Colors.blue),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.grey[200],
//     ),
//     validator: (value) {
//       final pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
//       final regExp = RegExp(pattern);
//
//       if (value!.isEmpty) {
//         return 'Enter an email';
//       } else if (!regExp.hasMatch(value)) {
//         return 'Enter a valid email';
//       } else {
//         return null;
//       }
//     },
//     keyboardType: TextInputType.emailAddress,
//     onSaved: (value) => setState(() => email = value ?? ''),
//   );
//
//   // Widget untuk input No. Telp
//   Widget buildTelp() => TextFormField(
//     decoration: InputDecoration(
//       labelText: 'No. Telp',
//       labelStyle: TextStyle(color: Colors.blue),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.grey[200],
//     ),
//     keyboardType: TextInputType.phone,
//     validator: (value) {
//       if (value == null || value.isEmpty) {
//         return 'Nomor telepon tidak boleh kosong';
//       }
//       if (value.length < 9) {
//         return 'Nomor telepon terlalu pendek';
//       }
//       return null;
//     },
//     onSaved: (value) => setState(() => notelp = value ?? ''),
//   );
//
//   // Widget untuk input Current Password
//   Widget buildCurrPass() => TextFormField(
//     obscureText: true,
//     decoration: InputDecoration(
//       labelText: 'Current Password',
//       labelStyle: TextStyle(color: Colors.blue),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.grey[200],
//     ),
//     onChanged: (value) => setState(() => currpass = value),
//     validator: (value) {
//       if (value == null || value.isEmpty) {
//         return 'Current password is required';
//       }
//       return null;
//     },
//     onSaved: (value) => setState(() => currpass = value ?? ''),
//   );
//
//   // Widget untuk input New Password
//   Widget buildNewPass() => TextFormField(
//     obscureText: true,
//     decoration: InputDecoration(
//       labelText: 'New Password (Leave empty to keep current password)',
//       labelStyle: TextStyle(color: Colors.blue),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.grey[200],
//     ),
//     onChanged: (value) => setState(() => newpassword = value),
//     onSaved: (value) => setState(() => newpassword = value ?? ''),
//   );
//
//   // Widget untuk tombol submit
//   Widget buildSubmitEdit() => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 16.0),
//     child: ButtonWidget(
//       key: Key('submit_button'),
//       text: 'Submit Edit',
//       onClicked: () {
//         final isValid = formKey.currentState!.validate();
//         if (isValid) {
//           formKey.currentState?.save();
//
//           // Verifikasi current password
//           ApiService.verifyCurrentPassword(currpass).then((isVerified) {
//             if (isVerified) {
//               ApiService.updateCustomer(username, email, notelp, currpass, newpassword).then((_) {
//                 final snackBar = SnackBar(
//                   content: Text('Customer berhasil diupdate!'),
//                   backgroundColor: Colors.green,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               }).catchError((error) {
//                 final snackBar = SnackBar(
//                   content: Text('Gagal mengupdate customer: $error'),
//                   backgroundColor: Colors.red,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
//               });
//             } else {
//               final snackBar = SnackBar(
//                 content: Text('Current password salah!'),
//                 backgroundColor: Colors.red,
//               );
//               ScaffoldMessenger.of(context).showSnackBar(snackBar);
//             }
//           }).catchError((error) {
//             final snackBar = SnackBar(
//               content: Text('Terjadi kesalahan saat memverifikasi password: $error'),
//               backgroundColor: Colors.red,
//             );
//             ScaffoldMessenger.of(context).showSnackBar(snackBar);
//           });
//         }
//       },
//     ),
//   );
// }
