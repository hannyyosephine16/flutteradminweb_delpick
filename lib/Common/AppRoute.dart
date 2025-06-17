import 'package:get/get.dart';

class AppRoutes {
  // Authentication Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Dashboard Routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';

  // Store Management Routes
  static const String stores = '/stores';
  static const String storeDetail = '/stores/:id';
  static const String addStore = '/stores/add';
  static const String editStore = '/stores/:id/edit';

  // Driver Management Routes
  static const String drivers = '/drivers';
  static const String driverDetail = '/drivers/:id';
  static const String addDriver = '/drivers/add';
  static const String editDriver = '/drivers/:id/edit';

  // Customer Management Routes
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/:id/edit';

  // Order Management Routes
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';

  // Menu Management Routes
  static const String menu = '/menu';
  static const String menuDetail = '/menu/:id';
  static const String addMenuItem = '/menu/add';
  static const String editMenuItem = '/menu/:id/edit';

  // Profile Routes
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Error Routes
  static const String notFound = '/404';
  static const String unauthorized = '/401';
  static const String serverError = '/500';

  // Get Routes List
  static List<GetPage> getRoutes() {
    return [
      // Will be filled when you provide the actual pages
    ];
  }
}