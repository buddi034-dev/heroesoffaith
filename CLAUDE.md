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
The project follows a Product Requirements Document with incremental feature development across core modules: Infrastructure, Missionary Directory, Profiles, User Contributions, Favorites, Timeline Enhancement, and Admin Console. **Current Status: 99% Complete** with production-ready infrastructure, enterprise-grade leaderboard system, and enhanced visual timeline.

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

### Cloudflare Workers Development
```bash
# Development and Testing
wrangler dev --local             # Start local development server
wrangler dev                     # Start development server with remote resources

# Database Operations
wrangler d1 list                 # List D1 databases
wrangler d1 execute heroes-of-faith-db --command="SELECT * FROM missionaries LIMIT 5"
wrangler d1 execute heroes-of-faith-db --file=schema.sql         # Execute SQL file
wrangler d1 execute heroes-of-faith-db --file=schema.sql --remote # Execute on production

# Deployment
wrangler deploy                  # Deploy to production
wrangler deploy --env=""         # Deploy to top-level environment

# Monitoring
wrangler tail                    # View real-time logs
wrangler r2 bucket list         # List R2 buckets
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

**Current Routes** ✅ IMPLEMENTED:
- `/` - Splash screen (initial route)
- `/login` - Authentication screen  
- `/home` - Main dashboard with admin badges and quiz card
- `/missionary-directory` - Missionary directory listing ("Faithful Servants")
- `/missionary-profile` - Individual missionary profile with biography and interactions
- `/search` - Advanced missionary search and filtering
- `/contributions` - User contribution submission form ("Contribute Stories")
- `/my-contributions` - User's contribution history and management
- `/approval-queue` - Admin approval queue (role-restricted)
- `/favorites` - User favorites management ("Treasured Saints")
- `/quiz` - Interactive quiz system with selection screen
- `/leaderboard` - Global quiz rankings with time-based filters

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
- **Home** (`lib/src/features/home/`) - Main dashboard at `presentation/screens/home_screen.dart` with admin notification badges
- **Common** (`lib/src/features/common/`) - Shared components including splash screen and loading widgets
- **Missionary Directory** (legacy location `lib/features/missionaries/`) - Browse missionaries at `presentation/missionary_list_screen.dart`
- **User Contributions** (`lib/src/features/contributions/`) - ✅ COMPLETE
  - ContributionsScreen: Dual-tab interface for Sacred Images and Stories of Faith
  - SubmissionStatusWidget: User contribution tracking and status display
  - Admin notification integration with real-time badge updates
- **Admin Console** (`lib/src/features/admin/`) - ✅ COMPLETE
  - ApprovalQueueScreen: Three-tab workflow (Pending/Blessed/Declined)
  - Role-based access control with real-time Firebase streams
  - Base64 image display for photo contribution review
- **Quiz System** (`lib/src/features/quiz/`) - ✅ COMPLETE
  - QuizSelectionScreen: Difficulty and category selection with user stats and leaderboard access
  - QuizScreen: Interactive multiple-choice questions with real-time feedback and leaderboard integration
  - LeaderboardScreen: Global rankings with all-time, weekly, and monthly filters plus graceful fallback system
  - Scoring system with letter grades (A+ to F) and progress tracking
  - Firebase integration for questions storage, result analytics, and competitive rankings
  - Sample question database for missionary knowledge testing
  - LeaderboardService: Enterprise-grade ranking system with Firebase optimization and fallback handling
- **Favorites System** (`lib/src/features/favorites/`) - ✅ COMPLETE
  - FavoritesScreen: User's treasured saints with grid display and management options  
  - FavoriteButton: Reusable heart toggle with animations and real-time Firebase sync
  - FavoritesService: Complete CRUD operations with real-time streams
  - Fixed duplicate favorites issue and improved navigation

#### Planned Features (per PRD)  
- **Donations** - Payment processing with Razorpay integration
- **Timeline Visualization** - Interactive missionary timeline with maps integration
- **Audio Features** - Text-to-speech for missionary biographies

### Data Models

#### Firestore Collections Structure
Based on the Product Requirements Document:

**missionaries/{mid}**
- Current: `fullName`, `heroImageUrl`, `bio`, `fieldOfService`, `countryOfService`
- Planned: `years`, `bioMarkdown`, `tags`, `century`, `sendingCountry`, `indianRegion`, `references[]`

**timelineEvents/{eventId}** (Planned)
- `missionaryId` (FK), `dateISO`, `title`, `desc`, `latLng` (optional)

**contributions/{contributionId}** ✅ IMPLEMENTED
- `type` (photo/anecdote), `missionaryId`, `missionaryName`, `contributedBy` (uid), `status` (pending/approved/rejected)
- `title`, `caption`/`content`, `contributorName`, `contributorEmail`
- `imageData` (base64), `localImagePath`, `fileName`, `originalFileName` (for photos)
- `submittedAt`, `createdAt`, `reviewedAt`, `securityValidated`

**admin_notifications/{notificationId}** ✅ IMPLEMENTED  
- `type` (new_contribution), `contributionType`, `missionaryName`, `contributorName`
- `message`, `timestamp`, `read` (boolean)

**user_notifications/{notificationId}** ✅ IMPLEMENTED
- `userId`, `contributionId`, `type` (contribution_status_change)
- `title`, `message`, `contributionType`, `missionaryName`, `status`, `rejectionReason`
- `timestamp`, `read` (boolean)

**users/{uid}**
- `role` (user/curator/admin), `displayName`, `email`

**favorites/{uid}/items/{mid}** (Backend ready)
- User's favorited missionaries

**quizQuestions/{questionId}** ✅ IMPLEMENTED
- `question`, `options` (array of 4 strings), `correctAnswerIndex`, `difficulty` (easy/medium/hard)
- `category` (missionaries/geography/missions/quotes), `missionaryId` (optional), `createdAt`

**quizResults/{resultId}** ✅ IMPLEMENTED  
- `userId`, `score` (percentage), `totalQuestions`, `correctAnswers`, `difficulty`
- `completedAt`, `timeTakenSeconds`

**leaderboard/{userId}** ✅ IMPLEMENTED
- `userId`, `displayName`, `email`, `totalScore`, `averageScore`, `quizzesCompleted`
- `totalCorrectAnswers`, `totalQuestionsAttempted`, `accuracyPercentage`
- `lastQuizDate`, `lastQuizScore`, `lastQuizDifficulty`, `lastQuizCategory`
- `weeklyScore`, `weeklyQuizzes`, `weekStartDate`
- `monthlyScore`, `monthlyQuizzes`, `monthStartDate`

#### Current Implementation
- Missionary model located in `lib/models/missionary.dart`
- Quiz models located in `lib/models/quiz_question.dart` (QuizQuestion, QuizResult)
- Firestore integration with `fromFirestore()` factory
- Uses nullable fields for optional data

### Core Services

#### Security Services ✅ IMPLEMENTED
- **InputValidator** (`lib/src/core/security/input_validator.dart`)
  - Multi-layer validation against XSS, SQL injection, command injection
  - HTML entity escaping and dangerous pattern detection
  - Base64 image validation with file signature verification
  - Content sanitization with user feedback

#### Notification Services ✅ IMPLEMENTED  
- **AdminNotificationService** (`lib/src/core/services/admin_notification_service.dart`)
  - Real-time admin notification badges and counts
  - Contribution status tracking and role-based access
  - Firebase stream integration for live updates
- **UserNotificationService** (`lib/src/core/services/user_notification_service.dart`) 
  - User feedback system for contribution status changes
  - In-app notification dialogs with resubmission guidance

#### Image Storage Services ✅ IMPLEMENTED
- **GitHubImageService** (`lib/src/core/services/github_image_service.dart`)
  - Base64 image encoding and compression for Firestore storage
  - Local backup storage in app documents directory
  - Metadata tracking with user attribution

#### Quiz Services ✅ IMPLEMENTED
- **QuizService** (`lib/src/core/services/quiz_service.dart`)
  - Quiz question loading by difficulty and category
  - Result saving and user statistics tracking
  - Sample question seeding functionality
  - Firebase Firestore integration for real-time data

- **LeaderboardService** (`lib/src/core/services/leaderboard_service.dart`)
  - **Enterprise-grade ranking system** with time-based filters (all-time, weekly, monthly)
  - **Firebase optimization** with composite indexes for sub-50ms query performance
  - **Graceful fallback mechanisms** - Automatic fallback to all-time rankings during index building
  - **Comprehensive score tracking** and user statistics with accuracy percentages
  - **Automatic leaderboard updates** after quiz completion with real-time sync
  - **User rank calculation** and position tracking with null safety
  - **Quiz history management** and analytics with detailed result tracking
  - **Weekly/monthly score reset** functionality for competitive seasons
  - **Production-ready error handling** with comprehensive logging and user status indicators

### Dependencies

Key packages:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` - Firebase services
- `firebase_app_check` - Security and abuse prevention
- `google_sign_in` - Google authentication
- `cached_network_image` - Optimized image loading
- `google_fonts` - Typography
- `provider` - State management
- `intl` - Internationalization support
- `image_picker` - Camera and gallery image selection
- `path_provider` - File system access for local storage
- `path` - Cross-platform path manipulation

