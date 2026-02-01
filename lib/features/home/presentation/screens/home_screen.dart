import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_nav_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_tab.dart';
import 'workouts_tab.dart';
import 'track_tab.dart';
import 'progress_tab.dart';
import '../../../unity/presentation/screens/unity_hub_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // 5 tabs: Home, Workouts, Track (Habits+Nutrition), Progress, Unity
    final List<Widget> tabs = [
      const DashboardTab(),
      const WorkoutsTab(),
      const TrackTab(),
      const ProgressTab(),
      const UnityHubScreen(),
    ];

    return Scaffold(
      body: tabs[selectedIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
