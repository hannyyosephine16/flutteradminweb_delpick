import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get_connect/http/src/http/html/file_decoder_html.dart';
import 'package:web/helpers.dart' as html;
// import 'package:get/get_connect/http/src/multipart/form_data.dart';
// import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
// import 'package:web/web.dart';
import '../../../Common/widgets/button/ButtonWidget.dart';
import '../../../src/ApiService.dart';


class NewCustomer extends StatefulWidget {
  const NewCustomer({super.key});

  @override
  State<NewCustomer> createState() => NewCustomerState();
}

class NewCustomerState extends State<NewCustomer> {
  final formKey = GlobalKey<FormState>();
  File? file;
  String username = '';
  String email = '';
  String notelp = '';
  String currpass = '';
  String newpassword = '';
  Uint8List? _imageBytes; // Untuk gambar web

  bool isUploadSuccess = false;
  double opacity = 0.0;

  void _convertFileToBytes(html.File webFile) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(webFile);
    reader.onLoadEnd.listen((e) {
      if (reader.result != null) {
        _imageBytes = reader.result as Uint8List;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Customer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Tombol back dengan warna putih
          onPressed: () {
            Navigator.of(context).pop(); // Fungsi kembali
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUsername(),
              const SizedBox(height: 16),
              buildEmail(),
              const SizedBox(height: 16),
              buildTelp(),
              const SizedBox(height: 16),
              buildNewPass(),
              const SizedBox(height: 32),
              buildUpload(),
              const SizedBox(height: 32),
              buildSubmit(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk input username
  Widget buildUsername() => TextFormField(
    decoration: InputDecoration(
      labelText: 'Username',
      labelStyle: TextStyle(color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    onChanged: (value) => setState(() => username = value),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Username tidak boleh kosong';
      }
      if (value.length < 3) {
        return 'Username harus lebih dari 3 karakter';
      }
      return null;
    },
    maxLength: 30,
    onSaved: (value) => setState(() => username = value ?? ''),
  );

  // Widget untuk input email
  Widget buildEmail() => TextFormField(
    decoration: InputDecoration(
      labelText: 'Email',
      labelStyle: TextStyle(color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    validator: (value) {
      final pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
      final regExp = RegExp(pattern);

      if (value!.isEmpty) {
        return 'Enter an email';
      } else if (!regExp.hasMatch(value)) {
        return 'Enter a valid email';
      } else {
        return null;
      }
    },
    keyboardType: TextInputType.emailAddress,
    onSaved: (value) => setState(() => email = value ?? ''),
  );

  // Widget untuk input nomor telp
  Widget buildTelp() => TextFormField(
    decoration: InputDecoration(
      labelText: 'No. Telp',
      labelStyle: TextStyle(color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    keyboardType: TextInputType.phone,
    onSaved: (value) => setState(() => notelp = value ?? ''),
  );

  // Widget untuk input password baru
  Widget buildNewPass() => TextFormField(
    obscureText: true,
    decoration: InputDecoration(
      labelText: 'New Password',
      labelStyle: TextStyle(color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    onChanged: (value) => setState(() => newpassword = value),
    onSaved: (value) => setState(() => newpassword = value ?? ''),
  );

  // Widget untuk submit button
  Widget buildSubmit() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: ButtonWidget(
      key: Key('submit_button'),
      text: 'Submit',
      onClicked: () async {
        final isValid = formKey.currentState!.validate();
        if (isValid) {
          formKey.currentState?.save();

          // Kirim data customer ke API
          try {
            await ApiService.createCustomer(username, email, notelp, newpassword);

            // Cek jika ada file gambar
            if (file != null) {
              final dio = Dio();
              final formData = FormData.fromMap({
                'username': username,
                'email': email,
                'phone': notelp,
                'password': newpassword,
                'file': await MultipartFile.fromFile(file!.path),
              });

              final response = await dio.post("https://delpick.fun/api/v1/auth/register", data: formData);
              log("$response");

              final snackBar = SnackBar(
                content: Text('Customer created and image uploaded successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              final snackBar = SnackBar(
                content: Text('Please select an image to upload'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } catch (error) {
            final snackBar = SnackBar(
              content: Text('Failed to create customer: $error'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      },
    ),
  );

  // Widget untuk upload gambar
  Widget buildUpload() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (file != null)
        ...[
          if (foundation.kIsWeb)
            _imageBytes != null
                ? Image.memory(
              _imageBytes!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : Container() // Gambar kosong jika belum tersedia
          else
            Image.file(
              file!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ElevatedButton(
            onPressed: () async {
              if (file == null) {
                final snackBar = SnackBar(
                  content: Text('Please select an image to upload'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              try {
                final dio = Dio();
                final formData = FormData.fromMap({
                  'file': foundation.kIsWeb
                      ? await MultipartFile.fromBytes(_imageBytes!) // Web, gunakan bytes
                      : await MultipartFile.fromFile(file!.path), // Mobile, gunakan File
                });

                final response = await dio.post("https://delpick.fun/api/v1/auth/register", data: formData, onSendProgress: (count, total) {
                  log("${(count / total) * 100}");
                });

                log("$response");

                setState(() {
                  isUploadSuccess = true;
                  opacity = 1.0;
                });

                final snackBar = SnackBar(
                  content: Text('Image uploaded successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } catch (error) {
                setState(() {
                  isUploadSuccess = false;
                  opacity = 0.0;
                });

                final snackBar = SnackBar(
                  content: Text('Upload failed: $error'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Text("Upload Image"),
          ),
          AnimatedOpacity(
            opacity: opacity,
            duration: Duration(seconds: 1),
            child: isUploadSuccess
                ? Icon(Icons.check_circle, color: Colors.green, size: 40)
                : Container(),
          ),
        ]
      else
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final result = await picker.pickImage(source: ImageSource.gallery);

            if (result == null) {
              return;
            }

            setState(() {
              file = File(result.path!);
              if (foundation.kIsWeb) {
                _convertFileToBytes(file! as html.File);
              }
            });
          },
          child: Text("Choose Image"),
        ),
    ],
  );

  Widget Upload() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (file != null)
        ...[
          if (foundation.kIsWeb)
            _imageBytes != null
                ? Image.memory(
              _imageBytes!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : Container() // Gambar kosong jika belum tersedia
          else
            Image.file(
              file!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ElevatedButton(
            onPressed: () async {
              if (file == null) {
                final snackBar = SnackBar(
                  content: Text('Please select an image to upload'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              try {
                final dio = Dio();
                final formData = FormData.fromMap({
                  'file': await MultipartFile.fromFile(file!.path),
                });

                final response = await dio.post("https://api/yourapi", data: formData, onSendProgress: (count, total) {
                  log("${(count / total) * 100}");
                });

                log("$response");
                setState(() {
                  isUploadSuccess = true; // Menandakan upload berhasil
                  opacity = 1.0; // Mengubah opacity untuk animasi
                });

                final snackBar = SnackBar(
                  content: Text('Image uploaded successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } catch (error) {
            //     final snackBar = SnackBar(
            //       content: Text('Upload failed: $error'),
            //       backgroundColor: Colors.red,
            //       duration: Duration(seconds: 2),
            //     );
            //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //   }
            // },
                setState(() {
                  isUploadSuccess = false; // Reset status upload
                  opacity = 0.0; // Reset opacity jika upload gagal
                });

                final snackBar = SnackBar(
                  content: Text('Upload failed: $error'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Text("Upload Image"),
          ),
          AnimatedOpacity(
            opacity: opacity,
            duration: Duration(seconds: 1),
            child: isUploadSuccess
                ? Icon(Icons.check_circle, color: Colors.green, size: 40) // Ikon sukses
                : Container(), // Tidak menampilkan ikon jika gagal
          ),
        ]
      else
        ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final result = await picker.pickImage(source: ImageSource.gallery);

            if (result == null) {
              return;
            }

            setState(() {
              file = File(result.path!);
              if (foundation.kIsWeb) {
                _convertFileToBytes(file! as html.File);
              }
            });
          },
          child: Text("Choose Image"),
        ),
    ],
  );
}
