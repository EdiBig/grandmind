# GrandMind - Holistic Fitness & Wellbeing App
## Project Memory for Claude Code

---

## Project Overview

**App Name:** GrandMind

**Vision:** A holistic fitness companion that adapts to your life and keeps you motivated — combining whole-life tracking, behavioural science, and an optional human touch to deliver a supportive coaching experience.

**Core Philosophy:** "No guilt. No overwhelm. Just progress."

**Brand Personality:** Science-backed + warm (Headspace meets Examine.com). Serious clinical credibility with friendly, supportive tone. Anti-toxic hustle culture, pro-self-compassion.

**Tagline Options:**
- "Your Personal Wellness Coach, in Your Pocket"
- "Fitness That Fits Your Life"

---

## Founder Context

- **Background:** MSc Bioinformatics with expertise in data analysis, ML, and computational biology
- **Competitive Advantage:** Can build data-driven features (ML personalisation, recovery advisor) that competitors lack
- **Working Style:** Solo founder, bootstrapped, organic growth strategy
- **Budget:** <£5k for MVP
- **Timeline:** 8-12 weeks to MVP
- **Target Platforms:** iOS & Android (simultaneous via Flutter)
- **Success Metric:** £5-10k MRR in Year 1

---

## Tech Stack (Flutter + Firebase)

| Component | Choice | Rationale |
|-----------|--------|-----------|
| **Frontend** | Flutter (Dart) | Cross-platform iOS & Android, near-native performance, hot reload |
| **Backend** | Firebase | Auth, Firestore, Cloud Functions, Storage — no server management |
| **Database** | Cloud Firestore | NoSQL, real-time sync, offline support |
| **Auth** | Firebase Authentication | Email/password + Google/Apple Sign-In |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Free, reliable, cross-platform |
| **Storage** | Firebase Storage | Progress photos, exercise media |
| **Analytics** | Firebase Analytics + Crashlytics | Free, built-in |
| **State Management** | Riverpod | Simple, scalable, recommended over Provider/Bloc |
| **Payments** | RevenueCat | Abstracts App Store + Google Play subscriptions |
| **Health Data** | HealthKit (iOS) / Health Connect (Android) | Via `health` Flutter plugin |

**Monthly Cost (MVP):** £0-50/mo (Firebase free tier)

---

## Three Core Differentiators

### 1. Adaptive, Compassionate Coaching Engine (AI + Behavioural Science)
- AI coach that adapts not just to performance but to lapses, mood, and life context
- Changes tone and support style based on user preferences (Friendly vs Strict vs Clinical)
- Handles relapse gracefully — no other app does "relapse recovery" with empathy
- Uses mood, schedule, wearable data to personalise recommendations
- Example: "You're tired today — here's a lighter workout" vs demanding adherence

### 2. Truly Holistic Health Integration & Insights Hub
- Unified dashboard: fitness, nutrition, sleep, mood, stress in one place
- Cross-domain insights: "On days you sleep <7h, your workout performance drops"
- Integrates Apple Health, Google Fit, and major wearables
- Becomes the "mission control" for the user's healthy life

### 3. Scalable Community with Expert Overlay
- Supportive community with moderated, positive culture
- Micro-coaching marketplace (Q&A with certified coaches)
- Small group challenges with coaching guidance
- Social accountability (optional buddy system)
- No toxicity or bro-science — curated, helpful environment

---

## Target Personas (4 Primary)

### Persona A: "Busy Professional Balancer" — Aria, 34
- Marketing Manager, works 10+ hour days
- **Goal:** Improve wellness, lose weight, reduce stress, sleep better
- **Pain Points:** Guilt from "failing" routines, overwhelmed by apps demanding daily logging
- **Needs:** 5-15 min workouts, flexible scheduling, non-judgmental support
- **Aha Moment:** Completes 10-min stretch, sleeps better, app congratulates her

### Persona B: "Fitness Newbie on a Mission" — Ben, 26
- Sedentary, slightly overweight, never been into fitness
- **Goal:** Lose 10kg, build confidence, run a 5K
- **Pain Points:** Intimidated by gyms, overwhelmed by fitness info, quick to quit
- **Needs:** Ultra-beginner workouts, gamification, simple nutrition habits
- **Aha Moment:** Completes first workout, earns achievement, feels proud not discouraged

