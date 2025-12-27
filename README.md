# GrandMind - Holistic Fitness & Wellbeing App

A comprehensive wellness app built with Flutter that integrates fitness tracking, habit building, workout management, and health monitoring with personalized insights and progress tracking.

## 🎯 Project Overview

**Target Users:** Busy professionals, fitness beginners, health-conscious individuals (ages 25-50)
**Platforms:** iOS & Android
**Status:** MVP Complete ✅

## ✨ Features

### Authentication & User Management
- ✅ Email/Password authentication
- ✅ Google Sign-In integration
- ✅ Password reset functionality
- ✅ Automatic login persistence
- ✅ User profile management

### Dashboard & Navigation
- ✅ Bottom navigation with 4 main tabs
- ✅ Dashboard with personalized welcome
- ✅ Quick stats overview
- ✅ Today's activity plan
- ✅ Recent activity feed

### Workouts
- ✅ Workout library with categorized exercises
- ✅ Workout cards with duration and difficulty
- ✅ Interactive workout interface
- ✅ Progress tracking

### Habits Tracking
- ✅ Daily habit management
- ✅ Habit completion tracking
- ✅ Progress visualization
- ✅ Streak tracking
- ✅ Custom habit creation

### Progress & Analytics
- ✅ Weekly activity overview
- ✅ Performance metrics
- ✅ Achievement system
- ✅ Progress visualization
- ✅ Historical data tracking

### Health Integration
- ✅ Health data synchronization
- ✅ Steps tracking
- ✅ Heart rate monitoring
- ✅ Sleep tracking
- ✅ Workout logging
- ✅ Weight and height tracking

### Notifications
- ✅ Local push notifications
- ✅ Scheduled reminders
- ✅ Daily recurring notifications
- ✅ Notification management

### Settings & Customization
- ✅ Profile editing
- ✅ App preferences
- ✅ Notification settings
- ✅ Health sync configuration
- ✅ Privacy controls
- ✅ Dark mode support

## 🛠 Tech Stack

### Frontend
- **Flutter** 3.10.4+ (Dart)
- **State Management:** Riverpod 2.6.1
- **UI Framework:** Material Design 3
- **Navigation:** go_router 14.6.2
- **Charts:** fl_chart 0.70.1

### Backend & Services
- **Firebase Authentication** - User authentication & authorization
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Storage** - File storage for images/videos
- **Firebase Messaging** - Push notifications
- **Firebase Analytics** - User behavior tracking
- **Firebase Crashlytics** - Error monitoring & crash reporting

### Health & Device Integration
- **health** 13.2.1 - HealthKit (iOS) & Health Connect (Android)
- **flutter_local_notifications** 18.0.1 - Local notifications
- **timezone** 0.9.4 - Timezone support for scheduling

### Additional Libraries
- **google_sign_in** 6.2.2 - Google OAuth
- **cached_network_image** 3.4.1 - Image caching
- **image_picker** 1.1.2 - Camera/gallery access
- **shared_preferences** 2.3.4 - Local data persistence
- **connectivity_plus** 6.1.2 - Network status monitoring

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # App-wide constants
│   │   ├── route_constants.dart     # Navigation routes
│   │   └── firebase_constants.dart  # Firebase config
│   ├── theme/
│   │   ├── app_theme.dart           # Theme configuration
│   │   └── app_colors.dart          # Color palette
│   ├── utils/
│   │   ├── validators.dart          # Form validators
│   │   ├── formatters.dart          # Data formatters
│   │   └── helpers.dart             # Helper functions
│   └── errors/
│       ├── exceptions.dart          # Custom exceptions
│       └── failures.dart            # Error handling
│
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           └── forgot_password_screen.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── dashboard_tab.dart
│   │       │   ├── workouts_tab.dart
│   │       │   ├── habits_tab.dart
│   │       │   └── progress_tab.dart
│   │       └── widgets/
│   │           └── bottom_nav_bar.dart
│   │
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/
│   │           └── profile_screen.dart
│   │
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   ├── health/
│   │   └── data/
│   │       └── services/
│   │           └── health_service.dart
│   │
│   ├── notifications/
│   │   └── data/
│   │       └── services/
│   │           └── notification_service.dart
│   │
│   └── user/
│       └── data/
│           ├── models/
│           │   └── user_model.dart
│           └── services/
│               └── firestore_service.dart
│
├── routes/
│   └── app_router.dart              # Route configuration
│
├── app.dart                         # App widget
├── main.dart                        # App entry point
└── firebase_options.dart            # Firebase config (auto-generated)
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.10.4 or higher)
   ```bash
   flutter doctor
   ```

