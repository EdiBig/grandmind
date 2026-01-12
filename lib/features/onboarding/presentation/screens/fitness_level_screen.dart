import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_shell.dart';

class FitnessLevelScreen extends ConsumerWidget {
  const FitnessLevelScreen({super.key});

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
                      step: 2,
                      totalSteps: 5,
                      title: 'What\'s your fitness level?',
                      subtitle: 'We\'ll adjust your plan to meet you where you are.',
                      onBack: () => context.pop(),
                      eyebrow: 'Set your baseline',
                    ),
                    const SizedBox(height: 24),
                    _LevelChips(
                      selected: onboardingState.fitnessLevel,
                      onSelected: (level) {
                        ref
                            .read(onboardingProvider.notifier)
                            .setFitnessLevel(level);
                      },
                    ),
                    const SizedBox(height: 20),
                    ...FitnessLevel.values.map((level) {
                      final isSelected = onboardingState.fitnessLevel == level;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LevelCard(
                          level: level,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .setFitnessLevel(level);
                          },
                        ),
                      );
                    }),
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
                  onPressed: onboardingState.fitnessLevel != null
                      ? () =>
                          context.push(RouteConstants.onboardingTimeAvailability)
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

class _LevelChips extends StatelessWidget {
  const _LevelChips({
    required this.selected,
    required this.onSelected,
  });

  final FitnessLevel? selected;
  final ValueChanged<FitnessLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FitnessLevel.values.map((level) {
        final isSelected = level == selected;
        return ChoiceChip(
          label: Text(level.displayName),
          selected: isSelected,
          onSelected: (_) => onSelected(level),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),
          selectedColor: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final FitnessLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  String _getEmoji() {
    switch (level) {
      case FitnessLevel.beginner:
        return '🌱';
      case FitnessLevel.intermediate:
        return '💪';
      case FitnessLevel.advanced:
        return '🏆';
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                _getEmoji(),
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
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
      ),
    );
  }
}
