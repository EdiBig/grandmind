# Grandmind (Kinesa) - Project Status

**Last Updated:** 2026-01-08 (Nutrition Features - AI Insights, Barcode Scanner, Photos)
**GitHub Repository:** https://github.com/EdiBig/grandmind
**Project Location:** `C:\dev\projects\grandmind`

---

## 🎯 Current Status: NUTRITION MODULE FULLY IMPLEMENTED ✅

The app now has a **complete, production-ready nutrition tracking system** with AI-powered insights, barcode scanning, and photo capabilities!

**Latest Achievements (2026-01-08):**
- ✅ Complete AI Insights screen with 4 comprehensive tabs
- ✅ Nutrition trend analysis (calories, macros over time)
- ✅ Personalized AI-powered tips and recommendations
- ✅ Goal progress tracking with predictions
- ✅ Cross-domain insights (nutrition + sleep/mood/workouts)
- ✅ Barcode scanner with OpenFoodFacts API integration
- ✅ Camera & photo gallery integration for meal photos
- ✅ Firebase Storage integration for photo uploads
- ✅ Meal photo capture, edit, and delete functionality

**Previous Major Achievements:**
- ✅ Complete notifications system with local notifications and reminders
- ✅ Comprehensive habits tracking with AI-powered insights
- ✅ Real-time streak tracking and statistics
- ✅ Progress tracking with weight, measurements, and photos
- ✅ Health data integration (HealthKit/Health Connect)
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
- Integration with health data

### 4. **Habits Tracking Feature** ✅

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

#### AI-Powered Habit Insights:
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

- **User Interface:**
  - AI Insights Card on Habits Tab
  - Detailed Insights Screen with full analysis
  - Key insights and actionable suggestions
  - Statistics breakdown

### 5. **Nutrition Tracking Feature** ✅ **COMPLETE!**

#### Core Functionality:

##### Meal Logging:
- **Quick Meal Logging:**
  - Create meals with multiple food items
  - Select meal type (breakfast, lunch, dinner, snacks)
  - Add food items with custom servings
  - Date selection for backlog meals
  - Optional notes for context
  - Photo attachments for visual tracking

- **Food Database:**
  - Search foods from database
  - Create custom foods
  - Food categorization (protein, grains, vegetables, fruits, dairy, fats, snacks, beverages, other)
  - Nutritional information (calories, protein, carbs, fat, fiber, sugar)
  - Serving size customization

- **Barcode Scanner:** ✅ **NEW!**
  - Real-time barcode scanning with camera
  - Automatic product lookup via OpenFoodFacts API
  - Instant nutrition information
  - Product details preview before adding
  - Flashlight and camera flip controls
  - Visual scanning overlay with corner brackets
  - Automatic food item creation from scanned products

- **Meal Photos:** ✅ **NEW!**
  - Take photos directly from camera
  - Choose photos from gallery
  - Photo preview and editing
  - Firebase Storage integration
  - Photo upload progress indicator
  - Delete and replace photos
  - Photos displayed in meal cards

##### Water Intake Tracking:
- **Daily Water Goals:**
  - Visual glass counter (default 8 glasses)
  - Progress bar with percentage
  - Quick-add water button
  - Goal achievement celebration
  - Real-time updates

##### Nutrition Goals:
- **Goal Setting:**
  - Daily calorie targets
  - Macronutrient goals (protein, carbs, fat)
  - Custom goal creation
  - Goal editing and updates

- **Progress Tracking:**
  - Real-time goal progress
  - Visual progress bars for each macro
  - Today's nutrition summary
  - Goal achievement status

##### Meal History:
- **Timeline View:**
  - Daily meal logs
  - Meal details with nutritional breakdown
  - Photo display in history
  - Edit and delete functionality
  - Date range filtering
  - Weekly/monthly summaries

#### AI-Powered Nutrition Insights ✅ **NEW!**

##### Insights Dashboard (4 Tabs):

