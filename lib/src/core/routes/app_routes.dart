// lib/src/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:herosoffaith/src/core/routes/route_names.dart';
import 'package:herosoffaith/src/features/home/presentation/screens/home_screen.dart';
// Import the LoginScreen
import 'package:herosoffaith/src/features/auth/presentation/screens/login_screen.dart';
// Import the SignUpScreen
import 'package:herosoffaith/src/features/auth/presentation/screens/signup_screen.dart';
// Import the MissionaryListScreen
import 'package:herosoffaith/features/missionaries/presentation/missionary_list_screen.dart';
// Import the DataUploadScreen - Commented out due to dependency issues
// import 'package:herosoffaith/src/features/admin/presentation/screens/data_upload_screen.dart';
// Import the MissionaryProfileScreen
import 'package:herosoffaith/features/missionaries/presentation/missionary_profile_screen.dart';
// Import the SplashScreen
import 'package:herosoffaith/src/features/common/presentation/screens/splash_screen.dart'; // <<< CORRECT IMPORT
// Import the SearchScreen
import 'package:herosoffaith/src/features/search/presentation/screens/search_screen.dart';
// Import the Missionary model
import 'package:herosoffaith/models/missionary.dart';


class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case RouteNames.missionaryDirectory:
        return MaterialPageRoute(builder: (_) => const MissionaryListScreen());

      case RouteNames.missionaryProfile:
        final missionary = settings.arguments as Missionary?;
        if (missionary != null) {
          return MaterialPageRoute(builder: (_) => MissionaryProfileScreen(missionary: missionary));
        } else {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text('Missionary data not found')),
            ),
          );
        }

      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen()); // <<< CORRECTED ROUTE

      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case RouteNames.dataUpload:
        return MaterialPageRoute(builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Upload Coming Soon")),
          body: const Center(child: Text('Advanced upload screen coming soon!\nUse the simple upload from home screen.')),
        ));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Navigation Error")),
            body: Center(
              child: Text('No route defined for ${settings.name ?? "a null route name"}'),
            ),
          ),
        );
    }
  }
}
