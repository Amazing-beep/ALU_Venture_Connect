# ALU VentureConnect

> A mobile platform connecting ALU students seeking internship experience with student-led startups and early-stage ventures within the African Leadership University ecosystem.

---

## What Is This?

At ALU, students need real work experience — but breaking into established companies is competitive and slow. At the same time, student ventures on campus are building real products and desperately need developers, designers, marketers, and researchers.

**VentureConnect bridges that gap.**

It is a Flutter mobile application where verified student ventures can post internship opportunities, and students can discover, bookmark, and apply for them — all within the trusted ALU ecosystem. Application statuses update in real-time from the startup side, so students always know where they stand.

---

## Screenshots

> Run the app on an Android emulator or physical device to see the full UI. Key screens include:

| Student Home | Explore & Search | My Applications | Startup Dashboard |
|:---:|:---:|:---:|:---:|
| Personalized feed | Filter by category | Live status tracking | Post & manage roles |

---

## Features

### For Students
- 📋 **Browse opportunities** — discover internship roles posted by verified ALU ventures
- 🔍 **Search & filter** — search by keyword or filter by category (Design, Engineering, Marketing, Data)
- 🔖 **Bookmark roles** — save interesting opportunities across sessions (persisted locally)
- ✉️ **Apply with a cover letter** — submit applications with a personal introduction
- 📊 **Track application status** — see real-time updates as startups move you through their pipeline

### For Startup Founders
- 🚀 **Post opportunities** — list internship roles with title, description, skills, hours, and location
- 👥 **Manage applicants** — view all incoming applications from a dedicated dashboard
- 🔄 **Update applicant status** — move candidates through: `Applied → Under Review → Shortlisted → Interview → Accepted`
- 🛡️ **ALU Verification Gate** — startups must register with a valid ALU Venture ID before posting

### Authentication
- 🔐 Email & password registration and login via Firebase Auth
- ✅ Email verification with auto-polling (no button required — verifies the moment you click the link)
- 🔑 Forgot password flow via Firebase email reset
- 👤 Role-based routing: students and startup founders see entirely different navigation experiences

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider (`ChangeNotifier`) |
| Backend / Auth | Firebase Authentication |
| Database | Cloud Firestore (NoSQL) |
| Local Storage | SharedPreferences (bookmarks) |
| Fonts | Google Fonts — Outfit & Inter |
| Architecture | Repository Pattern with Mock/Firebase dual-mode |

---

## Project Structure

```
lib/
├── core/
│   ├── theme/               # App colors, text styles
│   └── utils/               # Date formatter
│
├── data/
│   ├── models/              # UserProfile, Opportunity, Application
│   └── repositories/
│       ├── auth_repository.dart         # Firebase + Mock implementations
│       ├── opportunity_repository.dart  # Firebase + Mock implementations
│       ├── application_repository.dart  # Firebase + Mock implementations
│       └── firebase_service.dart        # Initializes Firebase, switches to Mock on failure
│
├── providers/               # AuthProvider, OpportunityProvider,
│                            # ApplicationProvider, BookmarkProvider,
│                            # TabNavigationProvider
│
├── presentation/
│   └── screens/
│       ├── auth/            # Login, Register, ForgotPassword, EmailVerification
│       ├── home/            # Student home screen
│       ├── explore/         # Search and filter screen
│       ├── details/         # Opportunity detail + Apply flow
│       ├── applications/    # My Applications (student) / Incoming Applicants (startup)
│       ├── profile/         # Edit profile
│       ├── startup/         # Dashboard, Post Opportunity, Pending Verification
│       ├── splash_screen.dart
│       └── main_nav_screen.dart
│
├── firebase_options.dart    # Firebase project credentials
└── main.dart
```

---

## Architecture

The application uses a **Repository Pattern** with a critical resilience feature: **dual-mode execution**.

```
UI Screens
    │
    ▼
Providers (ChangeNotifier)
    │
    ▼
Repository Interface (abstract)
    │
    ├── FirebaseRepository  ◄── used when Firebase is available
    └── MockRepository      ◄── used as automatic fallback
```