**1. Trends Tab:**
- **Calories Trend:**
  - Line chart showing daily calories over time (7/14/30/90 days)
  - Average vs target calories comparison
  - Visual trend identification
  - Goal line overlay

- **Macros Breakdown:**
  - Average daily protein, carbs, fat
  - Visual macro circles with values
  - Macro distribution analysis

- **Water Trend:**
  - Water intake patterns over time
  - Hydration goal achievement tracking

- **Meal Timing Patterns:**
  - Meal type distribution (breakfast, lunch, dinner, snacks)
  - Frequency analysis by meal type
  - Visual progress bars

**2. AI Tips Tab:**
- **Personalized Tips:**
  - AI-generated insights based on eating patterns
  - Behavioral observations
  - Evidence-based recommendations
  - Compassionate, actionable advice

- **Nutrition Recommendations:**
  - Specific food suggestions
  - Timing optimization
  - Portion guidance

- **Habit Suggestions:**
  - Meal prep ideas
  - Eating strategy recommendations
  - Sustainable habit formation tips

**3. Goals Tab:**
- **Today's Progress:**
  - Real-time goal tracking
  - Visual progress bars
  - Percentage completion
  - Current vs target metrics

- **Goal Predictions:**
  - AI-powered goal achievement predictions
  - Timeline estimates
  - Trend-based forecasting

- **Goal Streaks:**
  - Days meeting goals consecutively
  - Streak counter with fire icon
  - Motivational messaging

**4. Correlations Tab:**
- **Cross-Domain Insights:**
  - Nutrition & Sleep correlation
  - Nutrition & Workout performance
  - Nutrition & Mood patterns
  - Hydration & Energy levels
  - Data-driven observations
  - Personalized insights

#### Data Models:
- **FoodItem Model:**
  - Freezed immutable model
  - Nutritional information fields
  - Serving size and units
  - Brand and barcode support
  - Category classification
  - Custom vs verified foods

- **Meal Model:**
  - Meal type and date
  - Multiple food entries
  - Automatic nutrition calculation
  - Photo URL storage
  - Optional notes

- **WaterLog Model:**
  - Daily water tracking
  - Glass count and targets
  - Progress percentage
  - Goal achievement status

- **NutritionGoal Model:**
  - Daily calorie targets
  - Macro targets (protein, carbs, fat)
  - Goal creation date

- **DailyNutritionSummary Model:**
  - Total calories, protein, carbs, fat
  - Progress against goals
  - Summary statistics

#### Technical Implementation:
- **Repository Pattern:**
  - Complete CRUD operations
  - Real-time streaming with Firestore
  - Date-range queries
  - Aggregation functions

- **Services:**
  - OpenFoodFactsService: Product lookup API integration
  - NutritionPhotoService: Photo capture and upload
  - Firebase Storage integration

- **State Management:**
  - Riverpod providers for meals, goals, water logs
  - DateRange parameterized providers
  - Operations state notifier
  - Real-time updates

- **UI Components:**
  - NutritionTab with dashboard
  - LogMealScreen with photo capture
  - FoodSearchScreen with barcode scanner button
  - BarcodeScannerScreen with camera controls
  - NutritionInsightsScreen with 4 tabs
  - MealDetailsScreen with photo display
  - NutritionGoalsScreen
  - NutritionHistoryScreen

- **Permissions:**
  - Android: CAMERA permission
  - iOS: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
  - Camera and photo library access

### 6. **Progress Tracking Feature** ✅

#### Core Functionality:
- **Weight Tracking:**
  - Log weight entries with date
  - Line chart visualization (fl_chart)
  - Goal weight setting
  - Progress towards goal
  - Trend analysis

- **Body Measurements:**
  - Track multiple measurements (chest, waist, hips, arms, legs)
  - Historical tracking
  - Visual progress charts
  - Measurement history

- **Progress Photos:**
  - Upload progress photos
  - Front, side, back views
  - Date-based organization
  - Before/after comparisons
  - Firebase Storage integration

