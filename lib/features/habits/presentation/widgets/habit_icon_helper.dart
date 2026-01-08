import 'package:flutter/material.dart';
import '../../domain/models/habit.dart';

class HabitIconHelper {
  /// Get Flutter IconData from HabitIcon enum
  static IconData getIconData(HabitIcon habitIcon) {
    switch (habitIcon) {
      case HabitIcon.water:
        return Icons.local_drink;
      case HabitIcon.sleep:
        return Icons.bedtime;
      case HabitIcon.meditation:
        return Icons.self_improvement;
      case HabitIcon.walk:
        return Icons.directions_walk;
      case HabitIcon.read:
        return Icons.menu_book;
      case HabitIcon.exercise:
        return Icons.fitness_center;
      case HabitIcon.food:
        return Icons.restaurant;
      case HabitIcon.pill:
        return Icons.medication;
      case HabitIcon.study:
        return Icons.school;
      case HabitIcon.clean:
        return Icons.cleaning_services;
      case HabitIcon.other:
        return Icons.check_circle_outline;
    }
  }

  /// Get Color from HabitColor enum
  static Color getColor(HabitColor habitColor) {
    switch (habitColor) {
      case HabitColor.blue:
        return Colors.blue;
      case HabitColor.purple:
        return Colors.deepPurple;
      case HabitColor.pink:
        return Colors.pink;
      case HabitColor.red:
        return Colors.red;
      case HabitColor.orange:
        return Colors.orange;
      case HabitColor.yellow:
        return Colors.amber;
      case HabitColor.green:
        return Colors.green;
      case HabitColor.teal:
        return Colors.teal;
    }
  }
}
