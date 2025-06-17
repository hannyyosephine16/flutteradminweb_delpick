class AppConstants {
  // API Response Keys
  static const String statusCodeKey = 'statusCode';
  static const String messageKey = 'message';
  static const String dataKey = 'data';
  static const String errorsKey = 'errors';

  // Success Status Codes
  static const int successCode = 200;
  static const int createdCode = 201;

  // Error Status Codes
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // Pagination Keys
  static const String totalItemsKey = 'totalItems';
  static const String totalPagesKey = 'totalPages';
  static const String currentPageKey = 'currentPage';

  // DateTime Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Validation Messages
  static const String requiredFieldMsg = 'This field is required';
  static const String invalidEmailMsg = 'Please enter a valid email';
  static const String passwordMinLengthMsg = 'Password must be at least 6 characters';
  static const String phoneValidationMsg = 'Please enter a valid phone number';
}