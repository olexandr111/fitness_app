import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'fit_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('workouts');
  await Hive.openBox('training_plans');
  await Hive.openBox('goals');
  await Hive.openBox('measurements');
  runApp(const FitnessApp());
}