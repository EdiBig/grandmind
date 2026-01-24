import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_shell.dart';

class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

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
                      step: 1,
                      totalSteps: 5,
                      title: 'What\'s your main goal?',
                      subtitle: 'Choose what matters most to you right now.',
                      onBack: () => context.pop(),
                      eyebrow: 'Personalize your plan',
                    ),
                    const SizedBox(height: 24),
                    _GoalChipRow(
                      selected: onboardingState.goal,
                      onSelected: (goal) {
                        ref.read(onboardingProvider.notifier).setGoal(goal);
                      },
                    ),
                    const SizedBox(height: 20),
                    ...FitnessGoal.values.map((goal) {
                      final isSelected = onboardingState.goal == goal;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GoalCard(
                          goal: goal,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(onboardingProvider.notifier).setGoal(goal);
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
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onboardingState.goal != null
                      ? () =>
                          context.push(RouteConstants.onboardingFitnessLevel)
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

class _GoalChipRow extends StatelessWidget {
  const _GoalChipRow({
    required this.selected,
    required this.onSelected,
  });

  final FitnessGoal? selected;
  final ValueChanged<FitnessGoal> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FitnessGoal.values.map((goal) {
        final isSelected = goal == selected;
        return ChoiceChip(
          label: Text(goal.displayName),
          selected: isSelected,
          onSelected: (_) => onSelected(goal),
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

class _GoalCard extends StatelessWidget {
  final FitnessGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (goal) {
      case FitnessGoal.weightLoss:
        return Icons.trending_down;
      case FitnessGoal.buildMuscle:
        return Icons.fitness_center;
      case FitnessGoal.generalFitness:
        return Icons.directions_run;
      case FitnessGoal.wellness:
        return Icons.spa;
      case FitnessGoal.buildHabits:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                          colorScheme.surfaceContainerHighest,
                          colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getIcon(),
                color: AppColors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.displayName,
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
                goal.description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _getBadges(colorScheme, isSelected),
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

  List<Widget> _getBadges(ColorScheme colorScheme, bool isSelected) {
    final accent = isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    switch (goal) {
      case FitnessGoal.weightLoss:
        return [
          _Badge(label: 'Fat burn', icon: Icons.local_fire_department, color: accent),
          _Badge(label: 'Lean', icon: Icons.monitor_weight, color: accent),
        ];
      case FitnessGoal.buildMuscle:
        return [
          _Badge(label: 'Strength', icon: Icons.fitness_center, color: accent),
          _Badge(label: 'Power', icon: Icons.bolt, color: accent),
        ];
      case FitnessGoal.generalFitness:
        return [
          _Badge(label: 'Cardio', icon: Icons.directions_run, color: accent),
          _Badge(label: 'Stamina', icon: Icons.favorite, color: accent),
        ];
      case FitnessGoal.wellness:
        return [
          _Badge(label: 'Mindful', icon: Icons.self_improvement, color: accent),
          _Badge(label: 'Balance', icon: Icons.spa, color: accent),
        ];
      case FitnessGoal.buildHabits:
        return [
          _Badge(label: 'Consistency', icon: Icons.track_changes, color: accent),
          _Badge(label: 'Routine', icon: Icons.event_repeat, color: accent),
        ];
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