- **Goals Management:**
  - Create weight goals
  - Set target dates
  - Track goal progress
  - Goal achievement celebrations

#### Analytics:
- **Progress Dashboard:**
  - Weight trend chart
  - Measurement changes
  - Photo timeline
  - Goal progress overview

- **Insights:**
  - AI-powered progress insights
  - Correlation with habits
  - Trend identification
  - Recommendations

### 7. **Health Data Integration** ✅

#### HealthKit (iOS) & Health Connect (Android):
- **Data Reading:**
  - Steps count
  - Sleep duration
  - Heart rate
  - Workouts
  - Active energy burned
  - Distance traveled

- **Data Writing:**
  - Log workouts to Health app
  - Sync completed exercises
  - Nutrition data export (planned)

- **Dashboard Integration:**
  - Today's step count
  - Sleep hours display
  - Heart rate data
  - Activity summary

- **Permissions:**
  - HealthKit usage descriptions (iOS)
  - Health Connect permissions (Android)
  - User-controlled data access

### 8. **AI Coach System** ✅

#### Core Features:
- **Conversational AI:**
  - Claude AI API integration
  - Natural language conversations
  - Context-aware responses
  - Coach tone adaptation (Friendly, Strict, Clinical)

- **Use Cases:**
  - General fitness questions
  - Workout recommendations
  - Nutrition advice
  - Habit formation support
  - Motivation and encouragement

#### Technical Implementation:
- **Services:**
  - ClaudeAPIService: API communication
  - PromptBuilderService: Context building
  - AI Cache Repository: Response caching

- **Data Models:**
  - AIConversationModel: Chat history
  - UserContext: Personalized context
  - CacheEntry: Response caching

- **UI Components:**
  - AICoachScreen: Chat interface
  - Message bubbles
  - Quick action chips
  - Typing indicators

### 9. **Notifications System** ✅

#### Core Functionality:
- **Reminder Types:**
  - Workout reminders (customizable days and times)
  - Habit check-in reminders
  - Hydration (water) reminders
  - Meal reminders (breakfast, lunch, dinner)
  - Sleep reminders
  - Meditation reminders
  - Custom reminders

- **Reminder Management:**
  - Create custom reminders with title, message, time
  - Edit existing reminders
  - Enable/disable reminders with toggle
  - Delete reminders with confirmation
  - Schedule for specific days of the week
  - Set exact time for notifications

- **Quick Actions:**
  - One-tap creation of default reminders
  - Test notification functionality
  - Quick access to common reminder types

#### Technical Implementation:
- **Services:**
  - NotificationService: Local notifications with flutter_local_notifications
  - NotificationSchedulerService: Advanced scheduling with FCM integration
  - ReminderScheduler: Reminder scheduling logic with timezone support

- **Data Models:**
  - NotificationPreference: User notification settings (Freezed)
  - NotificationHistory: Notification tracking
  - NotificationSchedule: Scheduled notification metadata
  - NotificationType: Enum for notification categories

- **Repository:**
  - Complete CRUD operations for notification preferences
  - Notification history tracking
  - Real-time streaming of preferences
  - Firestore integration with user-scoped collections

- **Permissions:**
  - Android: POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM
  - Automatic permission request flow
  - Graceful permission handling

### 10. **Dashboard** ✅
- Real-time data from Firestore
- Daily summary cards
- Quick action buttons
- Personalized welcome messages
- Coach tone-aware messaging
- Integration with all tracking features
- Statistics overview

### 11. **Profile & Settings** ✅
- **Profile Management:**
  - Edit profile information
  - Photo upload
  - Display name, bio
  - User preferences

