import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GoalDatabase {
  static const String boxName = 'goals';
  final Box _goalsBox = Hive.box(boxName);

  Future<void> saveGoal(Map<String, dynamic> goal) async {
    try {
      await _goalsBox.add(goal);
    } catch (e) {
      print('Error saving goal: $e');
    }
  }

  List<Map<String, dynamic>> getGoals() {
    return _goalsBox.values.map((goal) {
      return Map<String, dynamic>.from(goal as Map);
    }).toList();
  }

  Future<void> deleteGoal(int index) async {
    try {
      await _goalsBox.deleteAt(index);
    } catch (e) {
      print('Error deleting goal: $e');
    }
  }
}