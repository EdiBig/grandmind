import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(RouteConstants.editProfile),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          final displayName = user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!
              : user?.email ?? 'User';
          final authPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;
          final userPhotoUrl =
              user?.photoUrl?.trim().isNotEmpty == true ? user!.photoUrl : null;
          final resolvedPhotoUrl =
              userPhotoUrl ?? (authPhotoUrl?.trim().isNotEmpty == true ? authPhotoUrl : null);
          final unitPreference =
              user?.preferences?['units'] as String? ?? 'Metric';
          final phone = user?.phoneNumber ?? 'Not set';
          final dob = user?.dateOfBirth != null
              ? _formatDate(user!.dateOfBirth!)
              : 'Not set';
          final gender = user?.gender ?? 'Not set';
          final height = user?.height != null
              ? _formatHeight(user!.height!, unitPreference)
              : 'Not set';
          final weight = user?.weight != null
              ? _formatWeight(user!.weight!, unitPreference)
              : 'Not set';
          final fitnessLevel = user?.fitnessLevel ?? 'Not set';
          final goal = user?.goal ?? 'Not set';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(
                context,
                displayName,
                user?.email,
                resolvedPhotoUrl,
              ),
              const SizedBox(height: 32),
              _buildStatsRow(context, ref),
              const SizedBox(height: 32),
              _buildSection(context, 'Personal Information', [
                _buildInfoTile(
                    context, 'Email', user?.email ?? 'Not set', Icons.email_outlined),
                _buildInfoTile(context, 'Phone', phone, Icons.phone_outlined),
                _buildInfoTile(context, 'Date of Birth', dob, Icons.cake_outlined),
                _buildInfoTile(context, 'Gender', gender, Icons.person_outline),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, 'Fitness Information', [
                _buildInfoTile(context, 'Height', height, Icons.height),
                _buildInfoTile(
                    context, 'Weight', weight, Icons.monitor_weight_outlined),
                _buildInfoTile(
                    context, 'Fitness Level', fitnessLevel, Icons.fitness_center),
                _buildInfoTile(context, 'Goal', goal, Icons.flag_outlined),
              ]),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push(RouteConstants.editProfile),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load profile')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String? email, String? photoUrl) {
    final gradients = Theme.of(context).extension<AppGradients>()!;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          key: ValueKey(photoUrl),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          webHtmlElementStrategy: kIsWeb
                              ? WebHtmlElementStrategy.prefer
                              : WebHtmlElementStrategy.never,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              gradient: gradients.primary,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                        decoration: BoxDecoration(
                          gradient: gradients.primary,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name.toUpperCase(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final workoutsAsync = ref.watch(totalWorkoutsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final achievementsAsync = ref.watch(achievementsCountProvider);

    return Row(
      children: [
        Expanded(
          child: workoutsAsync.when(
            data: (count) => _buildStatCard(
              context,
              count.toString(),
              count == 1 ? 'Workout' : 'Workouts',
              primary,
            ),
            loading: () => _buildStatCard(context, '...', 'Workouts', primary),
            error: (_, __) => _buildStatCard(context, '0', 'Workouts', primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: streakAsync.when(
            data: (streak) => _buildStatCard(
              context,
              streak.toString(),
              'Day Streak',
              secondary,
            ),
            loading: () => _buildStatCard(context, '...', 'Day Streak', secondary),
            error: (_, __) => _buildStatCard(context, '0', 'Day Streak', secondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: achievementsAsync.when(
            data: (count) => _buildStatCard(
              context,
              count.toString(),
              count == 1 ? 'Achievement' : 'Achievements',
              tertiary,
            ),
            loading: () => _buildStatCard(context, '...', 'Achievements', tertiary),
            error: (_, __) => _buildStatCard(context, '0', 'Achievements', tertiary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatHeight(double heightCm, String unitPreference) {
    if (unitPreference == 'Imperial') {
      final inches = heightCm / 2.54;
      return '${inches.toStringAsFixed(1)} in';
    }
    return '${heightCm.toStringAsFixed(0)} cm';
  }

  String _formatWeight(double weightKg, String unitPreference) {
    if (unitPreference == 'Imperial') {
      final lbs = weightKg * 2.2046226218;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${weightKg.toStringAsFixed(1)} kg';
  }
}