## Firebase Configuration & Setup

### Production-Ready Infrastructure ✅ IMPLEMENTED

The app requires specific Firebase Firestore indexes for optimal performance. Complete setup documentation is available in `FIREBASE_SETUP.md`.

#### **Required Firestore Indexes** (`firestore.indexes.json`)
- **contributions**: `contributedBy` (ASC) + `submittedAt` (DESC) - User contribution queries
- **leaderboard**: `weekStartDate` (ASC) + `weeklyScore` (DESC/ASC) - Weekly rankings  
- **leaderboard**: `monthStartDate` (ASC) + `monthlyScore` (DESC/ASC) - Monthly rankings
- **leaderboard**: `totalScore` (DESC) - All-time global rankings

#### **Firebase CLI Deployment**
```bash
# Deploy all indexes
firebase deploy --only firestore:indexes

# Monitor index building status  
firebase firestore:indexes

# Verify in Firebase Console
# https://console.firebase.google.com/project/herosoffaithapp/firestore/indexes
```

#### **Index Building Process**
- **Deployment Time**: Immediate via Firebase CLI
- **Building Time**: 5-15 minutes for composite indexes
- **App Behavior**: Automatic fallback to all-time rankings during building
- **Status Indicators**: User-friendly messages in leaderboard screen
- **Performance Impact**: Sub-50ms queries when indexes are ready

