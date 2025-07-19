import 'package:elder_care/presentation/screens/auth/login_screen.dart';
import 'package:elder_care/utils/app_theme.dart';
import 'package:elder_care/utils/bindings.dart';
import 'package:elder_care/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/dashboard_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: constants.supabaseUrl,
    anonKey: constants.supabaseKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Eldercare App', // Changed title for relevance
      initialBinding: InitialBinding(), // Use your updated binding
      theme: ThemeData(
        brightness: Brightness.dark, // Overall dark theme
        primarySwatch: Colors.blueGrey, // Can be overridden by custom colors
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // A modern, clean font
        textTheme: TextTheme(
          // Define text styles to use AppColors
          displayLarge: TextStyle(color: AppColors.textLight),
          displayMedium: TextStyle(color: AppColors.textLight),
          displaySmall: TextStyle(color: AppColors.textLight),
          headlineLarge: TextStyle(color: AppColors.textLight),
          headlineMedium: TextStyle(color: AppColors.textLight),
          headlineSmall: TextStyle(color: AppColors.textLight),
          titleLarge: TextStyle(color: AppColors.textLight),
          titleMedium: TextStyle(color: AppColors.textLight),
          titleSmall: TextStyle(color: AppColors.textLight),
          bodyLarge: TextStyle(color: AppColors.textLight),
          bodyMedium: TextStyle(color: AppColors.textLight),
          bodySmall: TextStyle(color: AppColors.textLight),
          labelLarge: TextStyle(color: AppColors.textLight),
          labelMedium: TextStyle(color: AppColors.textLight),
          labelSmall: TextStyle(color: AppColors.textLight),
        ),
        scaffoldBackgroundColor: AppColors.primaryDark, // Apply primary dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent app bar
          elevation: 0, // No shadow
          iconTheme: IconThemeData(color: AppColors.textLight), // Default icon color
          titleTextStyle: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentCoral,
            foregroundColor: AppColors.textLight, // Text color on button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: AppColors.accentCoral.withOpacity(0.4),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.iconColor.withOpacity(0.7)),
          filled: true,
          fillColor: AppColors.primaryDark.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accentCoral, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.cardBackground,
          selectedItemColor: AppColors.accentCoral,
          unselectedItemColor: AppColors.iconColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen()
    );
  }
}