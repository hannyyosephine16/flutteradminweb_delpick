import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:delpick_admin/src/CustomerService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart' as http;
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';
import '../../../src/ApiService.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({super.key});

  @override
  State<AddNewCustomerScreen> createState() => _AddNewCustomerScreenState();
}

class _AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();

  // String? selectedRole;
  bool isLoading = false;
  bool showPassword = false;

  Uint8List? _imageBytes;
  String? _imageBase64;
  bool _isHoveringUpload = false;

  bool _isFormValid() {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  // Fungsi untuk menyimpan customer
  // Future<void> _saveCustomer() async {
  //   if (nameController.text.isEmpty ||
  //       emailController.text.isEmpty ||
  //       phoneController.text.isEmpty ||
  //       passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Semua kolom harus diisi!')),
  //     );
  //     return;
  //   }
  //
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Memanggil ApiService.createCustomer dengan data yang diambil dari form
  //     final response = await CustomerService.createCustomer(
  //       nameController.text,
  //       emailController.text,
  //       phoneController.text,
  //       passwordController.text,
  //       _imageBase64  // Sertakan gambar base64
  //     );
  //
  //     if (response != null) {
  //       // Jika berhasil menambah customer, tampilkan popup
  //       _showSuccessDialog();
  //       // Reset form
  //       nameController.clear();
  //       emailController.clear();
  //       phoneController.clear();
  //       passwordController.clear();
  //       setState(() {
  //         // _imageBase64 = null; // Reset gambar setelah berhasil
  //         _imageBase64 = null;
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Gagal menambahkan customer')),
  //       );
  //     }
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Terjadi kesalahan: $error')),
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }  // Function to show the success dialog
  // Fungsi _pickImage() yang diperbaiki
  //region Pick Images version 1
  Future<void> _pickImage1() async {
    setState(() {
      isLoading = true;
    });

    try {
      final pickedImage = await ImagePickerWeb.getImageAsBytes();

      if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) { // 5MB
        // Konversi ke base64 dan tambahkan prefix yang sesuai
        final base64String = base64Encode(pickedImage);
        // Tentukan format gambar (umumnya JPEG)
        final imageBase64WithPrefix = 'data:image/jpeg;base64,' + base64String;

        setState(() {
          _imageBytes = pickedImage;  // Simpan bytes untuk ditampilkan
          _imageBase64 = imageBase64WithPrefix;  // Base64 dengan prefix yang sesuai untuk backend
        });

        print('Gambar berhasil dikonversi ke base64 dengan prefix');
      } else if (pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar terlalu besar, pilih gambar yang lebih kecil dari 5MB!')),
        );
      }
    } catch (e) {
      print('Error saat memilih gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memilih gambar: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  //endregion

  //region Pick Image Version 2
//   Future<void> _pickImage() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       // Using ImagePickerWeb to get the image bytes
//       final pickedImage = await ImagePickerWeb.getImageAsBytes();
//
//       if (pickedImage != null && pickedImage.lengthInBytes < 5 * 1024 * 1024) { // 5MB limit
//         // Detect content type from bytes
//         String contentType = _detectContentType(pickedImage);
//
//         // Convert to base64
//         final base64String = base64Encode(pickedImage);
//
//         // Create the complete data URI with proper content type
//         final imageBase64WithPrefix = 'data:$contentType;base64,' + base64String;
//
//         setState(() {
//           _imageBytes = pickedImage;  // Save bytes for display
//           _imageBase64 = imageBase64WithPrefix;  // Base64 with prefix for backend
//         });
//
//         // Detailed logs for debugging
//         print('Gambar berhasil dikonversi ke base64');
//         print('Content type: $contentType');
//         print('Ukuran gambar: ${(pickedImage.lengthInBytes / 1024).toStringAsFixed(2)} KB');
//         print('Base64 prefix: ${_imageBase64!.substring(0, _imageBase64!.length > 50 ? 50 : _imageBase64!.length)}...');
//
//         // Success message for user
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Gambar berhasil diunggah'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       } else if (pickedImage == null) {
//         print('Tidak ada gambar yang dipilih');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Tidak ada gambar yang dipilih'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       } else {
//         print('Gambar terlalu besar: ${(pickedImage.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Gambar terlalu besar, pilih gambar yang lebih kecil dari 5MB!'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error saat memilih gambar: $e');
//       String errorMessage = 'Error saat memilih gambar';
//
//       // More specific error messages based on the type of error
//       if (e.toString().contains('permission')) {
//         errorMessage = 'Tidak mendapatkan izin untuk mengakses file';
//       } else if (e.toString().contains('canceled')) {
//         errorMessage = 'Pemilihan gambar dibatalkan';
//       } else if (e.toString().contains('format') || e.toString().contains('decode')) {
//         errorMessage = 'Format gambar tidak didukung';
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
// // Helper function to detect content type based on file signatures
//   String _detectContentType(Uint8List bytes) {
//     if (bytes.length < 4) {
//       print('Byte array terlalu kecil untuk mendeteksi format, defaulting ke image/jpeg');
//       return 'image/jpeg'; // Default if not enough bytes to check
//     }
//
//     // Check for PNG signature: 89 50 4E 47 (hex) / 137 80 78 71 (decimal)
//     if (bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71) {
//       print('Tanda tangan PNG terdeteksi');
//       return 'image/png';
//     }
//
//     // Check for JPEG signature: FF D8 FF (hex) / 255 216 255 (decimal)
//     if (bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255) {
//       print('Tanda tangan JPEG terdeteksi');
//       return 'image/jpeg';
//     }
//
//     // Check for GIF signature: 47 49 46 38 (hex) / 71 73 70 56 (decimal)
//     if (bytes[0] == 71 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 56) {
//       print('Tanda tangan GIF terdeteksi');
//       return 'image/gif';
//     }
//
//     // Check for WEBP signature: 52 49 46 46 (hex) / 82 73 70 70 (decimal) at position 0
//     // and 57 45 42 50 (hex) / 87 69 66 80 (decimal) at position 8
//     if (bytes.length >= 12 &&
//         bytes[0] == 82 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 70 &&
//         bytes[8] == 87 && bytes[9] == 69 && bytes[10] == 66 && bytes[11] == 80) {
//       print('Tanda tangan WEBP terdeteksi');
//       return 'image/webp';
//     }
//
//     // Check for BMP signature: 42 4D (hex) / 66 77 (decimal)
//     if (bytes[0] == 66 && bytes[1] == 77) {
//       print('Tanda tangan BMP terdeteksi');
//       return 'image/bmp';
//     }
//
//     // Default to JPEG if format cannot be determined
//     print('Format gambar tidak terdeteksi, defaulting ke image/jpeg');
//     return 'image/jpeg';
//   }
  //endregion

  // Fungsi untuk web yang harus dimodifikasi agar kompatibel dengan mobile
  Future<String> webImageToBase64(Uint8List imageBytes) async {
    try {
      // Detect content type dengan cara yang sama seperti di _detectContentType
      String contentType = _detectContentType(imageBytes);

      // Encode ke base64 dengan format yang konsisten
      String base64String = base64Encode(imageBytes);

      // Pastikan tidak ada line breaks di base64 string
      base64String = base64String.replaceAll('\n', '').replaceAll('\r', '');

      // Pastikan padding = benar
      if (base64String.length % 4 > 0) {
        base64String = base64String.padRight(
            base64String.length + (4 - base64String.length % 4), '=');
      }

      // Buat data URL yang konsisten
      return 'data:$contentType;base64,$base64String';
    } catch (e) {
      print('Error converting web image to base64: $e');
      return '';
    }
  }

// Fungsi untuk debugging
  void checkBase64DataUrl(String dataUrl) {
    try {
      if (!dataUrl.startsWith('data:')) {
        print('WARNING: Not a valid data URL');
        return;
      }

      // Extract the base64 part
      final parts = dataUrl.split(',');
      if (parts.length != 2) {
        print('WARNING: Invalid data URL format');
        return;
      }

      final header = parts[0];
      final base64Data = parts[1];

      print('Header: $header');
      print('Base64 length: ${base64Data.length}');
      print('First 20 chars: ${base64Data.substring(0, 20 < base64Data.length ? 20 : base64Data.length)}');

      // Check if base64 is valid
      try {
        final decoded = base64Decode(base64Data);
        print('Successfully decoded ${decoded.length} bytes');
      } catch (e) {
        print('ERROR: Base64 cannot be decoded: $e');
      }
    } catch (e) {
      print('Error checking base64: $e');
    }
  }

// Implementasi fungsi _detectContentType untuk mendeteksi format gambar
  String _detectContentType(Uint8List bytes) {
    if (bytes.length < 4) {
      print('Byte array terlalu kecil untuk mendeteksi format, default ke image/jpeg');
      return 'image/jpeg'; // Default jika tidak cukup bytes untuk diperiksa
    }

    // Cek signature PNG: 89 50 4E 47 (hex) / 137 80 78 71 (decimal)
    if (bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71) {
      print('Tanda tangan PNG terdeteksi');
      return 'image/png';
    }

    // Cek signature JPEG: FF D8 FF (hex) / 255 216 255 (decimal)
    if (bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255) {
      print('Tanda tangan JPEG terdeteksi');
      return 'image/jpeg';
    }

    // Cek signature GIF: 47 49 46 38 (hex) / 71 73 70 56 (decimal)
    if (bytes[0] == 71 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 56) {
      print('Tanda tangan GIF terdeteksi');
      return 'image/gif';
    }

    // Cek signature WEBP: 52 49 46 46 (hex) / 82 73 70 70 (decimal) di posisi 0
    // dan 57 45 42 50 (hex) / 87 69 66 80 (decimal) di posisi 8
    if (bytes.length >= 12 &&
        bytes[0] == 82 && bytes[1] == 73 && bytes[2] == 70 && bytes[3] == 70 &&
        bytes[8] == 87 && bytes[9] == 69 && bytes[10] == 66 && bytes[11] == 80) {
      print('Tanda tangan WEBP terdeteksi');
      return 'image/webp';
    }

    // Cek signature BMP: 42 4D (hex) / 66 77 (decimal)
    if (bytes[0] == 66 && bytes[1] == 77) {
      print('Tanda tangan BMP terdeteksi');
      return 'image/bmp';
    }

    // Default ke JPEG jika format tidak dapat ditentukan
    print('Format gambar tidak terdeteksi, default ke image/jpeg');
    return 'image/jpeg';
  }

// Implementasi fungsi _pickImage yang berfungsi di web
  Future<void> _pickImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('======= IMAGE PICKING PROCESS STARTED =======');
      final pickedImage = await ImagePickerWeb.getImageAsBytes();

      if (pickedImage != null) {
        print('Image picked successfully');
        print('Image size: ${(pickedImage.lengthInBytes / 1024).toStringAsFixed(2)} KB');

        if (pickedImage.lengthInBytes < 5 * 1024 * 1024) {
          // Detect content type
          String contentType = _detectContentType(pickedImage);
          print('Detected content type: $contentType');

          // Show first few bytes for debugging
          print('First 8 bytes: ${pickedImage.take(8).toList()}');

          // Encode to base64
          String base64String = base64Encode(pickedImage);
          print('Base64 encoding completed');
          print('Base64 string length: ${base64String.length} characters');
          print('Base64 sample (first 50 chars): ${base64String.substring(0, min(50, base64String.length))}');

          // Check base64 validity
          try {
            final decodedTest = base64Decode(base64String);
            print('Base64 validation: SUCCESS - Can be decoded back (${decodedTest.length} bytes)');

            if (decodedTest.length == pickedImage.length) {
              print('Size check: MATCHED - Original and decoded sizes match');
            } else {
              print('Size check: MISMATCH - Original: ${pickedImage.length}, Decoded: ${decodedTest.length}');
            }
          } catch (e) {
            print('Base64 validation: FAILED - Cannot be decoded: $e');
          }

          // Create complete data URL
          final imageBase64WithPrefix = 'data:$contentType;base64,$base64String';
          print('Complete data URL (first 60 chars): ${imageBase64WithPrefix.substring(0, min(60, imageBase64WithPrefix.length))}...');

          // Check data URL format
          if (imageBase64WithPrefix.startsWith('data:image/') && imageBase64WithPrefix.contains(';base64,')) {
            print('Data URL format: VALID');
          } else {
            print('Data URL format: INVALID - Does not match expected pattern');
          }

          setState(() {
            _imageBytes = pickedImage;
            _imageBase64 = imageBase64WithPrefix;
          });

          // Call the debug function to deeply analyze the data URL
          print('\n======= DETAILED DATA URL ANALYSIS =======');
          checkBase64DataUrl(imageBase64WithPrefix);

          // Visual feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar berhasil diunggah'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Image too large: ${(pickedImage.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB (exceeds 5MB limit)');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar terlalu besar, pilih gambar yang lebih kecil dari 5MB!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('No image selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada gambar yang dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('ERROR during image picking process: $e');
      print('Stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
      print('======= IMAGE PICKING PROCESS COMPLETED =======\n');
    }
  }

// Fungsi _saveCustomer() dengan debugging yang ditingkatkan
  Future<void> _saveCustomer() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Debug: periksa apakah gambar dalam format yang benar
      if (_imageBase64 != null) {
        print('Format base64 gambar: ${_imageBase64!.substring(0, 30)}...'); // Tampilkan awal string saja
        if (!_imageBase64!.startsWith('data:image/')) {
          print('Warning: Format base64 gambar tidak dimulai dengan "data:image/"');
        }
      } else {
        print('Tidak ada gambar yang dipilih');
      }

      // Memanggil CustomerService.createCustomer dengan data yang diambil dari form
      final response = await CustomerService.createCustomer(
          nameController.text,
          emailController.text,
          phoneController.text,
          passwordController.text,
          _imageBase64  // Kirim base64 dengan prefix
      );

      print('Response dari server: $response');

      if (response != null) {
        // Jika berhasil menambah customer, tampilkan popup
        _showSuccessDialog();
        // Reset form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        setState(() {
          _imageBytes = null; // Reset gambar setelah berhasil
          _imageBase64 = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan customer')),
        );
      }
    } catch (error) {
      print('Error saat menyimpan customer: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $error')),
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
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Customer berhasil ditambahkan!'),
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
                                        onPressed: _isFormValid() ? _saveCustomer : null,
                                        // onPressed: _showSuccessDialog,
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Add Customer'),
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
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
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
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Foto telah dihapus'),
                                                          backgroundColor: Colors.orange,
                                                          duration: Duration(seconds: 2),
                                                        ),
                                                      );
                                                    },
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                    tooltip: 'Hapus Foto',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          : isLoading
                                          ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Memproses gambar...',
                                              style: TextStyle(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : Column(
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
                                            'JPG, PNG, GIF or BMP (Max 5MB)',
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

                                if (_imageBase64 != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
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