- **Settings:**
  - Notification preferences
  - Health sync settings
  - Data management
  - Privacy settings
  - About and help sections
  - API key setup for AI features

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
│   │   ├── data/repositories/
│   │   │   └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           └── forgot_password_screen.dart
│   ├── onboarding/
│   │   ├── domain/onboarding_data.dart
│   │   └── presentation/
│   │       ├── providers/onboarding_provider.dart
│   │       └── screens/
│   │           ├── welcome_screen.dart
│   │           ├── goal_selection_screen.dart
│   │           ├── fitness_level_screen.dart
│   │           ├── time_availability_screen.dart
│   │           ├── limitations_screen.dart
│   │           └── coach_tone_screen.dart
│   ├── habits/                         # ✅ COMPLETE FEATURE
│   │   ├── domain/models/
│   │   │   ├── habit.dart              # Habit model (Freezed)
│   │   │   ├── habit_log.dart          # Habit log model (Freezed)
│   │   │   └── *.freezed.dart, *.g.dart
│   │   ├── data/
│   │   │   ├── repositories/habit_repository.dart
│   │   │   └── services/habit_insights_service.dart
│   │   └── presentation/
│   │       ├── providers/habit_providers.dart
│   │       ├── screens/
│   │       │   ├── create_habit_screen.dart
│   │       │   └── habit_insights_screen.dart
│   │       └── widgets/
│   │           ├── habit_icon_helper.dart
│   │           └── ai_insights_card.dart
│   ├── nutrition/                      # ✅ COMPLETE FEATURE (NEW!)
│   │   ├── domain/models/
│   │   │   ├── food_item.dart          # Food item model (Freezed)
│   │   │   ├── meal.dart               # Meal model (Freezed)
│   │   │   ├── water_log.dart          # Water log model (Freezed)
│   │   │   ├── nutrition_goal.dart     # Nutrition goal model (Freezed)
│   │   │   ├── daily_nutrition_summary.dart
│   │   │   └── *.freezed.dart, *.g.dart
│   │   ├── data/
│   │   │   ├── repositories/nutrition_repository.dart
│   │   │   └── services/
│   │   │       ├── openfoodfacts_service.dart      # Barcode API
│   │   │       └── nutrition_photo_service.dart    # Photo handling
│   │   └── presentation/
│   │       ├── providers/nutrition_providers.dart
│   │       └── screens/
│   │           ├── nutrition_tab.dart              # Main dashboard
│   │           ├── log_meal_screen.dart            # Meal logging
│   │           ├── food_search_screen.dart         # Food search
│   │           ├── barcode_scanner_screen.dart     # ✅ Barcode scanner
│   │           ├── nutrition_insights_screen.dart  # ✅ AI insights
│   │           ├── create_custom_food_screen.dart
│   │           ├── meal_details_screen.dart
│   │           ├── nutrition_goals_screen.dart
│   │           └── nutrition_history_screen.dart
│   ├── progress/                       # ✅ COMPLETE FEATURE
│   │   ├── domain/models/
│   │   │   ├── weight_entry.dart       # Weight tracking (Freezed)
│   │   │   ├── measurement_entry.dart  # Body measurements (Freezed)
│   │   │   ├── progress_photo.dart     # Progress photos (Freezed)
│   │   │   ├── progress_goal.dart      # Goals (Freezed)
│   │   │   └── *.freezed.dart, *.g.dart
│   │   ├── data/
│   │   │   ├── repositories/progress_repository.dart
│   │   │   └── services/
│   │   │       ├── image_upload_service.dart
│   │   │       └── progress_correlation_service.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── progress_providers.dart
│   │       │   └── progress_insights_provider.dart
│   │       └── screens/
│   │           ├── progress_dashboard_screen.dart
│   │           ├── progress_insights_screen.dart
│   │           ├── goals_screen.dart
│   │           ├── create_goal_screen.dart
│   │           ├── measurements_screen.dart
│   │           └── weight_screen.dart
│   ├── health/                         # ✅ COMPLETE FEATURE
│   │   ├── data/
│   │   │   ├── repositories/health_repository.dart
│   │   │   └── services/health_service.dart
│   │   └── presentation/
│   │       ├── providers/health_providers.dart
│   │       └── screens/
│   │           ├── health_details_screen.dart
│   │           └── health_sync_screen.dart
│   ├── workouts/                       # ✅ COMPLETE FEATURE
│   │   ├── domain/models/
│   │   │   ├── workout.dart
│   │   │   ├── exercise.dart
│   │   │   └── workout_log.dart
│   │   ├── data/repositories/workout_repository.dart
│   │   └── presentation/
│   │       ├── providers/workout_providers.dart
│   │       └── screens/
│   │           ├── workout_detail_screen.dart
│   │           └── workout_logging_screen.dart
│   ├── ai/                             # ✅ AI Coach Infrastructure
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── ai_conversation_model.dart
│   │   │   │   ├── cache_entry.dart
│   │   │   │   └── user_context.dart
│   │   │   ├── repositories/ai_cache_repository.dart
│   │   │   └── services/
│   │   │       ├── claude_api_service.dart
│   │   │       └── prompt_builder_service.dart
│   │   ├── domain/usecases/
│   │   │   ├── send_coach_message_usecase.dart
│   │   │   ├── get_workout_recommendation_usecase.dart
│   │   │   └── get_form_check_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── ai_coach_provider.dart
│   │       │   └── ai_providers.dart
│   │       ├── screens/ai_coach_screen.dart
│   │       └── widgets/
│   │           ├── ai_message_bubble.dart
│   │           └── quick_action_chips.dart
│   ├── notifications/                  # ✅ COMPLETE FEATURE
│   │   ├── domain/models/
│   │   │   ├── notification_preference.dart
│   │   │   ├── notification_schedule.dart
│   │   │   ├── notification_type.dart
│   │   │   └── *.freezed.dart, *.g.dart
│   │   ├── data/
│   │   │   ├── repositories/notification_repository.dart
│   │   │   └── services/
│   │   │       ├── notification_service.dart
│   │   │       ├── notification_scheduler_service.dart
│   │   │       └── reminder_scheduler.dart
│   │   └── presentation/
│   │       ├── providers/notification_providers.dart
│   │       └── screens/
│   │           ├── notification_settings_screen.dart
│   │           └── create_reminder_screen.dart
│   ├── home/
│   │   ├── domain/models/dashboard_stats.dart
│   │   └── presentation/
│   │       ├── providers/dashboard_provider.dart
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── dashboard_tab.dart
│   │       │   ├── workouts_tab.dart
│   │       │   ├── habits_tab.dart
│   │       │   ├── progress_tab.dart
│   │       │   └── log_activity_screen.dart
│   │       └── widgets/bottom_nav_bar.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── profile_screen.dart
│   │           └── edit_profile_enhanced_screen.dart
│   ├── settings/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── settings_screen.dart
│   │           ├── api_key_setup_screen.dart
│   │           ├── data_management_screen.dart
│   │           ├── privacy_screen.dart
│   │           ├── help_center_screen.dart
│   │           ├── about_screen.dart
│   │           ├── terms_screen.dart
│   │           └── privacy_policy_screen.dart
│   └── user/
│       └── data/
│           ├── models/user_model.dart
│           └── services/firestore_service.dart
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