### Persona C: "Quantified Athlete" — Carlos, 39
- Amateur marathoner, data geek, uses multiple apps (Garmin, MFP, spreadsheets)
- **Goal:** Streamline tracking, get deeper insights, optimise performance
- **Pain Points:** Data siloed across apps, generic training plans
- **Needs:** Unified dashboard, advanced analytics, PR tracking, Strava-like social
- **Aha Moment:** Sees all data unified with insight he never noticed before

### Persona D: "Health-Focused Caregiver" — Dev, 48
- Father of two, borderline high BP, pre-diabetic, mild knee arthritis
- **Goal:** Health management, lose 15 lbs, model good habits for kids
- **Pain Points:** Typical fitness apps alienating (young fit people), needs low-impact
- **Needs:** Low-impact exercises, health metric tracking (BP, blood sugar), family challenges
- **Aha Moment:** Sees BP improve after week of walking, doctor would be proud

---

## Development Phases (13 Phases, 12 Weeks)

### PHASE 0: Project Setup & Foundation (Week 1, Days 1-2)
- [ ] Flutter project initialised (`flutter create grandmind`)
- [ ] Firebase project configured (FlutterFire CLI)
- [ ] Folder structure established
- [ ] Core dependencies installed (pubspec.yaml)
- [ ] Basic app shell with navigation

### PHASE 1: Authentication & User Management (Week 1, Days 3-5)
- [ ] Email/password authentication
- [ ] Google OAuth
- [ ] Apple Sign-In
- [ ] Password reset flow
- [ ] Basic profile creation
- [ ] Firebase Auth integration
- [ ] Session management

### PHASE 2: Onboarding Flow (Week 2, Days 1-3)
- [ ] Multi-step onboarding wizard (5-7 screens)
- [ ] Goal selection (weight loss, strength, wellness, habits)
- [ ] Fitness level assessment
- [ ] Time availability questions
- [ ] Injury/limitation capture ("bad knees?")
- [ ] Coach tone selection (Friendly/Strict/Clinical)
- [ ] Initial plan generation (rule-based)
- [ ] Data persistence to Firestore

### PHASE 3: Home Dashboard & Core UI (Week 2, Days 4-5)
- [ ] Bottom navigation (Home, Plan, Progress, Community, Settings)
- [ ] Home dashboard with dynamic widgets
- [ ] Today's workout/plan display
- [ ] Step count widget (basic)
- [ ] Quick action buttons
- [ ] Motivational tip of the day
- [ ] Responsive layout

### PHASE 4: Workout System (Weeks 3-4)
**4A: Workout Library & Models**
- [ ] Workout data models (Firestore)
- [ ] 10-15 pre-designed workouts (JSON/Firestore)
- [ ] Exercise database with descriptions
- [ ] Video/GIF asset integration

**4B: Workout Player**
- [ ] Workout detail screen
- [ ] Exercise list view
- [ ] Timer functionality
- [ ] Audio cues
- [ ] Pause/skip/restart controls
- [ ] Progress tracking during workout

**4C: Workout Logging**
- [ ] Quick activity log (<30 seconds)
- [ ] Manual workout entry
- [ ] Activity type selection
- [ ] Duration, distance, sets/reps inputs
- [ ] Perceived effort rating (RPE 1-10)
- [ ] Energy before/after (1-5)
- [ ] Context tags (stressed/tired/great)
- [ ] Auto-save to Firestore

### PHASE 5: Health Integrations (Week 5)
- [ ] HealthKit integration (iOS) — steps, sleep, workouts, weight, HR
- [ ] Health Connect integration (Android)
- [ ] Permission flows with clear explanations
- [ ] Write completed workouts back to Health
- [ ] Background sync handling
- [ ] Offline data management
- [ ] Data displayed on dashboard

### PHASE 6: Holistic Tracking (Week 6)
- [ ] Water intake tracker
- [ ] Sleep hours logging (manual + auto-import)
- [ ] Mood check-in (1-5 scale + emoji)
- [ ] Weight logging with graph
- [ ] Optional: Blood pressure, blood sugar tracking
- [ ] Habit tracking (max 3 free tier)
- [ ] Quick-add modals

