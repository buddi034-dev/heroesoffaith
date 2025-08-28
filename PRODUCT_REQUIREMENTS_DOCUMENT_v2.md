# PRODUCT REQUIREMENTS DOCUMENT (v2.0)
## Heroes of Faith - Missionary Profiles App

---

## 📋 **Vision & Scope**
Preserve and showcase the biographies, timelines, and impact of missionaries whose work directly affected India.
- **Platform**: Android (Google Play) first, iOS/Web following
- **Languages**: English + Indian languages for UI and content
- **Approach**: Incremental MVP with spiritual-themed user experience

---

## 👥 **Target Users**
- Church members / pastors seeking inspiration
- Seminary students & researchers  
- Christian history enthusiasts
- Curators / historians (admin role)

---

## 🏗️ **Architecture (Updated v2.0)**

### **Hybrid Cloud Architecture**
```
Mobile App (Flutter)
├── Firebase (User Management Only)
│   ├── Authentication (Email + Google Sign-In)
│   ├── Firestore (User data, favorites, preferences)
│   └── App Check (Security)
├── Cloudflare Workers API (Primary Data Source)
│   ├── Edge Caching (Global performance)
│   ├── Wikimedia Integration (Historical data)
│   └── GitHub Repository (Custom profiles)
└── Local Cache (Offline Support)
    ├── Hive Database (Structured data)
    └── SharedPreferences (User settings)
```

### **Key Architecture Benefits**
- **Cost Effective**: Free Cloudflare tier vs expensive Firestore reads
- **Global Performance**: Edge caching via Cloudflare CDN
- **Rich Data**: Wikimedia integration for historical accuracy
- **Offline First**: Multi-level caching strategy
- **Scalable**: Can handle massive user growth without cost explosion

---

## 🛠️ **Updated Tech Stack**

### **Core Dependencies**
```yaml
# Flutter Framework
flutter: 3.22+

# Authentication & User Management (Firebase)
firebase_core: ^2.x
firebase_auth: ^4.x
cloud_firestore: ^4.x
firebase_app_check: ^0.2.x
google_sign_in: ^6.x

# API & Networking (Cloudflare Integration)
dio: ^5.4.0                    # HTTP client for API calls
connectivity_plus: ^5.0.2      # Network connectivity checks

# Local Storage & Caching
hive_flutter: ^1.1.0           # Local database
shared_preferences: ^2.2.3     # User preferences
cached_network_image: ^3.x     # Image caching

# UI & UX
google_fonts: ^6.x             # Typography
shimmer: ^3.0.0               # Loading states
equatable: ^2.0.5             # Object comparisons

# Platform Integration
google_maps_flutter: ^2.5.3   # Maps for mission fields
```

---

## 📊 **Data Architecture**

### **1. Cloudflare Workers API (Primary Data Source)**
**Base URL**: `https://missionary-profiles-api.jbr01061981.workers.dev`

**Endpoints:**
```
GET /health                    # API health status
GET /api/profiles              # Paginated missionary list
GET /api/profile/{id}          # Individual missionary profile
GET /api/search/{query}        # Full-text search
GET /api/locations             # Mission field coordinates
```

**Enhanced Data Model:**
```typescript
interface EnhancedMissionary {
  id: string
  name: string
  displayName: string
  dates: { birth?: number, death?: number, display: string }
  image?: string
  images: string[]
  summary: string
  biography: BiographySection[]
  timeline: TimelineEvent[]
  locations: MissionaryLocation[]
  categories: string[]
  quiz: QuizQuestion[]
  achievements: string[]
  source: 'wikimedia' | 'github' | 'custom'
  sourceUrl: string
  attribution: string
  lastModified: string
  lang: string
}
```

### **2. Firebase (User Management Only)**
**Collections:**
```
users/{uid} → {
  role: 'user' | 'curator' | 'admin'
  displayName: string
  email: string
  createdAt: timestamp
  preferences: object
}

favorites/{uid}/items/{mid} → {
  addedAt: timestamp
  missionaryId: string
  missionaryName: string
}

contributions/{id} → {
  missionaryId: string
  type: 'photo' | 'anecdote'
  content: string | imageUrl
  caption: string
  contributedBy: uid
  status: 'pending' | 'approved' | 'rejected'
  submittedAt: timestamp
}
```

### **3. Local Cache Strategy**
**Cache Types & TTL:**
- **Profiles**: 24 hours (individual missionary data)
- **Profile Lists**: 12 hours (paginated directory data)
- **Search Results**: 6 hours (search query responses)
- **Locations**: 48 hours (mission field coordinates)
- **User Preferences**: Persistent (favorites, settings)

**Storage Implementation:**
```dart
// Hive Boxes (Structured Data)
Box<String> missionaryBox     # Individual profiles
Box<String> profilesListBox   # Directory listings
Box<String> searchBox         # Search results
Box<String> locationsBox      # Mission coordinates

// SharedPreferences (User Data)
favorites, settings, search_history, user_preferences
```

