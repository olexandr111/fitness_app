import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TrainingPlanDatabase {
  static const String boxName = 'training_plans';
  final Box _plansBox = Hive.box(boxName);

  Future<void> savePlan(Map<String, dynamic> plan) async {
    try {
      await _plansBox.add(plan);
    } catch (e) {
      print('Error saving plan: $e');
    }
  }

  List<Map<String, dynamic>> getPlans() {
    return _plansBox.values.map((plan) {
      return Map<String, dynamic>.from(plan as Map);
    }).toList();
  }

  Future<void> deletePlan(int index) async {
    try {
      await _plansBox.deleteAt(index);
    } catch (e) {
      print('Error deleting plan: $e');
    }
  }
}