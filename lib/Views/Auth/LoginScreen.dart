import 'package:flutter/material.dart';
import 'package:delpick_admin/src/ApiService.dart'; // Import your API service
import 'package:delpick_admin/Views/Auth/LoginScreen.dart';

import '../Dashboard/Dashboard.dart'; // Import your Dashboard page

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue, // Replace with your GlobalStyle.buttonColor
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delpick',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Welcome to Delpick Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'You could be adding any information as admin',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Right Side: Login Form Section
                Expanded(
                  flex: 1,
                  child: _buildLoginForm(context), // Pass context here
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.blue, // Replace with your GlobalStyle.buttonColor
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Welcome Admin Delpick',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'U could be change anything at here',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildLoginForm(context), // Pass context here
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Login Form Widget
  Widget _buildLoginForm(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Replace with your GlobalStyle.buttonColor
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _login(context, emailController.text, passwordController.text),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle login
  Future<void> _login(BuildContext context, String email, String password) async {
    try {
      // Call your login API
      var response = await ApiService.loginAdmin(email, password);
      if (response != null) {
        // Navigate to the Dashboard if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        // Handle unsuccessful login
        print("Login failed!");
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }
}

// import 'package:flutter/material.dart';
// import '../../Common/GlobalStyle.dart';
// import '../../src/ApiService.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//
//   // Fungsi untuk login
//   Future<void> _login() async {
//     String email = _emailController.text;
//     String password = _passwordController.text;
//
//     if (email.isEmpty || password.isEmpty) {
//       // Jika email atau password kosong
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Email dan Password tidak boleh kosong'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Panggil API login
//       final loginResponse = await ApiService.loginAdmin(email, password);
//       String token = loginResponse['token']; // Ambil token dari response
//
//       // Simpan token ke penyimpanan lokal (misalnya SharedPreferences)
//       // saveToken(token); // Gunakan shared_preferences atau metode penyimpanan lainnya
//
//       // Navigasi ke halaman utama
//       Navigator.pushReplacementNamed(context, '/home'); // Ganti '/home' dengan rute halaman utama
//
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Login failed: $e'),
//         backgroundColor: Colors.red,
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 600) {
//             // Large screens: Row layout
//             return Row(
//               children: [
//                 // Left Side: Blue Welcome Section
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     color: GlobalStyle.buttonColor,
//                     width: double.infinity,
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 32.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Delpick',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Text(
//                             'Welcome to Delpick Admin',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             'You could be adding any information as admin',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Right Side: Login Form Section
//                 Expanded(
//                   flex: 1,
//                   child: _buildLoginForm(),
//                 ),
//               ],
//             );
//           } else {
//             // Small screens: Column layout
//             return Column(
//               children: [
//                 // Top Section: Blue Welcome Section
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     width: double.infinity,
//                     color: GlobalStyle.buttonColor,
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 32.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Admin',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 24),
//                           Text(
//                             'Welcome Admin Delpick',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             'You could be changing anything here',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Bottom Section: Login Form Section
//                 Expanded(
//                   flex: 1,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: _buildLoginForm(context),
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   // Login Form Widget
//   Widget _buildLoginForm(BuildContext context) {
//     return Center(
//       child: Container(
//         width: 400,
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 6,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Center(
//                 child: Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Email Field
//               const Text(
//                 'Email',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Password Field
//               const Text(
//                 'Password',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Remember Me & Forgot Password Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: false,
//                         onChanged: (value) {},
//                         activeColor: Colors.blue,
//                       ),
//                       const Text(
//                         'Remember me',
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Handle "Forget Password?"
//                     },
//                     child: const Text(
//                       'Forget Password?',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: GlobalStyle.buttonColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: _isLoading ? null : _login,
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                     color: Colors.white,
//                   )
//                       : const Text(
//                     'Log in',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import '../../Common/GlobalStyle.dart';
// //
// //
// // class LoginScreen extends StatelessWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           if (constraints.maxWidth > 600) {
// //             // Larger screens: Use Row layout
// //             return Row(
// //               children: [
// //                 // Left Side: Blue Welcome Section
// //                 Expanded(
// //                   flex: 1,
// //
// //                   child: Container(
// //                     color: GlobalStyle.buttonColor,
// //                     width: double.infinity,
// //                     child: const Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 32.0),
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Delpick',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 32,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           SizedBox(height: 24),
// //                           Text(
// //                             'Welcome to Delpick Admin',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                           SizedBox(height: 12),
// //                           Text(
// //                             'You could be adding any information as admin',
// //                             style: TextStyle(
// //                               color: Colors.white70,
// //                               fontSize: 14,
// //                               height: 1.5,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 // Right Side: Login Form Section
// //                 Expanded(
// //                   flex: 1,
// //                   child: _buildLoginForm(),
// //                 ),
// //               ],
// //             );
// //           } else {
// //             // Smaller screens: Use Column layout
// //             return Column(
// //               children: [
// //                 // Top Section: Blue Welcome Section
// //                 Expanded(
// //                   flex: 1,
// //                   child: Container(
// //                     width: double.infinity,
// //                     color: GlobalStyle.buttonColor,
// //                     child: const Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 32.0),
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Admin',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 32,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           SizedBox(height: 24),
// //                           Text(
// //                             'Welcome Admin Delpick',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                           SizedBox(height: 12),
// //                           Text(
// //                             'U could be change anything at here',
// //                             style: TextStyle(
// //                               color: Colors.white70,
// //                               fontSize: 14,
// //                               height: 1.5,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 // Bottom Section: Login Form Section
// //                 Expanded(
// //                   flex: 1,
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: _buildLoginForm(),
// //                   ),
// //                 ),
// //               ],
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// //
// //   // Login Form Widget
// //   Widget _buildLoginForm() {
// //     return Center(
// //       child: Container(
// //         width: 400,
// //         padding: const EdgeInsets.all(24),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(8),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.2),
// //               spreadRadius: 2,
// //               blurRadius: 6,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Center(
// //                 child: Text(
// //                   'Login',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               // Email Field
// //               const Text(
// //                 'Email',
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               TextField(
// //                 decoration: InputDecoration(
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   contentPadding: const EdgeInsets.symmetric(
// //                     horizontal: 16,
// //                     vertical: 12,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               // Password Field
// //               const Text(
// //                 'Password',
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               TextField(
// //                 obscureText: true,
// //                 decoration: InputDecoration(
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   contentPadding: const EdgeInsets.symmetric(
// //                     horizontal: 16,
// //                     vertical: 12,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //               // Remember Me & Forgot Password Row
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Checkbox(
// //                         value: false,
// //                         onChanged: (value) {},
// //                         activeColor: Colors.blue,
// //                       ),
// //                       const Text(
// //                         'Remember me',
// //                         style: TextStyle(color: Colors.black54),
// //                       ),
// //                     ],
// //                   ),
// //                   GestureDetector(
// //                     onTap: () {
// //                       // Handle "Forget Password?"
// //                     },
// //                     child: const Text(
// //                       'Forget Password?',
// //                       style: TextStyle(
// //                         color: Colors.green,
// //                         fontSize: 14,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               // Login Button
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 48,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: GlobalStyle.buttonColor,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   onPressed: () {
// //                     // Handle login button press
// //                   },
// //                   child: const Text(
// //                     'Log in',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
