import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/onboarding_data.dart';
import '../providers/onboarding_provider.dart';

class LimitationsScreen extends ConsumerWidget {
  const LimitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Step 4 of 5'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Any physical limitations?',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select all that apply. We\'ll adjust exercises accordingly.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber[900]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Always consult your doctor before starting any new exercise program',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
            // Continue button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.primary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [Colors.grey[300]!, Colors.grey[400]!],
                      ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: 24,
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
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    limitation.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
