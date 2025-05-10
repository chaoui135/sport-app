// lib/models/goal.dart
import 'package:fitvista/models/progress_entry.dart';
import 'package:fitvista/pages/goal_type.dart';

class Goal {
  final String id;
  final GoalType type;
  final String title;
  final double target;
  final double progress;
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, ProgressEntry> dailyProgress; // Une Map pour gérer les dates et les ProgressEntry.

  Goal({
    required this.id,
    required this.type,
    required this.title,
    required this.target,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.dailyProgress,
  });

  double get percentage => progress / target;
}