#### **habits/** ✅
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

#### **habit_logs/** ✅
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

#### **nutrition/food_items/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  userId: string,
  name: string,
  calories: number,
  proteinGrams: number,
  carbsGrams: number,
  fatGrams: number,
  fiberGrams: number,
  sugarGrams: number,
  servingSizeGrams: number,
  servingSizeUnit: string?,
  brand: string?,
  barcode: string?,              // ✅ For barcode scanning
  isCustom: boolean,
  isVerified: boolean,
  category: FoodCategory?,
  createdAt: timestamp
}
```

#### **nutrition/meals/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  userId: string,
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack',
  mealDate: timestamp,
  loggedAt: timestamp,
  entries: [
    {
      foodItem: FoodItem,
      servings: number
    }
  ],
  notes: string?,
  photoUrl: string?,             // ✅ Firebase Storage URL
  totalCalories: number,
  totalProtein: number,
  totalCarbs: number,
  totalFat: number,
  totalFiber: number,
  totalSugar: number
}
```

#### **nutrition/water_logs/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  userId: string,
  date: timestamp,
  glassesConsumed: number,
  targetGlasses: number,
  progressPercentage: number,
  goalAchieved: boolean,
  updatedAt: timestamp
}
```

#### **nutrition/nutrition_goals/** ✅ NEW
```javascript
{
  id: string (auto-generated),
  userId: string,
  dailyCalories: number,
  dailyProteinGrams: number,
  dailyCarbsGrams: number,
  dailyFatGrams: number,
  goalType: string,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### **progress/weight_entries/** ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  weight: number,
  unit: 'kg' | 'lbs',
  date: timestamp,
  notes: string?,
  createdAt: timestamp
}
```

#### **progress/measurements/** ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  date: timestamp,
  chest: number?,
  waist: number?,
  hips: number?,
  leftArm: number?,
  rightArm: number?,
  leftThigh: number?,
  rightThigh: number?,
  unit: 'cm' | 'inches',
  notes: string?,
  createdAt: timestamp
}
```

