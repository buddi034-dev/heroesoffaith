import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:herosoffaith/src/core/theme/app_theme.dart';
import 'package:herosoffaith/src/core/routes/app_routes.dart';
import 'package:herosoffaith/src/core/routes/route_names.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase in background immediately without blocking
  unawaited(_initializeFirebase());
  
  // Start the app immediately
  runApp(const MyApp());
}

// Initialize Firebase in background
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    // Firebase initialized successfully
  } catch (e) {
    // Firebase initialization error: $e
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heroes of Faith',
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.splash, // Corrected initialRoute
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
