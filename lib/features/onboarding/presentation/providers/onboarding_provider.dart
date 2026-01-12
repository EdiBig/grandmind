import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/user/data/services/firestore_service.dart';
import '../../../authentication/data/repositories/auth_repository.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/onboarding_data.dart';

/// Provider for Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for onboarding state management
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(firestoreServiceProvider),
  );
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final AuthRepository _authRepository;
  final FirestoreService _firestoreService;

  OnboardingNotifier(this._authRepository, this._firestoreService)
      : super(const OnboardingState.initial());

  // Update goal
  void setGoal(FitnessGoal goal) {
    state = state.copyWith(goal: goal);
  }

  // Update fitness level
  void setFitnessLevel(FitnessLevel level) {
    state = state.copyWith(fitnessLevel: level);
  }

  // Update weekly workout frequency
  void setWeeklyWorkouts(WeeklyWorkoutFrequency frequency) {
    state = state.copyWith(weeklyWorkouts: frequency);
  }

  // Update coach tone
  void setCoachTone(CoachTone tone) {
    state = state.copyWith(coachTone: tone);
  }

  // Toggle limitation
  void toggleLimitation(String limitationId) {
    final currentLimitations = List<String>.from(state.limitations);

    if (limitationId == 'none') {
      // If "None" is selected, clear all others
      state = state.copyWith(limitations: ['none']);
    } else {
      // Remove "None" if it exists
      currentLimitations.remove('none');

      if (currentLimitations.contains(limitationId)) {
        currentLimitations.remove(limitationId);
      } else {
        currentLimitations.add(limitationId);
      }

      state = state.copyWith(limitations: currentLimitations);
    }
  }

  // Save onboarding data to Firestore
  Future<void> completeOnboarding() async {
    if (!state.isComplete) {
      state = state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: 'Please complete all steps',
      );
      return;
    }

    state = state.copyWith(status: OnboardingStatus.saving);

    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Save onboarding data to Firestore
      await _firestoreService.updateUser(user.uid, {
        'hasCompletedOnboarding': true,
        'onboarding': {
          'completed': true,
          'goalType': state.goal!.name,
          'fitnessLevel': state.fitnessLevel!.name,
          'weeklyWorkouts': state.weeklyWorkouts!.daysPerWeek,
          'coachTone': state.coachTone!.name,
          'limitations': state.limitations,
        },
      });

      state = state.copyWith(status: OnboardingStatus.completed);
    } catch (e) {
      state = state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset onboarding state
  void reset() {
    state = const OnboardingState.initial();
  }
}

/// Onboarding state
class OnboardingState {
  final FitnessGoal? goal;
  final FitnessLevel? fitnessLevel;
  final WeeklyWorkoutFrequency? weeklyWorkouts;
  final CoachTone? coachTone;
  final List<String> limitations;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.goal,
    this.fitnessLevel,
    this.weeklyWorkouts,
    this.coachTone,
    this.limitations = const [],
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  const OnboardingState.initial()
      : goal = null,
        fitnessLevel = null,
        weeklyWorkouts = null,
        coachTone = null,
        limitations = const [],
        status = OnboardingStatus.initial,
        errorMessage = null;

  bool get isComplete =>
      goal != null &&
      fitnessLevel != null &&
      weeklyWorkouts != null &&
      coachTone != null;

  OnboardingState copyWith({
    FitnessGoal? goal,
    FitnessLevel? fitnessLevel,
    WeeklyWorkoutFrequency? weeklyWorkouts,
    CoachTone? coachTone,
    List<String>? limitations,
    OnboardingStatus? status,
    String? errorMessage,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      weeklyWorkouts: weeklyWorkouts ?? this.weeklyWorkouts,
      coachTone: coachTone ?? this.coachTone,
      limitations: limitations ?? this.limitations,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

enum OnboardingStatus {
  initial,
  saving,
  completed,
  error,
}
