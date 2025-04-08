// import 'package:delpickadmin/UserControls/DashboardController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'Views/Dashboard/Dashboard.dart';
//
// Future<void> main() async {
//   Get.put(DashboardController());
//   runApp(DelAdmin());
// }
//
// class DelAdmin extends StatelessWidget{
//   const DelAdmin({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Admin Delpick Dashboard",
//       theme: ThemeData(useMaterial3: true),
//       // getPages: TAppRoute.pages,
//       // initialRoute: TRoutes.,
//       // home: Dashboard(),
//       // home: const Scaffold(
//       //     body: Center(
//       //         child: Text('admin')
//       //     )
//       // ),
//     );
//     throw UnimplementedError();
//
//   }
// }
//
//
//
//
// //
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:package_info_plus/package_info_plus.dart';
// // import 'package:provider/provider.dart';
// // import 'package:session_storage/session_storage.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../Common/GlobalStyle.dart';
// // import 'package:flutter/material.dart';
// // import 'Common/LoginInfo.dart';
// // import 'Common/NavigationService.dart';
// // import 'Dto/Base/GlobalDto.dart';
// // import 'Views/Controls/Login.dart';
// // // import 'dart:html' as html;
// //
// // void main() {
// //   debugPrint("Welcome");
// //   mainInit();
// //   runApp(MyApp());
// // }
// //
// // void mainInit() async {
// //   SessionStorage session = SessionStorage();
// //
// //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //
// //   if(session.containsKey("LOGIN_STAMP")){
// //     debugPrint("Refresh");
// //     //GlobalDto.timestampLogin = prefs.getString("LOGIN_TIMESTAMP") ?? "";
// //     GlobalDto.CONO = prefs.getString("CONO") ?? "";
// //     GlobalDto.CONA = prefs.getString("CONA") ?? "";
// //     GlobalDto.BRNO = prefs.getString("BRNO") ?? "";
// //     GlobalDto.BRNA = prefs.getString("BRNA") ?? "";
// //     GlobalDto.USNO = prefs.getString("USNO") ?? "";
// //     GlobalDto.USNA = prefs.getString("USNA") ?? "";
// //     GlobalDto.USTY = prefs.getString("USTY") ?? "";
// //     GlobalDto.listAuthority = prefs.getString("lstAuthority") ?? "";
// //     GlobalDto.listDictionary = prefs.getString("lstDictionary") ?? "";
// //   }else{
// //     debugPrint("New");
// //     session.clear();
// //     prefs.clear();
// //     GlobalDto.CONO = "";
// //     GlobalDto.CONA = "";
// //     GlobalDto.BRNO = "";
// //     GlobalDto.BRNA = "";
// //     GlobalDto.USNO = "";
// //     GlobalDto.USNA = "";
// //     GlobalDto.USTY = "";
// //     GlobalDto.listAuthority = "";
// //     GlobalDto.listDictionary = "";
// //   }
// //
// //   // html.window.onBeforeUnload.listen((event) {
// //   //   if(session.containsKey("welcome")){
// //   //     debugPrint("Goodbye ${session["welcome"]}");
// //   //   }else{
// //   //     debugPrint("Goodbye");
// //   //   }
// //   //
// //   //   //prefs.clear();
// //   // });
// // }
// //
// // class MyApp extends StatelessWidget {
// //
// //   final GoRouter router = NavigationService().generateRouter();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ScreenUtilInit(
// //       designSize: const Size(1280, 720),
// //       minTextAdapt: true,
// //       builder: (context , child) {
// //         return MaterialApp.router(
// //           routeInformationProvider: router.routeInformationProvider,
// //           routeInformationParser: router.routeInformationParser,
// //           routerDelegate: router.routerDelegate,
// //           title: "VIZEETRACK",
// //           theme: ThemeData(
// //             brightness: Brightness.light,
// //             primaryColor: GlobalStyle.primaryColor,
// //             // Define the default font family.
// //             fontFamily: GlobalStyle.fontFamily,
// //             visualDensity: VisualDensity.compact,
// //           ),
// //           debugShowCheckedModeBanner: false,
// //           supportedLocales: const [
// //             Locale("en", "US"),
// //           ],
// //           locale: const Locale("en", "US"),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // import 'package:delpickadmin/Views/Controls/MainHome.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:go_router/go_router.dart';
// // // import 'Dashboardtes.dart'; // Import halaman yang sudah ada
// // // import 'Views/Controls/Login.dart'; // Import halaman Login
// // //
// // // void main() {
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final GoRouter _router = GoRouter(
// // //       initialLocation: '/login', // Menetapkan halaman pertama
// // //       routes: [
// // //         // Definisikan rute-rute aplikasi
// // //         GoRoute(
// // //           path: '/login', // Rute halaman login
// // //           builder: (BuildContext context, GoRouterState state) {
// // //             return const Login(); // Halaman Login
// // //           },
// // //         ),
// // //         GoRoute(
// // //           path: '/mainHome', // Rute halaman login
// // //           builder: (BuildContext context, GoRouterState state) {
// // //             return const MainHome(); // Halaman Login
// // //           },
// // //         ),
// // //         GoRoute(
// // //           path: '/', // Rute halaman utama
// // //           builder: (BuildContext context, GoRouterState state) {
// // //             return const Dashboard(); // Halaman utama (Dashboard)
// // //           },
// // //         ),
// // //       ],
// // //       // Redirect untuk memeriksa status login
// // //       redirect: (context, state) {
// // //         // Gantilah dengan logika status login Anda
// // //         final isLoggedIn = true; // Ini hanya contoh, ganti dengan logika Anda
// // //         final isLoggingIn = state.matchedLocation == '/mainHome';
// // //
// // //         // Jika belum login dan bukan di halaman login, arahkan ke halaman login
// // //         if (!isLoggedIn && !isLoggingIn) {
// // //           return '/login'; // Arahkan ke halaman login
// // //         }
// // //
// // //         // Jika sudah login, biarkan user melanjutkan navigasi ke halaman yang diminta
// // //         return null;
// // //       },
// // //     );
// // //
// // //     return MaterialApp.router(
// // //       title: 'Flutter Demo',
// // //       theme: ThemeData(
// // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // //       ),
// // //       routerConfig: _router, // Menyambungkan GoRouter ke aplikasi
// // //     );
// // //   }
// // // }
// // //
// // //
// // // // import 'package:flutter/material.dart';
// // // //
// // // // // Define your main app widget
// // // // class MyApp extends StatelessWidget {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: 'Flutter Web App',
// // // //       theme: ThemeData(
// // // //         primarySwatch: Colors.blue,
// // // //       ),
// // // //       home: Scaffold(
// // // //         appBar: AppBar(
// // // //           title: Text('Flutter Web App'),
// // // //         ),
// // // //         body: Center(
// // // //           child: Text('Hello, World!'),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // The main entry point
// // // // void main() {
// // // //   runApp(MyApp());
// // // // }

import 'package:flutter/material.dart';
import 'app.dart';

/// Entry point of Flutter App
Future<void> main() async {
  // Ensure that widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX Local Storage

  // Remove # sign from url

  // Initialize Firebase & Authentication Repository

  // Main App Starts here...
  runApp(const App());
}
