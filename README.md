# Kinesa - Holistic Fitness & Wellbeing App

A comprehensive wellness app built with Flutter that integrates fitness tracking, habit building, workout management, health monitoring, and AI-powered coaching.

## Project Overview

**Target Users:** Busy professionals, fitness beginners, health-conscious individuals (ages 25-50)
**Platforms:** iOS and Android
**Status:** MVP complete

## Features

### Authentication and User Management
- Email/password authentication
- Google Sign-In integration
- Password reset flow
- User profile management

### Dashboard and Navigation
- Bottom navigation with 4 main tabs
- Dashboard with personalized welcome
- Quick stats overview
- Today's activity plan
- Recent activity feed

### Workouts
- Workout library with categorized exercises
- Workout cards with duration and difficulty
- Progress tracking

### Habits Tracking
- Daily habit management
- Habit completion tracking
- Streak tracking
- Custom habit creation

### Progress and Analytics
- Weekly activity overview
- Performance metrics
- Progress visualization
- Historical data tracking

### Health Integration
- Health data synchronization
- Steps tracking
- Heart rate monitoring
- Sleep tracking
- Workout logging
- Weight and height tracking

### Notifications
- Local push notifications
- Scheduled reminders
- Daily recurring notifications
- Notification management

### Settings and Customization
- Profile editing
- App preferences
- Notification settings
- Health sync configuration
- Privacy controls
- Dark mode support

### AI Coaching (In Progress)
- Personalized recommendations
- Mood insights
- Recovery guidance
- Prompt templates and caching

## Tech Stack

### Frontend
- Flutter 3.10.4+ (Dart)
- State management: Riverpod 2.6.1
- UI: Material Design 3
- Navigation: go_router 14.6.2
- Charts: fl_chart 0.70.1

### Backend and Services
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Messaging
- Firebase Analytics
- Firebase Crashlytics
- Firebase Remote Config

### Health and Device Integration
- health 10.0.0 (HealthKit and Health Connect)
- flutter_local_notifications 18.0.1
- timezone 0.9.4

### Additional Libraries
- google_sign_in, sign_in_with_apple
- cached_network_image, image_picker
- shared_preferences, flutter_secure_storage
- dio, hive, sentry_flutter

## Project Structure

```
lib/
  core/
    config/
    constants/
    errors/
    theme/
    utils/
  features/
    ai/
      data/
      domain/
      presentation/
    authentication/
      data/
      domain/
      presentation/
    health/
      data/
      domain/
      presentation/
    home/
      data/
      domain/
      presentation/
    notifications/
      data/
      domain/
      presentation/
    onboarding/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
    user/
      data/
      domain/
      presentation/
  routes/
  app.dart
  main.dart
  firebase_options.dart
```

## Getting Started

### Prerequisites

1. Flutter SDK (3.10.4 or higher)
   ```bash
   flutter doctor
   ```

2. Android Studio or Xcode (for iOS development on Mac)

3. Firebase CLI
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. FlutterFire CLI
   ```bash
   dart pub global activate flutterfire_cli
   ```

### Installation and Setup

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd kinesa
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase

   a. Create a Firebase project at https://console.firebase.google.com/

   b. Enable the following Firebase services:
      - Authentication (Email/Password, Google)
      - Cloud Firestore
      - Firebase Storage
      - Firebase Messaging
      - Firebase Analytics
      - Firebase Crashlytics
      - Firebase Remote Config

   c. Run FlutterFire configuration:
      ```bash
      flutterfire configure --project=your-project-id
      ```

   d. Select platforms (android, ios)

4. Android-specific setup

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

5. iOS-specific setup (Mac only)

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

6. Run the app
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

## AI Configuration

The Claude API key is stored **server-side only** for security. The app never has direct access to the API key.

### Architecture
- **Cloud Functions Proxy**: All AI requests go through a Cloud Run proxy (`claudeproxy`)
- **API Key**: Stored securely in Cloud Run environment variables
- **Client**: Only knows the proxy URL, never the API key

### Configuration via Firebase Remote Config

The following settings can be configured in Firebase Remote Config:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ai_proxy_url` | Cloud Functions proxy endpoint | (set in code) |
| `ai_default_model` | Default Claude model | `claude-3-haiku-20240307` |
| `ai_free_monthly_limit` | Free tier message limit | `20` |
| `ai_coach_enabled` | Enable AI Coach feature | `true` |
| `maintenance_mode` | Put app in maintenance mode | `false` |

### Build-time Override (Dev/Staging)

For different environments, use `--dart-define`:
```bash
flutter build apk --dart-define=AI_PROXY_URL=https://staging-proxy.example.com
```

## Testing

```bash
flutter test
flutter test integration_test/
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS (Mac only)
```bash
flutter build ipa --release
```

## Troubleshooting

- **Gradle build fails**
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

- **CocoaPods issues (iOS)**
  ```bash
  cd ios
  pod deintegrate
  pod install
  cd ..
  ```

- **Firebase configuration errors**
  ```bash
  flutterfire configure --force
  ```

## Development Phases

### Phase 0: Project Setup (Complete)
- Project initialization
- Dependencies configuration
- Firebase integration
- Core architecture setup

### Phase 1: Authentication (Complete)
- Email/password authentication
- Google Sign-In
- Password reset flow
- Auth state management

### Phase 2: Home and Navigation (Complete)
- Bottom navigation implementation
- Dashboard with stats
- Workouts tab
- Habits tab
- Progress tab

### Phase 3: User Profile and Settings (Complete)
- Profile screen
- Settings screen
- User preferences
- Account management

### Phase 4: Integrations (Complete)
- Health data integration
- Local notifications
- Firestore database
- Data models and services

### Phase 5: Advanced Features (Upcoming)
- Workout player with video
- Custom habit builder
- Advanced analytics and charts
- Social features
- AI-powered recommendations

## License

Proprietary - All rights reserved

---

Built with Flutter.