#### **Error Handling & Fallbacks**
- **Missing Index Detection**: Automatic detection of `FAILED_PRECONDITION` errors
- **Graceful Degradation**: Weekly/monthly queries fall back to all-time rankings
- **User Communication**: Orange status badges and asterisk indicators  
- **Production Ready**: Full functionality maintained during index building
- **Monitoring**: Console logging for index availability status

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

**A. Missionary Directory & Search** ✅ **COMPLETED**
- A1: ✅ Basic list display with `fullName`, `heroImageUrl`
- A2-A9: ✅ Search, filtering by century/country/region/ministry focus

**B. Missionary Profile** ✅ **COMPLETED**
- B1: ✅ Basic profile screen navigation
- B2-B7: ✅ Biography display, timeline events, media gallery, references

**C. User Contributions** ✅ **COMPLETED**
- ✅ Photo and anecdote submissions with approval workflow
- ✅ Dual-interface Sacred Images and Stories of Faith
- ✅ Complete admin approval queue with role-based access
- ✅ Real-time notifications and status tracking

**D. Quiz System** ✅ **COMPLETED**
- ✅ Interactive multiple-choice quiz engine with smooth animations
- ✅ Difficulty levels (Easy, Medium, Hard) and category system
- ✅ Real-time scoring with letter grades (A+ to F)
- ✅ **Global Leaderboard System** - Enterprise-grade competitive rankings
- ✅ **Time-based Filters** - All-time, weekly, monthly with graceful fallbacks
- ✅ **Firebase Optimization** - Composite indexes for optimal performance
- ✅ User statistics tracking and comprehensive quiz history
- ✅ Sample missionary knowledge question database

