import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_shell.dart';

class CoachToneScreen extends ConsumerWidget {
  const CoachToneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
      if (next.status == OnboardingStatus.completed) {
        context.go(RouteConstants.home);
      } else if (next.status == OnboardingStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
                      step: 5,
                      totalSteps: 5,
                      title: 'Choose your coach style',
                      subtitle: 'Pick the tone that keeps you motivated.',
                      onBack: () => context.pop(),
                      eyebrow: 'Make it personal',
                    ),
                    const SizedBox(height: 24),
                    _ToneSegmentedControl(
                      selected: onboardingState.coachTone,
                      onSelected: (tone) {
                        ref
                            .read(onboardingProvider.notifier)
                            .setCoachTone(tone);
                      },
                    ),
                    const SizedBox(height: 20),
                    ...CoachTone.values.map((tone) {
                      final isSelected = onboardingState.coachTone == tone;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CoachToneCard(
                          tone: tone,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setCoachTone(tone);
                          },
                        ),
                      );
                    }),
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
                            Icons.check_circle_outline,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can change this anytime in settings.',
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
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onboardingState.coachTone != null &&
                          onboardingState.status != OnboardingStatus.saving
                      ? () async {
                          await ref
                              .read(onboardingProvider.notifier)
                              .completeOnboarding();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                  ),
                  child: onboardingState.status == OnboardingStatus.saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Get Started!',
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

class _ToneSegmentedControl extends StatelessWidget {
  const _ToneSegmentedControl({
    required this.selected,
    required this.onSelected,
  });

  final CoachTone? selected;
  final ValueChanged<CoachTone> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: CoachTone.values.map((tone) {
          final isSelected = tone == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(tone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tone.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CoachToneCard extends StatelessWidget {
  final CoachTone tone;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoachToneCard({
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  String _getExample() {
    switch (tone) {
      case CoachTone.friendly:
        return '"Great job today! Every step counts. You\'re doing amazing!"';
      case CoachTone.strict:
        return '"You committed to 4 workouts. Let\'s finish strong this week."';
      case CoachTone.clinical:
        return '"Your consistency rate is 85%. Zone 3 is optimal for today."';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tone.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tone.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        tone.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.surface
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                _getExample(),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
