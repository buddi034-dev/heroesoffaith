# Heroes of Faith - Screen Reference Guide

This document provides an easy reference for all screens in the Heroes of Faith application.

## 🗂️ Screen Categories

### 🚀 Core Screens (3)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Splash Screen** | `lib/src/features/common/presentation/screens/splash_screen.dart` | `SplashScreen` | `/` | App initialization and loading |
| **Login Screen** | `lib/src/features/auth/presentation/screens/login_screen.dart` | `LoginScreen` | `/login` | User authentication |
| **Signup Screen** | `lib/src/features/auth/presentation/screens/signup_screen.dart` | `SignUpScreen` | `/signup` | User registration |

### 🏠 Main Application (1)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Home Dashboard** | `lib/src/features/home/presentation/screens/home_screen.dart` | `HomeScreen` | `/home` | Main dashboard and navigation |

### 👥 Missionary Features (3)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Faithful Servants** | `lib/features/missionaries/presentation/missionary_list_screen.dart` | `MissionaryListScreen` | `/missionary-directory` | Browse missionaries with filters |
| **Missionary Profile** | `lib/features/missionaries/presentation/missionary_profile_screen.dart` | `MissionaryProfileScreen` | `/missionary-profile` | Detailed missionary biography |
| **Search Screen** | `lib/src/features/search/presentation/screens/search_screen.dart` | `SearchScreen` | `/search` | Advanced search functionality |

### ⭐ User Features (3)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Treasured Saints** | `lib/src/features/favorites/presentation/screens/favorites_screen.dart` | `FavoritesScreen` | `/favorites` | User's favorite missionaries |
| **Contribute Stories** | `lib/src/features/contributions/presentation/screens/contributions_screen.dart` | `ContributionsScreen` | `/contributions` | Submit photos/anecdotes |
| **My Contributions** | `lib/src/features/contributions/presentation/screens/my_contributions_screen.dart` | `MyContributionsScreen` | `/my-contributions` | View contribution status |

### 🎓 Educational Features (3)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Quiz Selection** | `lib/src/features/quiz/presentation/screens/quiz_selection_screen.dart` | `QuizSelectionScreen` | `/quiz` | Select quiz difficulty/category |
| **Quiz Screen** | `lib/src/features/quiz/presentation/screens/quiz_screen.dart` | `QuizScreen` | *via navigation* | Interactive quiz gameplay |
| **Global Leaderboard** | `lib/src/features/quiz/presentation/screens/leaderboard_screen.dart` | `LeaderboardScreen` | `/leaderboard` | Competitive rankings & statistics |

### 🔧 Administrative Features (4)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **Approval Queue** | `lib/src/features/admin/presentation/screens/approval_queue_screen.dart` | `ApprovalQueueScreen` | `/approval-queue` | Review submissions |
| **Data Upload** | `lib/src/features/admin/presentation/screens/data_upload_screen.dart` | `DataUploadScreen` | `/data-upload` | Bulk data management |
| **Add Missionary** | `lib/src/features/admin/presentation/screens/missionary_add_screen.dart` | `MissionaryAddScreen` | *via navigation* | Add new missionaries |
| **Edit Missionary** | `lib/src/features/admin/presentation/screens/missionary_edit_screen.dart` | `MissionaryEditScreen` | *via navigation* | Edit missionary data |

### 🛠️ Development Tools (1)
| Screen Name | File | Class | Route | Purpose |
|-------------|------|-------|--------|---------|
| **API Test** | `lib/src/features/api_test/api_test_screen.dart` | `ApiTestScreen` | `/api-test` | API connectivity testing |

## 📊 Statistics
- **Total Screens:** 18
- **Public Routes:** 14  
- **Navigation-Only:** 4
- **Admin Screens:** 4
- **User-Facing:** 14

## 🎯 User-Friendly Names
For easy reference in conversations and documentation:

### Primary User Journey
1. **Splash** → **Login/Signup** → **Home Dashboard**
2. **Faithful Servants** (browse missionaries)
3. **Missionary Profile** (detailed view)  
4. **Treasured Saints** (favorites)
5. **Quiz System** (education)
6. **Global Leaderboard** (competitive rankings)

### Content Management
- **Contribute Stories** (user submissions)
- **My Contributions** (user's submission history)
- **Search** (advanced discovery)

### Administrative
- **Approval Queue** (content moderation)
- **Data Upload** (bulk management)
- **Add/Edit Missionary** (content creation)

## 🗺️ Navigation Flow
```
Splash Screen
├── Login Screen
├── Signup Screen
└── Home Dashboard
    ├── Faithful Servants (Missionary List)
    │   └── Missionary Profile
    ├── Treasured Saints (Favorites)
    ├── Search Screen
    ├── Quiz Selection
    │   └── Quiz Screen
    ├── Contribute Stories
    ├── My Contributions
    └── Admin Features
        ├── Approval Queue
        ├── Data Upload
        ├── Add Missionary
        └── Edit Missionary
```

## 🔄 Recent Updates
- **Timeline Enhancement:** Visual timeline improvements with gradient connectors, smart icons, and progress indicators
- **Global Leaderboard:** Enterprise-grade competitive ranking system with Firebase optimization
- **Leaderboard UI:** Improved layout with "Global Rankings" header positioned after user scores
- **Firebase Infrastructure:** Production-ready indexes with graceful fallback mechanisms
- **Status Indicators:** Real-time index building notifications and user-friendly messaging
- **Screen Navigation:** Fixed "Discover Saints" button in empty favorites
- **UI Improvements:** Centered heart icons, added audio placeholders, enhanced leaderboard UX
- **Favorites System:** Complete "Treasured Saints" implementation with real-time sync
- **Documentation Complete:** All 18 screens cataloged with comprehensive navigation guides

---
*Last Updated: August 30, 2025 - Development Status: 99% Complete*