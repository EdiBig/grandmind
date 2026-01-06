import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
          final phone = user?.phoneNumber ?? 'Not set';
          final dob = user?.dateOfBirth != null
              ? _formatDate(user!.dateOfBirth!)
              : 'Not set';
          final gender = user?.gender ?? 'Not set';
          final height = user?.height != null
              ? '${user!.height!.toStringAsFixed(0)} cm'
              : 'Not set';
          final weight = user?.weight != null
              ? '${user!.weight!.toStringAsFixed(1)} kg'
              : 'Not set';
          final fitnessLevel = user?.fitnessLevel ?? 'Not set';
          final goal = user?.goal ?? 'Not set';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, displayName, user?.email),
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
                  backgroundColor: AppColors.primary,
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

  Widget _buildProfileHeader(BuildContext context, String name, String? email) {
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
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: user?.photoUrl != null
                    ? Image.network(
                        user!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
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
                          gradient: AppColors.primaryGradient,
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
                decoration: const BoxDecoration(
                  color: AppColors.primary,
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
              AppColors.primary,
            ),
            loading: () => _buildStatCard(context, '...', 'Workouts', AppColors.primary),
            error: (_, __) => _buildStatCard(context, '0', 'Workouts', AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: streakAsync.when(
            data: (streak) => _buildStatCard(
              context,
              streak.toString(),
              'Day Streak',
              AppColors.secondary,
            ),
            loading: () => _buildStatCard(context, '...', 'Day Streak', AppColors.secondary),
            error: (_, __) => _buildStatCard(context, '0', 'Day Streak', AppColors.secondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: achievementsAsync.when(
            data: (count) => _buildStatCard(
              context,
              count.toString(),
              count == 1 ? 'Achievement' : 'Achievements',
              AppColors.accent,
            ),
            loading: () => _buildStatCard(context, '...', 'Achievements', AppColors.accent),
            error: (_, __) => _buildStatCard(context, '0', 'Achievements', AppColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
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
}