---

## 🎨 **Spiritual UI Language System**

### **Core Concept**
Transform standard app terminology into inspiring biblical/spiritual language.

**Key Transformations:**
| Standard | Spiritual Enhanced |
|----------|-------------------|
| Login | "Enter the Fellowship" |
| Search | "Seek Among Saints" |
| Home | "Fellowship Hall" |
| Profile | "Witness Their Testament" |
| Favorites | "Treasured Saints" |
| Loading... | "Gathering Testimonies..." |
| Read More | "Continue the Journey" |
| Share | "Spread the Word" |
| Settings | "Prepare Your Heart" |
| About | "Our Calling" |

**Implementation:**
```dart
class SpiritualStrings {
  static const String searchHint = 'Seek faithful servants...';
  static const String faithfulServants = 'Faithful Servants';
  static const String seekAgain = 'Seek Again';
  
  // Dynamic loading messages
  static String get randomLoadingMessage => // Rotates spiritual messages
}
```

---

## 🚀 **MVP Feature Set (Updated)**

### **A. Enhanced Missionary Directory & Search** ✅ **COMPLETED** (6 Comprehensive Profiles)
- A1-A9: All filtering and search functionality implemented
- **Enhancements Beyond PRD:**
  - Real-time search with API integration
  - Advanced filtering by categories and centuries
  - Spiritual-themed UI language
  - Offline support with intelligent caching

### **B. Rich Missionary Profiles** ✅ **COMPLETED** (Enhanced API with Rich Content)  
- B1-B7: All profile features implemented
- **Enhancements Beyond PRD:**
  - Interactive timeline with historical context
  - Rich biographical sections from Wikimedia
  - Achievement lists and categorization
  - Quiz system with educational questions
  - Location data with coordinates for mapping

### **C. User Contributions** 🚧 **IN PROGRESS**
- C1-C2: Basic admin upload system implemented
- **Remaining:**
  - C3: Public user contribution form
  - C4: Curator approval queue workflow

### **D. Favorites System** 🔄 **BACKEND READY**
- D1: Data model implemented in Firebase
- D2: Local caching system in place
- **Remaining:**
  - UI implementation for favorites management

### **E. Donations Integration** ❌ **PLANNED**
- E1: Informational donate screen
- E2: Razorpay payment integration (India-focused)

### **F. Admin Console** 🚧 **PARTIALLY IMPLEMENTED**
- F1: Role-based access system designed
- F2: Basic admin upload tools functional
- **Remaining:**
  - F3: Approval queue management UI
  - F4: Content editing interface

---

## 🆕 **New Features (Beyond Original PRD)**

### **1. Interactive Timeline System**
- Rich timeline events from historical data
- Visual journey mapping with dates
- Educational context and significance

### **2. Quiz & Learning System**
- Auto-generated questions from biography data
- Progressive difficulty levels
- Educational explanations and context

### **3. Global Mission Maps**
- Interactive world map with mission locations
- Historical routes and field assignments
- Coordinate-based location data

### **4. Advanced Offline Support**
- Intelligent multi-level caching
- Fallback data sources (GitHub → Cache → System)
- Offline-first architecture

### **5. API Testing Infrastructure**
- Comprehensive test screen for developers
- Fallback system testing
- Cache performance monitoring

---

## 🔧 **Non-Functional Requirements (Updated)**

### **Performance**
- **Startup Time**: All services initialize in background (<3 seconds)
- **Data Loading**: Edge caching provides <500ms API responses globally
- **Offline Support**: Full functionality without network connection
- **Cache Efficiency**: Intelligent TTL prevents unnecessary API calls

### **Security**
- **Firebase App Check**: Play Integrity verification for Android
- **Role-Based Access**: Curator/admin permissions via Firestore rules
- **API Security**: Cloudflare security features and DDoS protection
- **Data Privacy**: GDPR-compliant caching and user data handling

### **Scalability**
- **Cost Structure**: Free tier supports 100K+ monthly users
- **Global Performance**: Cloudflare edge locations worldwide
- **Data Growth**: API can handle unlimited missionary profiles
- **User Growth**: Firebase scales automatically for authentication

### **Reliability**
- **Fallback Systems**: Multiple data sources prevent single point of failure
- **Error Handling**: Graceful degradation with spiritual-themed messages
- **Cache Resilience**: Local storage ensures app functionality
- **Network Tolerance**: Offline-first approach handles poor connectivity

---

## 📱 **Key Screens (Updated)**

### **Core User Flows**
```
1. Splash → Authentication → Fellowship Hall (Home)
2. Fellowship Hall → Seek Among Saints (Search) → Witness Testament (Profile)
3. Profile → Timeline → Quiz → Share Journey
4. Treasured Saints (Favorites) → Manage Collections
5. Admin → Approval Queue → Content Management
```