#### **progress/progress_photos/** ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  photoUrl: string,              # Firebase Storage URL
  thumbnailUrl: string?,
  photoType: 'front' | 'side' | 'back',
  date: timestamp,
  weight: number?,
  notes: string?,
  createdAt: timestamp
}
```

#### **progress/goals/** ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  goalType: 'weight' | 'measurement',
  targetValue: number,
  currentValue: number,
  unit: string,
  targetDate: timestamp?,
  createdAt: timestamp,
  achievedAt: timestamp?,
  isActive: boolean
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

#### **notification_preferences/** (subcollection of users) ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  type: 'workout' | 'habit' | 'water' | 'meal' | 'sleep' | 'meditation' | 'custom',
  enabled: boolean,
  title: string,
  message: string,
  daysOfWeek: number[], // 1=Monday, 7=Sunday
  hour: number, // 0-23
  minute: number, // 0-59
  linkedEntityId: string?, // habitId, goalId, etc.
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### **notification_history/** (subcollection of users) ✅
```javascript
{
  id: string (auto-generated),
  userId: string,
  preferenceId: string,
  type: 'workout' | 'habit' | 'water' | 'meal' | 'sleep' | 'meditation' | 'custom',
  title: string,
  message: string,
  sentAt: timestamp,
  readAt: timestamp?,
  actionedAt: timestamp?,
  action: string? // 'opened', 'dismissed', 'completed'
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
      "collectionGroup": "meals",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "mealDate", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "weight_entries",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
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
  - Firebase Storage (for photos)
  - Firestore Security Rules
  - Firebase Cloud Messaging (FCM)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Data Models:** Freezed + JSON Serialization
- **Architecture:** Clean Architecture (feature-based)
- **AI Integration:** Claude AI API (Anthropic)
  - AI Coach for conversations
  - AI Insights for habit analysis
  - AI-powered nutrition insights
  - Prompt engineering for behavioral coaching
- **Charts:** fl_chart
- **Barcode Scanning:** mobile_scanner
- **Image Handling:** image_picker, Firebase Storage
- **Health Data:** health package (HealthKit/Health Connect)
- **Notifications:** flutter_local_notifications, timezone

---

## 📋 Remaining Features (From Original Plan)

### Phase 2: Enhanced Features

#### **Advanced AI Features** 🟡 PARTIALLY DONE
- [x] Habit insights and analysis ✅
- [x] Nutrition insights and analysis ✅
- [ ] Workout recommendations based on goals
- [ ] Form check with video analysis
- [ ] Recovery advisor (HRV + sleep)
- [ ] Weekly coaching reports
- [ ] Meal recommendations with AI

#### **Wearable Integration** 🔴 NOT STARTED
- [ ] Apple Watch
- [ ] Garmin
- [ ] Fitbit
- [ ] Oura Ring

#### **Predictive Features** 🔴 NOT STARTED
- [ ] Habit failure prediction
- [ ] Optimal workout timing suggestions
- [ ] Plateau detection and recommendations
- [ ] Injury risk assessment

### Phase 3: Social & Engagement

#### **Community Features** 🔴 NOT STARTED
- [ ] User profiles (public/private)
- [ ] Follow/friends system
- [ ] Activity feed
- [ ] Challenges and competitions
- [ ] Leaderboards
- [ ] Group workouts

#### **Gamification** 🔴 NOT STARTED
- [ ] Achievement badges (basic streaks exist)
- [ ] Levels and XP system
- [ ] Enhanced rewards system
- [ ] Daily/weekly challenges

### Phase 4: Premium Features

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

### Phase 5: Platform Expansion

#### **iOS App** 🟡 PARTIALLY DONE
- [x] iOS permissions configured
- [x] HealthKit integration
- [ ] iOS-specific UI adaptations
- [ ] Apple Sign-In
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

1. **AI Food Recognition** 🤖
   - Integrate food recognition API (Google Cloud Vision, Clarifai)
   - Automatic food detection from photos
   - Nutrition estimation from images
   - **Why:** Complete the nutrition photo feature, huge user value

2. **Enhanced Progress Analytics** 📊
   - Correlations between nutrition and weight
   - Habit adherence impact on progress
   - AI-powered progress predictions
   - **Why:** Leverage existing data for insights

### Short-term (Next 3-5 Sessions):

3. **Expand AI Coach**
   - Workout recommendations based on goals
   - Recovery advisor (HRV + sleep analysis)
   - Weekly coaching reports
   - **Why:** Leverage existing AI infrastructure

4. **Social Features (MVP)**
   - User profiles
   - Activity sharing
   - Simple challenges
   - **Why:** Increases engagement, viral potential

5. **Premium Tier Setup**
   - Subscription system with RevenueCat
   - Paywall implementation
   - Premium-only features
   - **Why:** Monetization for sustainability

### Medium-term (Next 6-10 Sessions):

6. **Wearable Integration**
   - Apple Watch
   - Garmin
   - Fitbit
   - **Why:** Automatic data sync, user convenience

7. **iOS Launch**
   - Platform-specific features
   - App Store submission
   - **Why:** Expand user base

8. **Gamification**
   - Achievement badges
   - Levels and XP
   - Challenges
   - **Why:** Engagement and retention

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
- **Nutrition Repo:** `lib/features/nutrition/data/repositories/nutrition_repository.dart`
- **Progress Repo:** `lib/features/progress/data/repositories/progress_repository.dart`
- **AI Insights (Habits):** `lib/features/habits/data/services/habit_insights_service.dart`
- **OpenFoodFacts:** `lib/features/nutrition/data/services/openfoodfacts_service.dart`
- **Photo Service:** `lib/features/nutrition/data/services/nutrition_photo_service.dart`
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

### 4. **Test Latest Features:**

**Nutrition Module:**
- Navigate to Nutrition tab from home
- Log a meal with photos
- Scan a barcode from food search
- View AI Insights
- Check water intake tracking
- Review nutrition history

**Habits:**
- Create a new habit
- Complete it (tap checkmark)
- View AI Insights
- Long-press for edit/delete

**Progress:**
- Log weight
- Add body measurements
- Upload progress photos
- View progress charts

### 5. **Firebase Console:**
- URL: https://console.firebase.google.com/
- Project: grandmind-kinesa
- Check Firestore for data
- Monitor indexes status
- View Firebase Storage for uploaded photos

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

### Issue: Camera Permissions
**Error:** "Permission denied" for camera
**Solution:**
- Android: Ensure CAMERA permission in AndroidManifest.xml
- iOS: Ensure NSCameraUsageDescription in Info.plist
- Request runtime permissions

### Issue: Barcode Scanner Not Working
**Possible Causes:**
1. Camera permission not granted
2. mobile_scanner package not installed
3. Emulator doesn't support camera
**Solution:** Test on real device, check permissions

### Issue: Photo Upload Failing
**Possible Causes:**
1. Firebase Storage rules not configured
2. No internet connection
3. File size too large
**Solution:** Check Firebase Storage rules, verify network

### Issue: AI Insights Not Loading
**Possible Causes:**
1. No Claude API key in secure storage
2. Insufficient data (need historical data)
3. API rate limit reached
**Solution:** Check logs, verify API key, ensure data exists

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

### Features Completed: **11/15** (73%)
- ✅ Authentication
- ✅ Onboarding
- ✅ Dashboard
- ✅ Workouts
- ✅ Habits (with AI insights)
- ✅ **Nutrition (with AI insights, barcode, photos)** ✅ NEW!
- ✅ **Progress Tracking** ✅
- ✅ **Health Data Integration** ✅
- ✅ Basic AI Coach
- ✅ Notifications System
- ✅ Profile & Settings

### Code Stats:
- **Total Files:** ~220+
- **Lines of Code:** ~25,000+
- **Features Folders:** 13
- **Models (Freezed):** 22+
- **Repositories:** 8
- **Services:** 12+
- **Providers:** 25+
- **Screens:** 45+

### Firestore Collections: **11+**
- users
- habits
- habit_logs
- food_items (nutrition)
- meals (nutrition)
- water_logs (nutrition)
- nutrition_goals (nutrition)
- weight_entries (progress)
- measurements (progress)
- progress_photos (progress)
- progress_goals (progress)
- workouts
- notification_preferences (subcollection)
- notification_history (subcollection)

### External API Integrations: **3**
- Claude AI (Anthropic)
- OpenFoodFacts API
- HealthKit/Health Connect

---

## 📞 Session Notes

### What Worked Well This Session (2026-01-08):
✅ Implemented complete AI Insights system for nutrition
✅ Added barcode scanner with OpenFoodFacts integration
✅ Implemented meal photo capture and upload
✅ Firebase Storage integration working smoothly
✅ Comprehensive nutrition analytics with 4-tab layout
✅ Cross-domain insights connecting nutrition to other health metrics
✅ Clean architecture maintained throughout

### Challenges Overcome:
- Integrated multiple complex systems (camera, barcode, storage, AI)
- Maintained consistent architecture patterns
- Ensured proper permissions for all platforms
- Created intuitive UI for complex features

### Previous Session Achievements:
✅ Completed notifications system with reminders
✅ Habits feature with AI insights
✅ Progress tracking with charts
✅ Health data integration
✅ Systematic Firestore query optimization

### Key Learnings:
- Complex features can be built systematically with planning
- AI insights provide tremendous user value
- Barcode scanning significantly improves UX
- Photo features add engagement and motivation
- Cross-domain insights create holistic health view
- OpenFoodFacts API is reliable and comprehensive

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
Info: Colors.blue
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

### Component Patterns:
- Cards with rounded corners (12px radius)
- Gradient backgrounds for special sections
- Progress bars for tracking
- Icon + text combinations
- Bottom sheets for selections
- Floating action buttons for primary actions

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
- Nutrition logging rate > 50%

### Retention:
- Day 1: > 60%
- Day 7: > 40%
- Day 30: > 25%

### Feature Usage:
- Barcode scans per user > 10/month
- Photos uploaded > 5/month
- AI insights views > 20/month

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

*Last session date: 2026-01-08*
*Session focus: Complete Nutrition Module - AI Insights, Barcode Scanner, Photos*
*Next recommended feature: AI Food Recognition or Social Features*

---

## Quick Reference Commands

```bash
# Start project
cd C:\dev\projects\grandmind && flutter run -d emulator-5554

# Install dependencies (after adding packages)
flutter pub get

# Check Firestore indexes
cat firestore.indexes.json

# View git history
git log --oneline --graph --all

# Clean build
flutter clean && flutter pub get && flutter run

# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade
```

**🎉 You're all set to continue building Kinesa/Grandmind!**
