import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // We'll use Google Fonts

// TODO: Replace with colors from your PRD or design specifications
class AppColors {
  static const Color primaryColor = Color(0xFF6200EE); // A placeholder primary color
  static const Color accentColor = Color(0xFF03DAC6);  // A placeholder accent color
  static const Color backgroundColor = Color(0xFFFFFFFF); // White background
  static const Color textColor = Color(0xFF333333);     // Dark grey for text
  static const Color errorColor = Color(0xFFB00020);     // Standard error color
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(AppColors.primaryColor),
        accentColor: AppColors.accentColor,
        backgroundColor: AppColors.backgroundColor,
        errorColor: AppColors.errorColor,
        brightness: Brightness.light,
      ).copyWith(
          // For compatibility with some Flutter widgets that still use these directly
          secondary: AppColors.accentColor, // For FloatingActionButton, etc.
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: GoogleFonts.latoTextTheme( // Using Lato from Google Fonts as an example
        ThemeData.light().textTheme.copyWith(
              bodyLarge: const TextStyle(color: AppColors.textColor),
              bodyMedium: const TextStyle(color: AppColors.textColor),
              // Define other text styles as needed
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        elevation: 0, // Flat app bar
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // Helper function to create MaterialColor from a single Color
  // This is useful because ThemeData.fromSwatch requires a MaterialColor.
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round(), g = (color.g * 255.0).round(), b = (color.b * 255.0).round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  // TODO: Define a darkTheme if your app supports dark mode
  // static ThemeData get darkTheme { ... }
}
