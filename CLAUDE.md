# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Heroes of Faith is a Flutter application designed to preserve and showcase biographies, timelines, and impact of missionaries whose work directly affected India. The app follows an incremental MVP development approach targeting Android (Google Play) as first-launch platform, with eventual multilingual support for English and Indian languages.

### Target Users
- Church members and pastors seeking inspiration
- Seminary students and researchers
- Christian history enthusiasts
- Curators and historians (admin role)

### Current Development Status
The project follows a Product Requirements Document with incremental feature development across core modules: Infrastructure, Missionary Directory, Profiles, User Contributions, Favorites, Donations, and Admin Console.

## Development Commands

### Setup and Installation
```bash
flutter pub get                    # Install dependencies
```

### Development
```bash
flutter run                       # Run app in development mode
flutter run --debug               # Run with debug mode
flutter run --release             # Run in release mode
```

### Code Quality
```bash
flutter analyze                   # Run static analysis
flutter test                      # Run all tests
flutter test test/widget_test.dart # Run specific test file
```

### Build Commands
```bash
flutter build apk                 # Build Android APK
flutter build appbundle          # Build Android App Bundle
flutter build ios                # Build iOS app
flutter build web                # Build web app
```

### Platform-Specific Development
```bash
flutter run -d android           # Run on Android device/emulator
flutter run -d ios              # Run on iOS simulator
flutter run -d chrome           # Run on Chrome (web)
flutter run -d windows          # Run on Windows
flutter run -d macos            # Run on macOS
flutter run -d linux            # Run on Linux
```

## Architecture

### Project Structure
The app follows a feature-based clean architecture pattern with some legacy paths:

- `lib/src/core/` - Core application utilities, themes, routes, and services
- `lib/src/features/` - New feature modules organized by domain (auth, home, common)
- `lib/models/` - Data models (legacy location, transitioning to feature-based)
- `lib/features/` - Legacy feature implementations (missionaries)

### Key Architecture Components

#### Routing System
- Central routing managed in `lib/src/core/routes/app_routes.dart`
- Route constants defined in `lib/src/core/routes/route_names.dart`
- Uses Flutter's named routing with `onGenerateRoute`

#### Theme System  
- Centralized theming in `lib/src/core/theme/app_theme.dart`
- Uses Google Fonts (Lato) and Material Design principles
- Color scheme defined in `AppColors` class

#### Firebase Integration
- Firebase Core, Auth, Firestore, Storage, and App Check configured
- App Check uses Play Integrity for Android security
- Google Sign-In integration available

### Feature Modules

Each feature follows this structure:
- `application/` - Business logic and state management
- `presentation/` - UI screens and widgets
  - `screens/` - Full-screen widgets
  - `widgets/` - Reusable UI components

#### Current Features
- **Authentication** (`lib/src/features/auth/`) - Login and signup screens at `presentation/screens/`
- **Home** (`lib/src/features/home/`) - Main dashboard at `presentation/screens/home_screen.dart`
- **Common** (`lib/src/features/common/`) - Shared components including splash screen
- **Missionary Directory** (legacy location `lib/features/missionaries/`) - Browse missionaries at `presentation/missionary_list_screen.dart`

#### Planned Features (per PRD)
- **Missionary Profile** - Individual missionary details with timeline and media
- **Donations** - Payment processing with Razorpay integration
- **Favorites** - User favorites management
- **Admin** - Administrative functions and content approval
- **User Contributions** - Photo and anecdote submissions

### Data Models

#### Firestore Collections Structure
Based on the Product Requirements Document:

**missionaries/{mid}**
- Current: `fullName`, `heroImageUrl`, `bio`, `fieldOfService`, `countryOfService`
- Planned: `years`, `bioMarkdown`, `tags`, `century`, `sendingCountry`, `indianRegion`, `references[]`

**timelineEvents/{eventId}** (Planned)
- `missionaryId` (FK), `dateISO`, `title`, `desc`, `latLng` (optional)

