import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutDatabase {
  static const String boxName = 'workouts';
  final Box _workoutsBox = Hive.box(boxName);

  Future<void> saveWorkout(Map<String, dynamic> workout) async {
    try {
      final workoutCopy = Map<String, dynamic>.from(workout);
      workoutCopy['exercises'] = List<Map<String, dynamic>>.from(workout['exercises']);
      await _workoutsBox.add(workoutCopy);
      print('Workout saved to Hive: $workoutCopy');
      print('Raw data after save: ${_workoutsBox.values.toList()}');
    } catch (e) {
      print('Error saving workout: $e');
    }
  }

  List<Map<String, dynamic>> getWorkouts() {
    final workouts = _workoutsBox.values.map((workout) {
      final workoutMap = (workout as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(key.toString(), value),
      );
      if (workoutMap['exercises'] != null) {
        workoutMap['exercises'] = (workoutMap['exercises'] as List<dynamic>).map((exercise) {
          return (exercise as Map<dynamic, dynamic>).map(
                (key, value) => MapEntry(key.toString(), value),
          );
        }).toList();
      }
      print('Retrieved workout: $workoutMap');
      return workoutMap;
    }).toList();
    print('All workouts from Hive: $workouts');
    return workouts;
  }

  Future<void> deleteWorkout(int index) async {
    try {
      await _workoutsBox.deleteAt(index);
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  Future<void> updateWorkout(int index, Map<String, dynamic> updatedWorkout) async {
    try {
      await _workoutsBox.putAt(index, updatedWorkout);
    } catch (e) {
      print('Error updating workout: $e');
    }
  }
}