### PHASE 7: Progress & Analytics (Week 7)
- [ ] Activity calendar (heatmap)
- [ ] Weight/metric line graphs (fl_chart)
- [ ] Streak counter (adaptive, not punishing)
- [ ] Personal bests tracker
- [ ] Weekly summary screen
- [ ] Progress milestones & badges

### PHASE 8: Plan Management (Week 8)
- [ ] Plan view screen (weekly schedule)
- [ ] Workout schedule calendar
- [ ] Manual reschedule/swap workouts
- [ ] Goal editing
- [ ] Plan difficulty adjustment
- [ ] Program switching (2-3 templates)

### PHASE 9: Notifications & Engagement (Week 9)
- [ ] FCM setup
- [ ] Daily plan reminders
- [ ] Workout day alerts
- [ ] Inactivity nudges (3+ days — compassionate tone)
- [ ] Achievement notifications
- [ ] Coach tone customisation in notification copy
- [ ] Notification preferences screen

### PHASE 10: Settings & Profile (Week 10)
- [ ] Profile editing (photo, name, weight, height)
- [ ] Units toggle (metric/imperial)
- [ ] Notification preferences
- [ ] Connected services management
- [ ] Data export (JSON/CSV)
- [ ] Account deletion (GDPR)
- [ ] Privacy & Terms links

### PHASE 11: Polish & UX (Week 11)
- [ ] Animations (Lottie for celebrations)
- [ ] Empty states with illustrations
- [ ] Error handling UI
- [ ] Accessibility (screen readers, contrast)
- [ ] Dark mode support
- [ ] Loading states throughout

### PHASE 12: Testing & QA (Week 12)
- [ ] Test on iOS simulator + real device
- [ ] Test on Android emulator + real device
- [ ] Test offline scenarios
- [ ] Test edge cases (empty states, errors)
- [ ] Fix critical bugs
- [ ] Performance optimisation

### PHASE 13: Launch Preparation (Week 12)
- [ ] App Store assets (screenshots, preview video)
- [ ] Play Store assets
- [ ] Privacy policy & Terms of Service
- [ ] Health disclaimer
- [ ] TestFlight beta distribution
- [ ] Play Console internal testing
- [ ] Submit to stores

---

## Database Schema (Firestore Collections)

### Users Collection: `/users/{userId}`
```json
{
  "userId": "string (UID)",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string | null",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "subscriptionTier": "free | premium | premium_annual",
  "timezone": "Europe/London",
  "preferences": {
    "coachTone": "friendly | strict | clinical",
    "units": "metric | imperial",
    "modulesEnabled": ["workouts", "habits", "mood", "nutrition", "sleep"],
    "notificationsEnabled": true,
    "reminderTime": "08:00"
  },
  "onboarding": {
    "completed": true,
    "goalType": "weight_loss | strength | wellness | habit",
    "fitnessLevel": "beginner | intermediate | advanced",
    "weeklyWorkouts": 3,
    "limitations": ["bad_knees", "back_pain"],
    "currentPlanId": "string | null"
  }
}
```

### Workouts: `/users/{userId}/workouts/{workoutId}`
```json
{
  "workoutId": "string",
  "workoutDate": "timestamp",
  "workoutType": "strength | cardio | yoga | walk | sport | other",
  "templateId": "string | null",
  "durationMinutes": 30,
  "caloriesBurned": 250,
  "energyBefore": 3,
  "energyAfter": 4,
  "perceivedEffort": 7,
  "contextTags": ["stressed", "tired"],
  "notes": "string | null",
  "exercises": [
    {
      "exerciseName": "Squats",
      "sets": 3,
      "reps": 12,
      "weightKg": 40,
      "durationSeconds": null,
      "rpe": 7
    }
  ],
  "createdAt": "timestamp"
}
```

### Habits: `/users/{userId}/habits/{habitId}`
```json
{
  "habitId": "string",
  "habitName": "Drink 8 glasses of water",
  "frequencyType": "daily | weekly | custom",
  "frequencyTarget": 1,
  "isActive": true,
  "createdAt": "timestamp"
}
```

### Habit Logs: `/users/{userId}/habitLogs/{logId}`
```json
{
  "logId": "string",
  "habitId": "string",
  "logDate": "timestamp (date only)",
  "completed": true
}
```

