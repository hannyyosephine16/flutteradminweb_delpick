import 'package:flutter/material.dart';

class GlobalStyle {
  // Primary Colors - sesuai dengan backend theme
  static const Color primaryColor = Color(0xFFB71C1C);      // Brick Red untuk primary
  static const Color primaryLightColor = Color(0xFFE57373); // Light Red
  static const Color primaryDarkColor = Color(0xFF8B0000);  // Dark Red

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF0A84FF);    // Blue untuk accent
  static const Color warningColor = Color(0xFFFFB300);      // Amber untuk warning
  static const Color successColor = Color(0xFF4CAF50);      // Green untuk success
  static const Color errorColor = Color(0xFFF44336);        // Red untuk error
  static const Color infoColor = Color(0xFF2196F3);         // Blue untuk info

  // Background Colors
  static const Color bgColor = Color(0xFFF5F7FA);           // Light Gray background
  static const Color primaryBgColor = Color(0xFFB71C1C);   // Primary background
  static const Color cardBgColor = Color(0xFFFFFFFF);       // White untuk cards

  // Text Colors
  static const Color text1Color = Color(0xFF333333);        // Dark text
  static const Color text2Color = Color(0xFF666666);        // Medium text
  static const Color text3Color = Color(0xFFFFA726);        // Accent text
  static const Color textLightColor = Color(0xFFFFFFFF);    // White text

  // Button Colors
  static const Color buttonColor = Color(0xFF0A84FF);       // Primary button
  static const Color button2Color = Color(0xFFFFB300);      // Secondary button
  static const Color buttonTextColor = Color(0xFFFFFFFF);   // Button text

  // Form Colors
  static const Color textFormFieldBorderColor = Color(0xFF424242);
  static const Color textFormFieldLabelColor = Color(0xFF37474F);

  // Other Colors
  static const Color tabColor = Color(0xFFFFFFFF);          // Tab background
  static const Color tab2Color = Color(0xFF1A73E8);         // Active tab
  static const Color strokeColor = Color(0xFFB0BEC5);       // Border color

  // Status Colors (untuk order status, dll)
  static const Color pendingColor = Color(0xFFFF9800);      // Orange
  static const Color confirmedColor = Color(0xFF2196F3);    // Blue
  static const Color preparingColor = Color(0xFF9C27B0);    // Purple
  static const Color deliveredColor = Color(0xFF4CAF50);    // Green
  static const Color cancelledColor = Color(0xFFF44336);    // Red

  // Driver Status Colors
  static const Color activeDriverColor = Color(0xFF4CAF50); // Green
  static const Color inactiveDriverColor = Color(0xFF9E9E9E); // Gray
  static const Color busyDriverColor = Color(0xFFFF9800);   // Orange
}