2. **Android Studio** or **Xcode** (for iOS development on Mac)

3. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd grandmind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   a. Create a Firebase project at https://console.firebase.google.com/

   b. Enable the following Firebase services:
      - Authentication (Email/Password, Google)
      - Cloud Firestore
      - Firebase Storage
      - Firebase Messaging
      - Firebase Analytics
      - Firebase Crashlytics

   c. Run FlutterFire configuration:
      ```bash
      flutterfire configure --project=your-project-id
      ```

   d. Select platforms (android, ios)

4. **Android-specific setup**

   Update `android/app/build.gradle.kts`:
   ```kotlin
   defaultConfig {
       minSdk = 26  // Required for health plugin
       targetSdk = 34
   }

   compileOptions {
       sourceCompatibility = JavaVersion.VERSION_17
       targetCompatibility = JavaVersion.VERSION_17
       isCoreLibraryDesugaringEnabled = true
   }

   dependencies {
       coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
   }
   ```

5. **iOS-specific setup** (Mac only)

   Update `ios/Podfile`:
   ```ruby
   platform :ios, '13.0'
   ```

   Add HealthKit permissions to `ios/Runner/Info.plist`:
   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>We need access to your health data to track your fitness progress</string>
   <key>NSHealthUpdateUsageDescription</key>
   <string>We need permission to update your health data</string>
   ```

6. **Run the app**
   ```bash
   # List available devices
   flutter devices

   # Run on specific device
   flutter run -d <device-id>

   # Run in release mode
   flutter run --release
   ```

## 🔧 Configuration

### Firebase Configuration

The app uses Firebase for backend services. Configuration is stored in:
- `lib/firebase_options.dart` (auto-generated by FlutterFire CLI)
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

### Environment Variables

Create a `.env` file in the root directory for sensitive configuration:
```env
API_KEY=your_api_key
DEBUG_MODE=true
```

## 🧪 Testing

Run tests with:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/
```

## 📱 Building for Production

### Android
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS (Mac only)
```bash
# Generate IPA
flutter build ipa --release
```

## 🐛 Troubleshooting

### Build Issues

1. **Gradle build fails**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **CocoaPods issues (iOS)**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

3. **Firebase configuration errors**
   ```bash
   flutterfire configure --force
   ```

### Common Issues

- **minSdk error**: Ensure `minSdk = 26` in `android/app/build.gradle.kts`
- **Core library desugaring**: Add desugaring dependency and enable it
- **Health permissions**: Verify permissions are added to platform-specific files

## 🏗 Development Phases

### ✅ Phase 0: Project Setup (Completed)
- Project initialization
- Dependencies configuration
- Firebase integration
- Core architecture setup

### ✅ Phase 1: Authentication (Completed)
- Email/password authentication
- Google Sign-In
- Password reset flow
- Auth state management

### ✅ Phase 2: Home & Navigation (Completed)
- Bottom navigation implementation
- Dashboard with stats
- Workouts tab
- Habits tab
- Progress tab

### ✅ Phase 3: User Profile & Settings (Completed)
- Profile screen
- Settings screen
- User preferences
- Account management

### ✅ Phase 4: Integrations (Completed)
- Health data integration
- Local notifications
- Firestore database
- Data models & services

### 🚧 Phase 5: Advanced Features (Upcoming)
- Workout player with video
- Custom habit builder
- Advanced analytics & charts
- Social features
- AI-powered recommendations

## 📖 Code Standards

- **Architecture:** Clean Architecture with feature-first organization
- **State Management:** Riverpod for reactive state management
- **Code Style:** Official Flutter/Dart style guide
- **Naming:** descriptive_snake_case for files, PascalCase for classes
- **Documentation:** Inline comments for complex logic

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Proprietary - All rights reserved

## 📞 Support

For issues and questions:
- Create an issue in the repository
- Contact the development team

---

**Built with ❤️ using Flutter**
