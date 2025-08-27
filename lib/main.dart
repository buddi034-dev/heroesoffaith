import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:herosoffaith/src/core/theme/app_theme.dart';
import 'package:herosoffaith/src/core/routes/app_routes.dart';
import 'package:herosoffaith/src/core/routes/route_names.dart';
import 'package:herosoffaith/src/core/services/missionary_api_service.dart';
import 'package:herosoffaith/src/core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in background
  unawaited(_initializeServices());
  
  // Start the app immediately
  runApp(const MyApp());
}

// Initialize all services in background
Future<void> _initializeServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    print('✅ Firebase initialized successfully');
    
    // Initialize Cache Service
    await CacheManager().initialize();
    print('✅ Cache service initialized successfully');
    
    // Initialize API Service
    MissionaryApiService().initialize();
    print('✅ API service initialized successfully');
    
    // Test API health
    final healthResult = await MissionaryApiService().healthCheck();
    healthResult.onSuccess((data) {
      print('✅ API health check passed: ${data['status']}');
    });
    healthResult.onFailure((error) {
      print('⚠️ API health check failed: $error');
    });
    
  } catch (e) {
    print('❌ Service initialization error: $e');
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