### Mood Logs: `/users/{userId}/moodLogs/{logId}`
```json
{
  "logId": "string",
  "logDate": "timestamp",
  "energyLevel": 4,
  "moodRating": 4,
  "contextTags": ["productive", "calm"],
  "notes": "string | null"
}
```

### Health Data: `/users/{userId}/healthData/{date}`
```json
{
  "date": "2025-12-26",
  "steps": 8500,
  "sleepHours": 7.5,
  "hrvMs": 45.2,
  "restingHr": 58,
  "weight": 75.5,
  "syncedAt": "timestamp"
}
```

### Workout Templates: `/workoutTemplates/{templateId}`
```json
{
  "templateId": "string",
  "name": "Full Body Beginner",
  "description": "A gentle introduction to strength training",
  "category": "strength | cardio | yoga | hiit",
  "level": "beginner | intermediate | advanced",
  "durationMinutes": 20,
  "isPremium": false,
  "exercises": [
    {
      "name": "Bodyweight Squat",
      "sets": 3,
      "reps": 10,
      "durationSeconds": null,
      "restSeconds": 60,
      "videoUrl": "string | null",
      "instructions": "Stand with feet shoulder-width apart..."
    }
  ]
}
```

---

## Feature Roadmap Summary

### MVP (Weeks 1-12) — Validate Core Value Prop
✅ Auth (email + social)
✅ Onboarding with persona questions
✅ Quick workout logging (<30 sec)
✅ Daily energy check-in
✅ Habit tracking (3 max free)
✅ Weekly summary
✅ Apple Health/Google Fit read
✅ Adaptive streaks (compassionate)
✅ Coach tone toggle
✅ Basic progress graphs

❌ **NOT in MVP:** Video streaming, coaching marketplace, advanced AI/ML, gamification beyond streaks, nutrition calorie tracking

### V1 (Months 3-6) — Retention & Monetisation
- Premium subscription (£4.99/mo or £39.99/yr)
- Unlimited habits (up to 10)
- Detailed exercise logging
- Advanced insights & correlations
- Workout templates library
- Apple Health write
- Android launch parity
- Basic AI coaching responses

### V2 (Months 6-12) — Scale & Differentiate
- AI Recovery Advisor (HRV + sleep → readiness score)
- ML-driven personalisation
- Wearable integrations (Garmin, Fitbit, Oura)
- Coaching marketplace (micro-coaching Q&A)
- Community features (challenges, groups)
- Corporate wellness B2B offering

---

## Monetisation Strategy

### Free Tier
- Unlimited basic workout logging
- 3 habits max
- Daily energy check-in
- Weekly summary (basic)
- Apple Health read

### Premium (£4.99/mo or £39.99/yr)
- Unlimited habits (up to 10)
- Detailed exercise logging (sets/reps/weight)
- Advanced insights & trends
- Workout templates
- Data export (CSV/JSON)
- Priority support

### Future Revenue
- Coaching marketplace (20-30% platform fee)
- Corporate wellness partnerships (B2B, £3-5/employee/mo)

---

## Analytics Events

```dart
// Onboarding
'onboarding_started'
'onboarding_step_completed' // {step: int}
'onboarding_completed' // {goalType, fitnessLevel}

// Core Actions
'workout_logged' // {type, duration, hasExercises}
'habit_completed' // {habitName}
'mood_logged' // {energyLevel}
'health_synced' // {source: apple_health | google_fit}

// Engagement
'streak_achieved' // {length}
'streak_broken'
'weekly_summary_viewed'
'personal_best_achieved' // {metric}

// Monetisation
'paywall_viewed' // {trigger}
'subscription_started' // {plan, price}
'subscription_cancelled'
'trial_started'
```

---

## Key Metrics to Track

| Category | Metric | Target |
|----------|--------|--------|
| **Activation** | % complete onboarding | >80% |
| **Activation** | % log first workout in 7 days | >50% |
| **Retention** | Day 1 retention | >60% |
| **Retention** | Day 7 retention | >40% |
| **Retention** | Day 30 retention | >25% |
| **Engagement** | WAU/MAU ratio | >40% |
| **Conversion** | Free → Paid | >5% |
| **Revenue** | Monthly churn | <8% |

