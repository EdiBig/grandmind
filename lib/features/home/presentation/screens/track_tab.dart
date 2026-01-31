import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_tab.dart';
import '../../../nutrition/presentation/screens/nutrition_tab.dart';

/// Combined tracking tab that holds Habits and Nutrition sub-tabs.
/// This reduces the bottom navigation from 6 to 5 items for better UX.
class TrackTab extends ConsumerStatefulWidget {
  const TrackTab({super.key});

  @override
  ConsumerState<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends ConsumerState<TrackTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(
              icon: Icon(Icons.check_circle_outline),
              text: 'Habits',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Nutrition',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HabitsTabContent(),
          NutritionTabContent(),
        ],
      ),
    );
  }
}