**media/{mediaId}** (Planned)
- `missionaryId` (FK), `type` (image/anecdote), `storageUrl`, `text`, `caption`, `year`, `contributedBy` (uid), `status` (pending/approved/rejected)

**users/{uid}**
- `role` (user/curator/admin), `displayName`, `email`

**favorites/{uid}/items/{mid}** (Planned)
- User's favorited missionaries

#### Current Implementation
- Missionary model located in `lib/models/missionary.dart`
- Firestore integration with `fromFirestore()` factory
- Uses nullable fields for optional data

### Dependencies

Key packages:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` - Firebase services
- `firebase_app_check` - Security and abuse prevention
- `google_sign_in` - Google authentication
- `cached_network_image` - Optimized image loading
- `google_fonts` - Typography
- `provider` - State management
- `intl` - Internationalization support

### Development Notes

- The app starts with splash screen (`RouteNames.splash`) as initial route in `main.dart:32`
- Firebase services must be initialized before app startup in `main.dart:13`
- Firebase App Check with Play Integrity is configured for Android security in `main.dart:15-20`
- Uses Material Design with custom color scheme defined in `lib/src/core/theme/app_theme.dart`
- Supports multiple platforms: Android, iOS, Web, Windows, macOS, Linux
- Images stored in `assets/images/` directory
- Lint rules follow `package:flutter_lints/flutter.yaml` standards via `analysis_options.yaml`

### MVP Development Increments

Current implementation follows the Product Requirements Document with these key feature modules:

**A. Missionary Directory & Search** (In Progress)
- A1: ✅ Basic list display with `fullName`, `heroImageUrl`
- A2-A9: Search, filtering by century/country/region/ministry focus (Planned)

**B. Missionary Profile** (Planned)
- B1: Basic profile screen navigation
- B2-B7: Biography display, timeline events, media gallery, references

**C. User Contributions** (Planned)
- Photo and anecdote submissions with approval workflow

**D. Favorites & Shareable Cards** (Planned)
- User favorites system and quote card generation

**E. Donations** (Planned)
- Integration with Razorpay for Indian market

**F. Admin Console** (Planned)
- Role-based access for curators and content approval

### Firebase Configuration

Firebase services configured with:
- Authentication (including Google Sign-In)
- Firestore database for missionary and user data
- Storage for image assets
- App Check for security (Play Integrity on Android)

### Testing

- Widget tests located in `test/` directory
- Main test file: `test/widget_test.dart`
- Run `flutter test` to execute all tests

### Security and Role-Based Access

The app implements user roles defined in the PRD:
- **user**: Regular app users
- **curator**: Content moderators who can approve contributions
- **admin**: Full administrative access

Role-based security implemented via:
- Firestore security rules for backend protection
- In-app role checks for UI access control
- Firebase App Check with Play Integrity for Android security

### Multilingual Support Strategy

Current: English UI with single language content
Planned: UI localization for English + major Indian languages per PRD requirements
Future: Full content translation for missionary biographies and historical content

## Important Implementation Notes

### Route Structure Inconsistency
The project has mixed routing locations:
- Core routing: `lib/src/core/routes/app_routes.dart` and `route_names.dart`
- Legacy missionary features: `lib/features/missionaries/` (imported in app_routes.dart:11)
- New features: `lib/src/features/` (auth, home, common)

### Firebase App Initialization Sequence
Critical initialization order in `main.dart`:
1. `WidgetsFlutterBinding.ensureInitialized()` (line 11)
2. `Firebase.initializeApp()` (line 13)
3. `FirebaseAppCheck.instance.activate()` with Play Integrity (lines 15-20)
4. `runApp()` (line 21)

### Product Requirements Integration
The codebase implements the incremental MVP approach defined in the PRD:
- Infrastructure setup is complete (INFRA-01 to INFRA-05)
- Currently implementing Module A (Missionary Directory & Search)
- Modules B-F are planned for future implementation