PRODUCT REQUIREMENTS DOCUMENT (v1.1 - Incremental Development Plan)

Vision & Scope
Preserve and showcase the biographies, timelines, and impact of missionaries whose work directly affected India.
Android (Google Play) as first-launch platform; Web can follow.
English + all Indian languages for UI and (eventually) content.

Target Users
*   Church members / pastors seeking inspiration
*   Seminary students & researchers
*   Christian history enthusiasts
*   Curators / historians (admin role)

MVP Feature Set (Incremental Breakdown)

**Core Infrastructure & Initial Setup (Underpins all features)**
*   INFRA-01: Flutter Project Setup & Firebase Integration (Core, Auth, Firestore, Storage)
*   INFRA-02: Basic User Authentication (Email/Password, Google Sign-In)
*   INFRA-03: Basic App Navigation (e.g., Bottom Navigation or Drawer)
*   INFRA-04: User Roles Setup (Define `users/{uid}` with `role`: 'user'/'curator'/'admin')
*   INFRA-05: Initial Language Picker UI (WF-01 Splash & Language Picker - UI only for now)

**A. Missionary Directory & Search**
*   A1: Basic Missionary Data Model (`missionaries` collection: `fullName`, `heroImageUrl`) & Simple List Display
*   A2: Basic Search by `fullName` (Client-side or basic server-side)
*   A3: Expand Missionary Data Model (Add `years`, short `summary`/`bioExcerpt`) & Update List Display
*   A4: Filtering UI Setup (Filter button, dialog/panel for one criterion e.g., "Century")
*   A5: Implement "Century" Filter (Add relevant field to model, implement filter logic)
*   A6: Implement "Sending Country" Filter (Add field, UI, and logic)
*   A7: Implement "Indian Region" Filter (Add field, UI, and logic)
*   A8: Implement "Ministry Focus" Filter (Add field/tags, UI, and logic)
*   A9: Combine Filters & Search (Ensure they work together, refine filter UI)

**B. Missionary Profile**
*   B1: Basic Profile Screen (Navigate with `missionaryId`, display `fullName`, `heroImageUrl`)
*   B2: Display Biography (Add `bioMarkdown` to model, render on profile screen)
*   B3: Timeline Data Model (`timelineEvents` collection) & Basic List Display on Profile (title, date)
*   B4: Detailed Timeline Event View (Optional: Show full description on tap)
*   B5: Media Gallery Data Model (`media` collection: `missionaryId`, `type`='image', `storageUrl`) & Basic Grid Display on Profile
*   B6: Media Viewer (Full-screen image view with `caption`, `year` - WF-06)
*   B7: Display References (Add `references[]` to missionary model, display on profile)

**C. User Contributions (Photos & Anecdotes)**
*   C1: Contribution Form UI (WF-07 - Start with photo upload: image picker, caption)
*   C2: Photo Upload to Firebase Storage (Image picking, compression, upload)
*   C3: Save Photo Contribution to Firestore (`media` collection: `missionaryId`, `storageUrl`, `caption`, `contributedBy`, `status`='pending')
*   C4: Anecdotes Contribution (Extend form for text anecdotes, save to Firestore with `type`='anecdote' or similar)

