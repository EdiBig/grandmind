# Grandmind (Kinesa) - Project Status

**Last Updated:** 2026-01-05 (Habits Feature + AI Insights Session)
**GitHub Repository:** https://github.com/EdiBig/grandmind
**Project Location:** `C:\dev\projects\grandmind`

---

## 🎯 Current Status: Habits Feature FULLY IMPLEMENTED with AI-Powered Insights ✅

The app now has a **complete, production-ready habits tracking system** with AI-powered analysis and personalized insights!

**Latest Achievements:**
- ✅ Comprehensive habits tracking (create, edit, delete, archive)
- ✅ AI-powered habit insights and pattern analysis
- ✅ Real-time streak tracking and statistics
- ✅ Support for both simple and quantifiable habits
- ✅ All Firestore indexes created and optimized

---

## ✅ Completed Features (Detailed)

### 1. **Authentication System** ✅
- **Firebase Authentication** integration
  - Email/Password sign up and login
  - Google Sign-In support
  - Password reset functionality
  - User profile creation in Firestore on signup
- **Auth Screens:**
  - Splash Screen with loading and navigation logic
  - Login Screen
  - Signup Screen
  - Forgot Password Screen

### 2. **User Onboarding Flow** ✅
Complete 6-step onboarding process:
- Welcome Screen
- Goal Selection (5 options)
- Fitness Level Assessment
- Weekly Workout Frequency
- Physical Limitations
- **Coach Tone Selection** (Friendly, Strict, Clinical)

### 3. **Workouts Feature** ✅
- Complete workout system with library, details, and logging
- Category filtering (Strength, Cardio, HIIT, Yoga, etc.)
- Difficulty filtering (Beginner, Intermediate, Advanced)
- Exercise tracking with sets, reps, duration, weight
- Workout logging to Firestore

### 4. **Habits Tracking Feature** ✅ **NEW!**

#### Core Functionality:
- **Create Habits:**
  - Simple yes/no habits
  - Quantifiable habits with target counts and units
  - Custom icons (11 options: water, sleep, meditation, walk, read, exercise, food, pill, study, clean, other)
  - Custom colors (8 options)
  - Frequency selection (daily, weekly, custom)

- **Track Completion:**
  - One-tap completion for simple habits
  - Automatic target count logging for quantifiable habits
  - Real-time progress updates
  - Visual progress indicators

- **Streak Tracking:**
  - Current streak counter
  - Longest streak tracking
  - Automatic streak calculation
  - Streak recovery on re-completion

- **Manage Habits:**
  - Edit existing habits (long-press menu)
  - Delete habits with confirmation dialog
  - Archive/unarchive habits
  - All operations update Firestore in real-time

#### Statistics & Analytics:
- **Daily Progress Summary:**
  - Completion count (e.g., "1/2 Completed")
  - Completion percentage (e.g., "50%")
  - Best streak across all habits

- **Individual Habit Stats:**
  - Current streak display with fire icon
  - Progress bars for quantifiable habits
  - Completion status indicators
  - Last completed timestamp

#### Data Models:
- **Habit Model:**
  - Freezed immutable model
  - Support for frequency types
  - Target count and unit fields
  - Streak tracking fields
  - Active/archived status

- **HabitLog Model:**
  - Daily completion tracking
  - Count tracking for quantifiable habits
  - Timestamp fields
  - Optional notes

#### Technical Implementation:
- **Repository Pattern:**
  - Complete CRUD operations
  - Automatic streak calculation
  - Batch operations for deletion
  - Real-time streaming with Firestore

- **State Management:**
  - Riverpod providers for habits stream
  - Today's logs provider
  - Statistics provider
  - Operations state notifier

- **UI Components:**
  - Habits tab with progress summary
  - Create/Edit habit screen with form validation
  - Habit cards with icons and colors
  - Empty state with CTA
  - Loading and error states

- **Custom Utilities:**
  - Timestamp converters for Firestore
  - Habit icon helper with Material icons mapping
  - Color helper for habit colors

