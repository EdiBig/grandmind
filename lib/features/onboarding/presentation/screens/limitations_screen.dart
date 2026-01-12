import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_shell.dart';

class LimitationsScreen extends ConsumerWidget {
  const LimitationsScreen({super.key});

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
                      step: 4,
                      totalSteps: 5,
                      title: 'Any physical limitations?',
                      subtitle:
                          'Select all that apply. We\'ll tailor exercises safely.',
                      onBack: () => context.pop(),
                      eyebrow: 'Safety first',
                    ),
                    const SizedBox(height: 20),
                    _LimitationShortcuts(
                      hasSelections: onboardingState.limitations.isNotEmpty,
                      onSelectNone: () {
                        for (final limitation in PhysicalLimitation
                            .commonLimitations) {
                          if (onboardingState.limitations
                              .contains(limitation.id)) {
                            ref
                                .read(onboardingProvider.notifier)
                                .toggleLimitation(limitation.id);
                          }
                        }
                        ref
                            .read(onboardingProvider.notifier)
                            .toggleLimitation('none');
                      },
                      onClear: () {
                        for (final limitation
                            in List<String>.from(onboardingState.limitations)) {
                          ref
                              .read(onboardingProvider.notifier)
                              .toggleLimitation(limitation);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.tertiary.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Always consult your doctor before starting any new exercise program.',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...PhysicalLimitation.commonLimitations.map((limitation) {
                      final isSelected =
                          onboardingState.limitations.contains(limitation.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LimitationCard(
                          limitation: limitation,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(onboardingProvider.notifier)
                                .toggleLimitation(limitation.id);
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
                  onPressed: () =>
                      context.push(RouteConstants.onboardingCoachTone),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
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

class _LimitationCard extends StatelessWidget {
  final PhysicalLimitation limitation;
  final bool isSelected;
  final VoidCallback onTap;

  const _LimitationCard({
    required this.limitation,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (limitation.id) {
      case 'knee_pain':
        return Icons.airline_seat_legroom_reduced;
      case 'back_pain':
        return Icons.accessibility_new;
      case 'shoulder_pain':
        return Icons.front_hand;
      case 'pregnancy':
        return Icons.pregnant_woman;
      case 'heart_condition':
        return Icons.favorite;
      case 'none':
        return Icons.check;
      default:
        return Icons.warning_amber;
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? Theme.of(context).extension<AppGradients>()!.primary
                    : LinearGradient(
                        colors: [
                          colorScheme.surface,
                          colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    limitation.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    limitation.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: colorScheme.primary,
              activeTrackColor: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitationShortcuts extends StatelessWidget {
  const _LimitationShortcuts({
    required this.hasSelections,
    required this.onSelectNone,
    required this.onClear,
  });

  final bool hasSelections;
  final VoidCallback onSelectNone;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ChoiceChip(
          label: const Text('None'),
          selected: false,
          onSelected: (_) => onSelectNone(),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Clear all'),
          selected: false,
          onSelected: hasSelections ? (_) => onClear() : null,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                hasSelections ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
