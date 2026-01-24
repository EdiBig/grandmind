import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_shell.dart';

class TimeAvailabilityScreen extends ConsumerWidget {
  const TimeAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnboardingStepHeader(
                      step: 3,
                      totalSteps: 5,
                      title: 'How often can you work out?',
                      subtitle: 'We\'ll build a rhythm that fits your week.',
                      onBack: () => context.pop(),
                      eyebrow: 'Create a sustainable routine',
                    ),
                    const SizedBox(height: 24),
                    _FrequencySlider(
                      selected: onboardingState.weeklyWorkouts,
                      onSelected: (frequency) {
                        ref
                            .read(onboardingProvider.notifier)
                            .setWeeklyWorkouts(frequency);
                      },
                    ),
                    const SizedBox(height: 20),
                    ...WeeklyWorkoutFrequency.values.map((frequency) {
                      final isSelected =
                          onboardingState.weeklyWorkouts == frequency;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FrequencyCard(
                          frequency: frequency,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setWeeklyWorkouts(frequency);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Consistency beats intensity. Start with what feels sustainable.',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onboardingState.weeklyWorkouts != null
                      ? () => context.push(RouteConstants.onboardingLimitations)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final WeeklyWorkoutFrequency frequency;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyCard({
    required this.frequency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? Theme.of(context).extension<AppGradients>()!.primary
                    : LinearGradient(
                        colors: [
                          colorScheme.surface,
                          colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                frequency.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}

class _FrequencySlider extends StatelessWidget {
  const _FrequencySlider({
    required this.selected,
    required this.onSelected,
  });

  final WeeklyWorkoutFrequency? selected;
  final ValueChanged<WeeklyWorkoutFrequency> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = WeeklyWorkoutFrequency.values;
    final selectedIndex = selected == null ? 0 : options.indexOf(selected!);
    final active = options[selectedIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly target',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            active.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor:
                  colorScheme.outlineVariant.withValues(alpha: 0.4),
              thumbColor: colorScheme.primary,
            ),
            child: Slider(
              value: selectedIndex.toDouble(),
              min: 0,
              max: (options.length - 1).toDouble(),
              divisions: options.length - 1,
              onChanged: (value) {
                final nextIndex = value.round();
                onSelected(options[nextIndex]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
