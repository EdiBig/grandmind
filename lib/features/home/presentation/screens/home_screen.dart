import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_tab.dart';
import 'workouts_tab.dart';
import 'habits_tab.dart';
import 'progress_tab.dart';
import '../../../nutrition/presentation/screens/nutrition_tab.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final List<Widget> tabs = [
      const DashboardTab(),
      const WorkoutsTab(),
      const HabitsTab(),
      const ProgressTab(),
      const NutritionTab(),
    ];

    return Scaffold(
      body: tabs[selectedIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