### **Enhanced Screen Capabilities**
- **WF-01**: Splash with service initialization indicators
- **WF-02**: Home with spiritual greeting and feature access
- **WF-03**: Directory with advanced API-powered search
- **WF-04**: Profile with timeline, quiz, and rich biography
- **WF-05**: Interactive maps with mission field locations
- **WF-06**: Media viewer with zoom and attribution
- **WF-07**: Contribution flow with approval workflow
- **WF-08**: Favorites with sync across devices
- **WF-09**: Donations with Razorpay integration
- **WF-10**: Admin console with approval queue
- **WF-11**: API test screen for development validation

---

## 🗓️ **Updated Development Schedule**

### **Phase 1: Infrastructure & API** ✅ **COMPLETED** (3 weeks)
- Cloudflare Workers API deployment
- Flutter app API integration
- Cache system implementation
- Service architecture setup

### **Phase 2: Core Features** ✅ **COMPLETED** (4 weeks) 
- Enhanced directory and search
- Rich profile system with timeline
- Spiritual UI language implementation
- Offline functionality

### **Phase 3: User Features** 🔄 **IN PROGRESS** (3 weeks)
- Favorites system UI
- User contributions workflow
- Quiz system interface
- Maps integration

### **Phase 4: Admin & Polish** 📋 **PLANNED** (3 weeks)
- Admin console completion
- Approval queue workflow
- Donations integration
- Final testing and optimization

### **Phase 5: Deployment** 📋 **PLANNED** (2 weeks)
- Play Store preparation
- Production environment setup
- Performance optimization
- Launch preparation

**Total Timeline**: ~15 weeks (vs original 18 weeks)
**Status**: Ahead of schedule due to advanced API integration

---

## 📈 **Success Metrics (Updated)**

### **User Engagement**
- Monthly active users
- Average profiles viewed per session
- Search queries per user
- Time spent on profile pages
- Quiz completion rates

### **Content Interaction** 
- Favorite missionaries added
- Timeline events viewed
- Quiz questions answered correctly
- Shared content via social features

### **Technical Performance**
- API response times (<500ms target)
- Cache hit rates (>80% target)
- Offline usage percentage
- App crash rates (<0.1% target)

### **Business Metrics**
- User acquisition cost (organic focus)
- Donation conversion rates
- Content contribution volume
- Curator approval efficiency

---

## ⚠️ **Risks & Mitigations (Updated)**

### **Technical Risks**
| Risk | Mitigation |
|------|------------|
| API Downtime | Multi-level fallback system |
| Data Quality | Wikimedia + manual curation |
| Cache Corruption | Version management + cleanup |
| Performance Issues | Edge caching + optimization |

### **Content Risks**
| Risk | Mitigation |
|------|------------|
| Copyright Issues | Public domain + attribution system |
| Historical Accuracy | Wikipedia sourcing + fact checking |
| Incomplete Profiles | Community contributions + curation |
| Image Availability | Fallback images + graceful handling |

### **Business Risks**
| Risk | Mitigation |
|------|------------|
| Cost Scalability | Free-tier architecture design |
| User Adoption | Spiritual UX + organic marketing |
| Content Moderation | Curator approval workflow |
| Competition | Unique spiritual positioning |

---

## 🎯 **Immediate Priorities (Next Session)**

### **High Priority** (Complete core PRD features)
1. **Favorites System UI** - Backend ready, needs interface
2. **User Contributions Workflow** - Enable community content
3. **Admin Approval Queue** - Complete curator tools

### **Medium Priority** (Enhanced user experience) 
1. **Quiz System Interface** - Rich educational content available
2. **Timeline Enhancement** - Visual improvements to existing data
3. **Maps Integration** - Location data ready for visualization

### **Low Priority** (Polish & optimization)
1. **Donations Page** - Razorpay integration
2. **Performance Optimization** - Already performing well
3. **Additional Spiritual Language** - Expand terminology

---

**Document Version**: 2.0  
**Last Updated**: 2025-08-27 - Major API Enhancement Complete  
**Architecture Status**: ✅ Hybrid Firebase + Cloudflare implementation complete  
**Development Status**: ✅ 75% complete, significantly ahead of original schedule with enhanced API deployment  
**Next Milestone**: Complete core PRD features for MVP launch

## 🌟 **Latest Major Update (2025-08-27)**

### **Cloudflare Workers API Enhancement - DEPLOYED**
- **Achievement**: Expanded from 3 basic to 6 comprehensive missionary profiles
- **New Missionaries Added**:
  - Dr. Ida Scudder (1870-1960) - Medical missionary, CMC Vellore founder
  - Alexander Duff (1806-1878) - Educational pioneer, modern Indian education architect
  - Pandita Ramabai (1858-1922) - Social reformer, women's rights advocate
- **Enhanced Features**:
  - Rich multi-paragraph biographies
  - Detailed timelines with historical context
  - Interactive educational quizzes
  - Mission locations with geographic coordinates
  - Working Wikipedia Commons images
  - Achievement records and legacy documentation
- **API Version**: 18cbbdc6-8e72-400b-b603-30bb472f984d
- **Status**: ✅ Live and tested in Flutter app