**D. Favorites & Shareable Quote Cards**
*   D1: Favorites Data Model (`favorites/{uid}/items/{mid}`) & Toggle on Profile Screen
*   D2: Favorites Screen (WF-08 - List user's favorited missionaries)
*   D3: Shareable Quote Cards - Data Preparation (Identify quote sources; UI/generation can be post-MVP or a later iteration of this feature)

**E. Simple Donate Page**
*   E1: Basic Donate Screen UI (WF-09 - Informational content)
*   E2: Link to External Razorpay Payment Page (Button linking out)

**F. Admin Console (Curators)**
*   F1: Secure Admin Area (Protect access based on 'curator'/'admin' role via Firestore rules & in-app checks)
*   F2: Contribution Approval Queue UI (WF-10 - List `media` items with `status`='pending')
*   F3: Approve/Reject Contribution Logic (Update `media` item `status` to 'approved' or 'rejected')
*   F4: Basic Missionary Data Editing for Curators (Allow editing of selected fields like `bioMarkdown`, `years`)

Deferred to Post-MVP:
*   Interactive map view (WF-05)
*   Advanced multilingual content (full content translation)
*   Analytics dashboard
*   Full implementation of Shareable Quote Card generation

Non-Functional Requirements
*   Framework: Flutter SDK 3.22+
*   Backend: Firebase (Auth, Firestore, Storage, Cloud Functions for any server-side logic e.g., donation webhook)
*   Performance: Offline read cache for Firestore data; responsive layout for various screen sizes.
*   Security: Role-based security implemented via Firestore rules and in-app checks.
*   Media Handling: Image compression (target ≤1 MB per user upload); CDN for media delivery (Firebase Storage default).
*   Compliance: Consider India-based hosting options or a `.in` domain if web version proceeds and requires it.

Data Model (Firestore) - Summary
*   `missionaries/{mid}` → `fullName`, `years`, `bioMarkdown`, `tags` (for ministry focus, region, etc.), `heroImageUrl`, `references[]`, `century`, `sendingCountry`, `indianRegion`
*   `timelineEvents/{eventId}` → `missionaryId` (FK), `dateISO`, `title`, `desc`, `latLng` (optional)
*   `media/{mediaId}` → `missionaryId` (FK), `type` (image/anecdote), `storageUrl` (for images), `text` (for anecdotes), `caption`, `year`, `contributedBy` (uid), `status` (pending/approved/rejected)
*   `favorites/{uid}/items/{mid}` → (empty document or timestamp for ordering, `mid` is doc ID)
*   `donations/{donationId}` → (Details from Razorpay webhook, processed by a Cloud Function)
*   `users/{uid}` → `role` (user/curator/admin), `displayName`, `email`

Key Screens / Wireframes (Referenced by WF-xx codes above)
*   WF-01 Splash & Language Picker
*   WF-02 Home / Featured Missionaries
*   WF-03 Directory & Filters
*   WF-04 Profile Screen (Tabs/Sections for Bio, Timeline, Media, References)
*   WF-05 Map / Timeline View (Post-MVP)
*   WF-06 Media Viewer (Full-screen image/video)
*   WF-07 Add Contribution Flow (Multi-step form)
*   WF-08 Favorites Screen
*   WF-09 Donate Screen
*   WF-10 Admin Console (Approval Queue, Basic Editing Tools)

Tech Stack & Packages (Indicative)
*   Flutter SDK 3.22+
*   Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
*   State Management: Provider (or Riverpod, Bloc - developer choice)
*   Networking/Media: `cached_network_image`, `image_picker`, `image_compression` package
*   UI: `google_fonts`, `flutter_markdown`
*   Localization: `intl`, `flutter_localizations`
*   Routing: (e.g., `go_router` or Flutter's built-in Navigator 2.0)

Schedule – Solo Developer (Estimate: ≈18-24 weeks for MVP items above, depending on depth of each increment)
*   Sprint 0 (2 wks): Core Infrastructure & Initial Setup (INFRA tasks)
*   Sprints for Module A (Directory & Search - 3-4 wks): A1-A9
*   Sprints for Module B (Profile - 3-4 wks): B1-B7
*   Sprints for Module D (Favorites - 1-2 wks): D1-D2 (D3 data prep)
*   Sprints for Module C (Contributions - 3-4 wks): C1-C4
*   Sprints for Module F (Admin - 2-3 wks): F1-F4
*   Sprints for Module E (Donate - 1 wk): E1-E2
*   Buffer / Polish / Testing Sprints (2-3 wks)
    *(Note: Schedule is a rough estimate and can be adjusted. Some tasks can be parallelized if sub-components are independent.)*

Success Metrics
*   Monthly active users (MAU)
*   Average number of missionary profiles viewed per active user
*   Number of user contributions submitted and approved
*   Donation volume (if E is implemented fully)
*   App Store ratings and reviews

Risks & Mitigations
*   Missing historical media for profiles → Mitigation: Prioritize user contributions (C) with a robust curation process (F).
*   Copyright issues with historical images/texts → Mitigation: Emphasize public-domain sources, user-contributed content (with terms stating they have rights), or seek licenses where necessary.
*   Solo-developer bandwidth & scope creep → Mitigation: Stick to the defined MVP incremental steps, defer non-essential features, leverage Flutter community packages and potentially low-code tools for admin interfaces if speed is critical.
*   Data accuracy and historical verification → Mitigation: Curator role (F) is critical. Clearly state if content is user-contributed and awaiting verification.
*   Multilingual content complexity → Mitigation: For MVP, UI in English + one major Indian language. Content translation primarily post-MVP, or start with titles/summaries.
