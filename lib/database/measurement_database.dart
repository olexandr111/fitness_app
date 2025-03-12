import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MeasurementDatabase {
  static const String boxName = 'measurements';
  final Box _measurementsBox = Hive.box(boxName);

  Future<void> saveMeasurement(Map<String, dynamic> measurement) async {
    try {
      await _measurementsBox.add(measurement);
    } catch (e) {
      print('Error saving measurement: $e');
    }
  }

  List<Map<String, dynamic>> getMeasurements() {
    return _measurementsBox.values.map((measurement) {
      return Map<String, dynamic>.from(measurement as Map);
    }).toList();
  }

  Future<void> deleteMeasurement(int index) async {
    try {
      await _measurementsBox.deleteAt(index);
    } catch (e) {
      print('Error deleting measurement: $e');
    }
  }
}