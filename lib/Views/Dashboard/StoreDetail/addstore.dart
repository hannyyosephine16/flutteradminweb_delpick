import 'package:flutter/material.dart';

import '../../../Common/GlobalStyle.dart';
import '../../../Common/widgets/texts/customdropdownfield.dart';
import '../../../Common/widgets/texts/customtextfield.dart';

class AddNewStoreScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();


  AddNewStoreScreen({super.key});

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
        title: const Text('Add New Store', style: TextStyle(color: Colors.black)),
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
                          const Text(
                            'Photo Images (Dimension: 192*182)',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
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