### 5. **AI-Powered Habit Insights** ✅ **NEW!**

#### AI Analysis Features:
- **Pattern Recognition:**
  - Completion patterns by day of week
  - Best and worst performing days
  - Streak analysis and trends
  - Average completion rates

- **Personalized Insights:**
  - Data-driven behavioral observations
  - Evidence-based suggestions
  - Compassionate, non-judgmental tone
  - Clinical relevance without medical advice

#### User Interface:
- **AI Insights Card (Habits Tab):**
  - Gradient design with AI icon
  - Summary of overall progress
  - Top 2 key insights displayed
  - "View Full Analysis" button
  - Refresh capability
  - Loading/error states with retry

- **Detailed Insights Screen:**
  - Full summary section
  - Complete list of key insights (3+)
  - Actionable suggestions (3 numbered items)
  - Statistics breakdown
  - Professional disclaimer
  - Mobile-optimized layout

#### Technical Implementation:
- **HabitInsightsService:**
  - Analyzes last 30 days of data
  - Calculates comprehensive statistics
  - Generates AI prompts with context
  - Uses Claude AI API for analysis
  - Fallback handling for API failures

- **AI Integration:**
  - Uses existing Claude AI infrastructure
  - Prompt engineering for behavioral insights
  - Response parsing (summary, insights, suggestions)
  - Caching for efficiency

- **Data Analysis:**
  - Completion by day of week
  - Average completion rates
  - Streak progression tracking
  - Best/worst day detection
  - Habit-specific patterns

#### AI Prompt Design:
- Behavioral psychology expertise
- Evidence-based recommendations
- Compassionate coaching tone
- Specific data references
- 15-word limit per insight for clarity

### 6. **Dashboard** ✅
- Real-time data from Firestore
- Daily summary cards
- Quick action buttons
- Personalized welcome messages
- Coach tone-aware messaging

---

## 🗂️ Complete Project Structure

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # Main app widget
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── route_constants.dart
│   │   └── firebase_constants.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   ├── helpers.dart
│   │   └── timestamp_converter.dart    # Firestore Timestamp converter
│   └── config/
│       └── ai_config.dart              # AI API configuration
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
│   ├── onboarding/
│   │   ├── domain/
│   │   │   └── onboarding_data.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── onboarding_provider.dart
│   │       └── screens/
│   │           ├── welcome_screen.dart
│   │           ├── goal_selection_screen.dart
│   │           ├── fitness_level_screen.dart
│   │           ├── time_availability_screen.dart
│   │           ├── limitations_screen.dart
│   │           └── coach_tone_screen.dart
│   ├── habits/                         # ✅ COMPLETE FEATURE
│   │   ├── domain/
│   │   │   └── models/
│   │   │       ├── habit.dart          # Habit model (Freezed)
│   │   │       ├── habit.freezed.dart
│   │   │       ├── habit.g.dart
│   │   │       ├── habit_log.dart      # Habit log model (Freezed)
│   │   │       ├── habit_log.freezed.dart
│   │   │       └── habit_log.g.dart
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── habit_repository.dart     # Complete CRUD + streak logic
│   │   │   └── services/
│   │   │       └── habit_insights_service.dart  # AI analysis service
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── habit_providers.dart      # Riverpod providers
│   │       ├── screens/
│   │       │   ├── create_habit_screen.dart  # Create/Edit form
│   │       │   └── habit_insights_screen.dart # Detailed AI insights
│   │       └── widgets/
│   │           ├── habit_icon_helper.dart    # Icon/color mapping
│   │           └── ai_insights_card.dart     # AI insights widget
│   ├── home/
│   │   ├── domain/
│   │   │   └── models/
│   │   │       └── dashboard_stats.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── dashboard_tab.dart
│   │       │   ├── workouts_tab.dart
│   │       │   ├── habits_tab.dart     # ✅ Habits UI with AI card
│   │       │   ├── progress_tab.dart
│   │       │   └── log_activity_screen.dart
│   │       └── widgets/
│   │           └── bottom_nav_bar.dart
│   ├── workouts/
│   │   ├── domain/
│   │   │   └── models/
│   │   │       ├── workout.dart
│   │   │       ├── exercise.dart
│   │   │       └── workout_log.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── workout_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── workout_providers.dart
│   │       └── screens/
│   │           ├── workout_detail_screen.dart
│   │           └── workout_logging_screen.dart
│   ├── ai/                             # ✅ AI Coach Infrastructure
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── ai_conversation_model.dart
│   │   │   │   ├── cache_entry.dart
│   │   │   │   └── user_context.dart
│   │   │   ├── repositories/
│   │   │   │   └── ai_cache_repository.dart
│   │   │   └── services/
│   │   │       ├── claude_api_service.dart
│   │   │       └── prompt_builder_service.dart
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── send_coach_message_usecase.dart
│   │   │       ├── get_workout_recommendation_usecase.dart
│   │   │       └── get_form_check_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── ai_coach_provider.dart
│   │       │   └── ai_providers.dart
│   │       ├── screens/
│   │       │   └── ai_coach_screen.dart
│   │       └── widgets/
│   │           ├── ai_message_bubble.dart
│   │           └── quick_action_chips.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/
│   │           └── profile_screen.dart
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart
│   └── user/
│       └── data/
│           ├── models/
│           │   └── user_model.dart
│           └── services/
│               └── firestore_service.dart
└── routes/
    └── app_router.dart                 # GoRouter configuration