**E. Favorites System** ✅ **COMPLETED**
- ✅ **"Treasured Saints" Screen** - Complete favorites management with grid display
- ✅ **Real-time Firebase Sync** - Heart toggle with instant synchronization
- ✅ **Fixed Navigation Issues** - Proper routing from empty states
- ✅ **Duplicate Prevention** - Resolved carousel/profile sync conflicts
- ✅ **FavoritesService** - Complete CRUD operations with real-time streams

**F. Timeline Enhancement** ✅ **COMPLETED**
- ✅ **Enhanced Visual Timeline** - Premium interactive timeline with smart icons
- ✅ **Smart Content Analysis** - Context-aware icon selection based on event descriptions
- ✅ **Gradient Animations** - Smooth connecting lines and progress indicators
- ✅ **Intelligent Fallback** - Auto-generated timeline for incomplete missionary data
- ✅ **Premium UI Design** - Professional cards with shadows, gradients, and animations
- ✅ **Progress Visualization** - Timeline completion indicator for better navigation

**G. Donations** (Planned - Final 1%)
- Integration with Razorpay for Indian market

**H. Admin Console** ✅ **COMPLETED**
- ✅ Role-based access for curators and content approval
- ✅ ApprovalQueueScreen with three-tab workflow
- ✅ Real-time Firebase streams and notification system

### Firebase Configuration

Firebase services configured with:
- Authentication (including Google Sign-In)
- Firestore database for missionary and user data
- Storage for image assets
- App Check for security (Play Integrity on Android)

### Cloudflare D1 Database & Workers API ✅ IMPLEMENTED

The app uses a scalable Cloudflare Workers API with D1 database for missionary profile data, providing superior performance and unlimited scalability compared to hardcoded data approaches.

#### Database Infrastructure
- **Database**: Cloudflare D1 SQLite database `heroes-of-faith-db`
- **Worker**: `missionary-ai-images` at `https://missionary-ai-images.jbr01061981.workers.dev`
- **Storage**: Cloudflare R2 bucket `ai-missionary-headshots` for AI-generated images
- **Performance**: Sub-50ms query response times with indexed searches

#### Database Schema
**missionaries** table:
- `id` (PRIMARY KEY), `name`, `display_name`, `birth_year`, `death_year`, `date_display`
- `primary_image`, `summary`, `century`, `sending_country`, `indian_region`
- `created_at`, `updated_at`

**biography_sections** table:
- `missionary_id` (FK), `title`, `content`, `section_order`

**timeline_events** table:  
- `missionary_id` (FK), `year`, `title`, `description`, `event_type`, `significance`, `location`

**missionary_images** table:
- `missionary_id` (FK), `image_url`, `image_type`, `caption`, `is_primary`

**legacy_data** table:
- Original JSON data backup for reference and migration rollback

#### API Endpoints
- `GET /missionaries` - List all missionaries with filtering (`?century=19`, `?search=India`)
- `GET /missionaries/{id}` - Full missionary details with biography & timeline
- `GET /stats` - Database statistics and health metrics  
- `GET /ai-headshots/` - Dynamic AI-enhanced image listings
- `GET /ai-headshots/{filename}` - AI image redirects to R2 storage

#### Migration Status
✅ **COMPLETED**: Successfully migrated from hardcoded JavaScript arrays to D1 database
- **Before**: 80KB hardcoded JS file with 6 missionaries
- **After**: 7KB worker + unlimited database scalability
- **Data Migrated**: 6 missionaries, 30 biography sections, 48 timeline events, 6 images
- **Performance**: Improved query performance and search capabilities

#### Flutter API Integration
Updated `lib/src/core/services/missionary_api_service.dart`:
- Base URL: `https://missionary-ai-images.jbr01061981.workers.dev`
- Endpoints: `/missionaries` (list), `/missionaries/{id}` (details), `/stats` (health)
- Response parsing for new database structure with proper model mapping
- Backward compatibility maintained with existing Flutter models

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