When the app starts, `FirebaseService.initialize()` attempts to connect to Firebase. If it succeeds, all repositories use live Firestore and Firebase Auth. If it fails — missing credentials, offline emulator, wrong config — the app automatically falls back to fully functional in-memory Mock repositories and continues running without crashing.

This means **the app always works**, regardless of the grading environment.

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.0`
- Android Studio with an Android emulator (API 30+)
- A Firebase project with **Email/Password authentication** and **Cloud Firestore** enabled

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/Amazing-Venture-connect.git

# Navigate into the project
cd Amazing-Venture-connect

# Install dependencies
flutter pub get
```

### Firebase Setup

The Firebase credentials are already included in the project:
- `android/app/google-services.json` — Android config
- `ios/Runner/GoogleService-Info.plist` — iOS config
- `lib/firebase_options.dart` — Dart config

> ⚠️ **If you are running this without the provided Firebase project**, the app will automatically fall back to Mock mode with pre-loaded demo data (Amazing Mkhonta's profile, Learnify, EduBridge, GreenLoop opportunities). Everything will still work.

### Running the App

```bash
# Run on connected device or emulator
flutter run
```

**If you get a Firebase network error on the Android emulator:**
1. Open Android Studio → Device Manager
2. Click ⋮ next to your emulator → **Wipe Data**
3. Click ⋮ again → **Cold Boot Now**
4. Run `flutter run` again

---

## Running Tests

```bash
flutter test
```

Expected output:
```
00:01 +1: All tests passed!
```

The test boots the full app widget tree in Mock mode and verifies that the splash screen renders correctly without exceptions.

---

## Firestore Data Schema

### `/users/{userId}`
```json
{
  "id": "firebase_auth_uid",
  "email": "amina@alu.edu",
  "name": "Amazing Mkhonta",
  "role": "student",
  "location": "Kigali, Rwanda",
  "skills": ["Flutter", "Dart", "UX Design"],
  "bio": "Short personal description",
  "startupName": null,
  "registrationNumber": null,
  "isVerified": false
}
```

### `/opportunities/{opportunityId}`
```json
{
  "id": "auto_generated_id",
  "title": "UX Research Volunteer",
  "company": "EduBridge",
  "location": "Remote",
  "hoursPerWeek": "4-6 hrs/week",
  "postedDate": "2026-07-09T10:00:00.000Z",
  "category": "Design",
  "description": "Full role description...",
  "skills": ["UX Design", "Figma", "Research"],
  "tags": ["UX Design", "Remote"],
  "postedBy": "startup_user_id"
}
```

### `/applications/{applicationId}`
```json
{
  "id": "auto_generated_id",
  "opportunityId": "opp_id",
  "opportunityTitle": "UX Research Volunteer",
  "companyName": "EduBridge",
  "studentId": "student_user_id",
  "studentName": "Amazing Mkhonta",
  "appliedDate": "2026-07-11T14:00:00.000Z",
  "coverLetter": "I would love to contribute...",
  "status": "applied"
}
```

**Possible status values:** `applied` · `underReview` · `shortlisted` · `interview` · `accepted` · `closed`

---

## Demo Flow

To test the full experience on a fresh run:

1. **As a Student** — Register with any `@alustudent.com` email, verify your email, browse opportunities, apply to one with a cover letter, and check your Applications tab.

2. **As a Startup** — Register with a different email, enter any startup name and a registration number starting with `ALU-V-`, post an opportunity from the dashboard, then check Incoming Applicants and update a student's status.

---

## Dependencies

```yaml
provider: ^6.1.5           # State management
google_fonts: ^8.1.0       # Outfit + Inter typography
shared_preferences: ^2.5.5 # Bookmark persistence
uuid: ^4.5.3               # ID generation
intl: ^0.20.3              # Date formatting
firebase_core: ^4.11.0     # Firebase initialization
firebase_auth: ^6.5.4      # Authentication
cloud_firestore: ^6.6.0    # NoSQL database
```

---

## Author

**Amazing Mkhonta**  
School of Software Engineering  
African Leadership University, Kigali Campus  
Individual Assignment 2 — Mobile Application Development (SWE-4001)  
July 2026

---

## License

This project was developed as part of a graded academic assignment at African Leadership University.