```

---

## 🔥 Firebase Configuration

### Firestore Collections:

#### **users/** ✅
```javascript
{
  userId: string,
  email: string,
  displayName: string?,
  photoUrl: string?,
  createdAt: timestamp,
  updatedAt: timestamp,
  onboarding: {
    completed: boolean,
    goalType: string,
    fitnessLevel: string,
    weeklyWorkouts: number,
    coachTone: string,
    limitations: string[]
  }
}
```

#### **habits/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  userId: string,
  name: string,
  description: string,
  frequency: 'daily' | 'weekly' | 'custom',
  icon: 'water' | 'sleep' | 'meditation' | ...,
  color: 'blue' | 'purple' | 'pink' | ...,
  createdAt: timestamp,
  isActive: boolean,
  targetCount: number,
  unit: string?,
  daysOfWeek: number[],
  lastCompletedAt: timestamp?,
  currentStreak: number,
  longestStreak: number
}
```

#### **habit_logs/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  habitId: string,
  userId: string,
  date: timestamp,
  completedAt: timestamp,
  count: number,
  notes: string?
}
```

#### **workouts/** ✅
```javascript
{
  id: string,
  name: string,
  description: string,
  category: string,
  difficulty: string,
  duration: number,
  exercises: Exercise[]
}
```

### Firestore Indexes (All Created) ✅

```json
{
  "indexes": [
    {
      "collectionGroup": "habits",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "habit_logs",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "habit_logs",
      "fields": [
        { "fieldPath": "habitId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "habit_logs",
      "fields": [
        { "fieldPath": "habitId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### Security Rules:
- ✅ Users can only read/write their own data
- ✅ All collections are user-scoped
- ✅ Validation rules for required fields
- ✅ Deployed to Firebase Console

---

## 🔧 Tech Stack

- **Framework:** Flutter 3.38.5
- **Language:** Dart
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firestore Security Rules
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Data Models:** Freezed + JSON Serialization
- **Architecture:** Clean Architecture (feature-based)
- **AI Integration:** Claude AI API (Anthropic)
  - AI Coach for conversations
  - AI Insights for habit analysis
  - Prompt engineering for behavioral coaching

---

## 📋 Remaining Features (From Original Plan)

### Phase 1: Core Features (Remaining)

#### **Progress Tracking** 🔴 NOT STARTED
- [ ] Weight logging with graphs
- [ ] Body measurements tracking
- [ ] Progress photos
- [ ] Charts and analytics (fl_chart)
- [ ] Goal progress visualization
- [ ] Weekly/monthly summaries

#### **Nutrition Tracking** 🔴 NOT STARTED
- [ ] Meal logging
- [ ] Calorie tracking
- [ ] Macro tracking (protein, carbs, fats)
- [ ] Water intake (can integrate with habits)
- [ ] Meal photo uploads
- [ ] Nutrition goals

### Phase 2: Health Integrations

#### **HealthKit / Google Fit Integration** 🔴 NOT STARTED
- [ ] Read steps data
- [ ] Read sleep data
- [ ] Read heart rate
- [ ] Read workouts
- [ ] Write completed workouts back
- [ ] Sync with dashboard

#### **Wearable Integration** 🔴 NOT STARTED
- [ ] Apple Watch
- [ ] Garmin
- [ ] Fitbit
- [ ] Oura Ring

### Phase 3: Advanced AI Features

#### **Expand AI Coach** 🟡 PARTIALLY DONE
- [x] Habit insights and analysis ✅
- [ ] Workout recommendations based on goals
- [ ] Form check with video analysis
- [ ] Recovery advisor (HRV + sleep)
- [ ] Meal recommendations
- [ ] Weekly coaching reports

#### **Predictive Features** 🔴 NOT STARTED
- [ ] Habit failure prediction
- [ ] Optimal workout timing suggestions
- [ ] Plateau detection and recommendations
- [ ] Injury risk assessment

### Phase 4: Social & Engagement

#### **Community Features** 🔴 NOT STARTED
- [ ] User profiles (public/private)
- [ ] Follow/friends system
- [ ] Activity feed
- [ ] Challenges and competitions
- [ ] Leaderboards
- [ ] Group workouts

#### **Gamification** 🔴 NOT STARTED
- [ ] Achievement badges
- [ ] Levels and XP system
- [ ] Streaks and milestones
- [ ] Rewards system
- [ ] Daily/weekly challenges

### Phase 5: Notifications & Engagement

#### **Push Notifications** 🔴 NOT STARTED
- [ ] Firebase Cloud Messaging setup
- [ ] Workout reminders
- [ ] Habit check-in prompts
- [ ] Motivational messages (tone-aware)
- [ ] Achievement notifications
- [ ] Inactivity nudges (compassionate)

#### **Smart Scheduling** 🔴 NOT STARTED
- [ ] AI-powered optimal reminder times
- [ ] Adaptive scheduling based on completion patterns
- [ ] Calendar integration

### Phase 6: Premium Features

#### **Subscription System** 🔴 NOT STARTED
- [ ] RevenueCat integration
- [ ] Free tier limits
- [ ] Premium tier features
- [ ] Subscription management
- [ ] Payment flow

#### **Premium Features** 🔴 NOT STARTED
- [ ] Unlimited habits
- [ ] Advanced analytics
- [ ] Coaching marketplace
- [ ] Video workouts
- [ ] Meal plans
- [ ] Personal trainer matching

### Phase 7: Platform Expansion

#### **iOS App** 🔴 NOT STARTED
- [ ] iOS-specific adaptations
- [ ] Apple Sign-In
- [ ] HealthKit integration
- [ ] Apple Watch app
- [ ] App Store submission

#### **Web App** 🔴 NOT STARTED
- [ ] Web-responsive design
- [ ] Firebase hosting
- [ ] Progressive Web App (PWA)
- [ ] Desktop experience optimization

---

## 🎯 Recommended Next Steps (Priority Order)

### Immediate (Next 1-2 Sessions):

1. **Progress Tracking** 📊
   - Weight logging with line charts
   - Body measurements
   - Progress photos upload
   - Goal tracking visualization
   - **Why:** Completes the core tracking trifecta (workouts, habits, progress)

2. **HealthKit/Google Fit Integration** 📱
   - Read steps, sleep, heart rate
   - Display on dashboard
   - Auto-sync daily
   - **Why:** Provides holistic health view, user value++

3. **Notifications System** 🔔
   - FCM setup
   - Workout reminders
   - Habit check-ins
   - **Why:** Critical for engagement and retention

### Short-term (Next 3-5 Sessions):

4. **Expand AI Coach**
   - Workout recommendations
   - Recovery advisor
   - Weekly reports
   - **Why:** Leverage existing AI infrastructure

5. **Nutrition Tracking**
   - Basic meal logging
   - Calorie tracking
   - Water intake
   - **Why:** Common user request, completes wellness picture

6. **Enhanced Analytics**
   - Charts for all metrics
   - Trend analysis
   - Correlations (habits vs progress)
   - **Why:** Users love seeing progress visualized

### Medium-term (Next 6-10 Sessions):

7. **Social Features (MVP)**
   - User profiles
   - Activity sharing
   - Simple challenges
   - **Why:** Increases engagement, viral potential

8. **Premium Tier**
   - Subscription setup
   - Paywall implementation
   - Premium-only features
   - **Why:** Monetization for sustainability

9. **iOS Launch**
   - Platform-specific features
   - App Store submission
   - **Why:** Expand user base

---

## 🔑 Important Files & Locations

### Configuration:
- **Firebase:** `android/app/google-services.json` (gitignored)
- **Firebase Options:** `lib/firebase_options.dart` (gitignored)
- **Firestore Rules:** `firestore.rules`
- **Firestore Indexes:** `firestore.indexes.json`
- **Firebase Config:** `firebase.json`
- **Git Ignore:** `.gitignore` (updated for security)

### Key Implementation:
- **Auth:** `lib/features/authentication/data/repositories/auth_repository.dart`
- **Habits Repo:** `lib/features/habits/data/repositories/habit_repository.dart`
- **AI Insights:** `lib/features/habits/data/services/habit_insights_service.dart`
- **Claude API:** `lib/features/ai/data/services/claude_api_service.dart`
- **Router:** `lib/routes/app_router.dart`
- **Timestamp Converter:** `lib/core/utils/timestamp_converter.dart`

---

## 🚀 How to Resume Work

### 1. **Open Project:**
```bash
cd C:\dev\projects\grandmind
code .  # VS Code
# OR
start . # Open in file explorer, then open in Android Studio
```

### 2. **Start Emulator:**
- Open Android Studio → AVD Manager
- Launch emulator (API 33/34)
- OR use command: `emulator -avd Medium_Phone_API_36.1`

### 3. **Run App:**
```bash
flutter run -d emulator-5554
```

### 4. **Test Habits Feature:**
- Navigate to Habits tab
- Create a new habit
- Complete it (tap checkmark)
- View AI Insights
- Long-press habit for edit/delete menu

### 5. **Firebase Console:**
- URL: https://console.firebase.google.com/
- Project: grandmind-kinesa
- Check Firestore for data
- Monitor indexes status

---

## 💾 Git Workflow

### Check Status:
```bash
git status
```

### Commit Changes:
```bash
git add .
git commit -m "feat: your feature description"
```

### Push to GitHub:
```bash
git push origin main
```

### Pull Latest:
```bash
git pull origin main
```

### View Commit History:
```bash
git log --oneline --graph --decorate --all
```

---

## 🐛 Common Issues & Solutions

### Issue: Firestore Index Missing
**Error:** "The query requires an index"
**Solution:** Click the link in error, create index in Firebase Console

### Issue: Timestamp Conversion Error
**Error:** "type 'Timestamp' is not a subtype of type 'String'"
**Solution:** Already fixed with `timestamp_converter.dart`

### Issue: AI Insights Not Loading
**Possible Causes:**
1. No Claude API key in secure storage
2. No habit data (need at least 1 habit)
3. Firestore index not created
4. API rate limit reached

**Solution:** Check logs, verify API key, ensure indexes exist

### Issue: Build Fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Hot Reload Not Working
**Solution:**
- Press 'R' in terminal for full restart
- OR restart app: `Ctrl+C` then `flutter run`

---

## 📊 Project Metrics

### Features Completed: **6/15** (40%)
- ✅ Authentication
- ✅ Onboarding
- ✅ Dashboard
- ✅ Workouts
- ✅ Habits (with AI insights)
- ✅ Basic AI Coach

### Code Stats:
- **Total Files:** ~150+
- **Lines of Code:** ~15,000+
- **Features Folders:** 8
- **Models (Freezed):** 10+
- **Repositories:** 4
- **Providers:** 15+
- **Screens:** 25+

### Firestore Collections: **4**
- users
- habits
- habit_logs
- workouts

### Git Commits: **3 major commits this session**
1. Habits feature implementation
2. AI insights integration
3. Delete/Edit features

---

## 📞 Session Notes

### What Worked Well This Session:
✅ Systematic approach to fixing Firestore query errors
✅ Custom Timestamp converter solved date handling
✅ AI insights feature provides real user value
✅ Clean separation of concerns (service, provider, UI)
✅ Comprehensive testing before committing
✅ Proper Git hygiene with .gitignore updates

### Challenges Overcome:
- Firestore query order (WHERE before ORDER BY)
- Timestamp vs String type mismatches
- Multiple missing Firestore indexes
- AI service integration with existing infrastructure
- Import path corrections for Claude API service

### Key Learnings:
- Firestore composite indexes are critical for complex queries
- Always test queries with actual data before deploying
- AI insights add significant value with minimal code
- Users love seeing patterns in their data
- Compassionate tone in AI coaching is important

---

## 🎨 App Design Language

### Color Palette:
```dart
Primary: Color(0xFF6366F1)      // Indigo
Secondary: Color(0xFF8B5CF6)    // Purple
Accent: Color(0xFFEC4899)       // Pink
Background: Color(0xFFF9FAFB)   // Light gray
Success: Colors.green
Warning: Colors.orange
Error: Colors.red
```

### Typography:
- Headlines: Bold, 24-28px
- Body: Regular, 16px
- Captions: 12-14px
- Buttons: Medium, 16px

### Spacing:
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

---

## 📖 Documentation

### For Developers:
- **Architecture:** Clean Architecture with feature-based modules
- **State Management:** Riverpod (Provider-based)
- **Naming Convention:** snake_case for files, camelCase for variables
- **Comments:** JSDoc-style for public APIs
- **Testing:** Manual testing on emulator (unit tests TODO)

### For Future Contributors:
1. Read this document first
2. Check `CLAUDE.md` for detailed project vision
3. Follow existing patterns in codebase
4. Test on emulator before committing
5. Update this document with changes

---

## 🎯 Success Metrics (When Launched)

### Engagement:
- DAU/MAU ratio > 40%
- Average session > 5 minutes
- Habits completion rate > 60%

### Retention:
- Day 1: > 60%
- Day 7: > 40%
- Day 30: > 25%

### Monetization:
- Free → Premium: > 5%
- Monthly churn: < 8%
- Target: £5-10k MRR in Year 1

---

## 🔮 Vision Statement

**Kinesa is a holistic fitness companion that adapts to your life and keeps you motivated — combining whole-life tracking, behavioral science, and an optional human touch to deliver a supportive coaching experience.**

**Core Philosophy:** "No guilt. No overwhelm. Just progress."

---

**Happy Coding! 🚀**

*Last session date: 2026-01-05*
*Session focus: Habits Feature + AI-Powered Insights*
*Next recommended feature: Progress Tracking or HealthKit Integration*

---

## Quick Reference Commands

```bash
# Start project
cd C:\dev\projects\grandmind && flutter run -d emulator-5554

# Check Firestore indexes
cat firestore.indexes.json

# View git history
git log --oneline

# Clean build
flutter clean && flutter pub get && flutter run
```

**🎉 You're all set to continue building Kinesa/Grandmind!**