---

## Privacy & Compliance

### GDPR Requirements (UK/EU)
- ✅ Explicit consent for data collection
- ✅ Right to access (data export)
- ✅ Right to deletion (account delete)
- ✅ Data portability (CSV/JSON export)
- ✅ Clear privacy policy

### App Store Compliance
- ✅ HealthKit usage descriptions in Info.plist
- ✅ Health data not used for advertising
- ✅ Not claiming medical diagnosis

### Health Disclaimers
- "This app is not a medical device and does not provide medical advice."
- "Always consult a qualified healthcare provider before making significant changes to your diet or exercise routine."

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── extensions/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── onboarding/
│   ├── home/
│   ├── workouts/
│   ├── habits/
│   ├── progress/
│   ├── plan/
│   └── settings/
├── shared/
│   ├── widgets/
│   └── services/
└── l10n/
```

---

## Reusable Widgets to Build

1. **CustomButton** — primary, secondary, text variants
2. **CustomTextField** — with validation, error states
3. **LoadingIndicator** — circular + shimmer
4. **EmptyState** — illustration + message + CTA
5. **ErrorView** — retry action
6. **StatCard** — dashboard metric widget
7. **ChartCard** — wrapper for fl_chart
8. **BottomSheet** — consistent design
9. **CustomAppBar** — back button + actions
10. **BadgeIcon** — achievements, notifications

---

## Services to Abstract

1. **AuthService** — Firebase Auth wrapper
2. **FirestoreService** — CRUD operations
3. **HealthService** — Unified HealthKit/Google Fit interface
4. **NotificationService** — FCM + local notifications
5. **AnalyticsService** — Event tracking
6. **StorageService** — Local SharedPreferences

---

## Quality Checkpoints (After Each Phase)

### Code Review
- [ ] All features working as expected
- [ ] No console errors or warnings
- [ ] Proper error handling (try-catch)
- [ ] Loading states implemented
- [ ] Null safety throughout
- [ ] No hardcoded values (use constants)

### Testing
- [ ] Tested on iOS simulator/device
- [ ] Tested on Android emulator/device
- [ ] Tested offline scenarios
- [ ] Tested edge cases (empty, error states)

### Firebase
- [ ] Firestore security rules updated
- [ ] User can only access own data
- [ ] Indexes created where needed

---

## Common Troubleshooting

### Firebase "not initialized" error
```dart
// Ensure in main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### HealthKit permissions not appearing (iOS)
1. Add HealthKit capability in Xcode (Runner > Signing & Capabilities)
2. Add to Info.plist:
```xml
<key>NSHealthShareUsageDescription</key>
<string>We read your health data to track your progress</string>
<key>NSHealthUpdateUsageDescription</key>
<string>We write workout data to your Health app</string>
```

### Build failures (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### State not updating (Riverpod)
- Use `ref.watch()` in build methods, not `ref.read()`
- Ensure `notifyListeners()` called after state changes
- Wrap widgets with `ConsumerWidget` or `Consumer`

---

## Notes for Claude Code

### Working Style
- This is a **solo founder project** — suggest pragmatic, time-efficient solutions
- Prioritise **shipping over perfection** for MVP
- The founder has **bioinformatics background** — comfortable with data/ML concepts
- **UK-based** — use British English spellings

### Technical Preferences
- Use **Riverpod** for state management (not Provider or Bloc)
- Use **GoRouter** for navigation
- Use **fl_chart** for graphs
- Keep files under 200 lines where possible
- Write **clean, readable code** with comments for complex logic

### Design Principles
- **Compassionate tone** in all user-facing copy
- No guilt-tripping or shame-based messaging
- Celebrate small wins
- Always provide graceful degradation if data unavailable

### When Uncertain
- Favour **simplicity** and user experience
- Ask clarifying questions rather than assuming
- Avoid feature creep — stick to the roadmap
- Consider GDPR implications for any data handling

---

## Current Development Status

**Last Updated:** [UPDATE THIS DATE]

### Completed
- [ ] Phase 0: Project setup

### In Progress
- [ ] Phase 1: Authentication

### Blockers
- None

### Notes
- [Add session notes here]
