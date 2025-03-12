import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../cards/stat_card.dart';
import '../colors.dart';
import '../database/workout_database.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = WorkoutDatabase();
    final workouts = db.getWorkouts();

    if (workouts.isEmpty) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(title: const Text('Statistics')),
          body: const Center(child: Text('No data available')),
        ),
      );
    }

    double totalCalories = 0;
    int totalDuration = 0;
    int completedWorkouts = 0;

    for (var workout in workouts) {
      final exercises = workout['exercises'] as List<Map<String, dynamic>>;
      if (exercises.every((e) => e['isCompleted'] as bool? ?? false)) {
        completedWorkouts++;
      }
      for (var exercise in exercises) {
        if (exercise['isCompleted'] as bool? ?? false) {
          totalCalories += ((exercise['duration'] as num) / 60) * (exercise['caloriesPerMinute'] as num).toDouble();
          totalDuration += (exercise['duration'] as num).toInt();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StatCard(
              title: 'Total Workouts',
              value: workouts.length.toString(),
              icon: Icons.fitness_center,
            ),
            StatCard(
              title: 'Completed Workouts',
              value: completedWorkouts.toString(),
              icon: Icons.check_circle,
            ),
            StatCard(
              title: 'Total Duration',
              value: '${(totalDuration / 60).toStringAsFixed(1)} minutes',
              icon: Icons.timer,
            ),
            StatCard(
              title: 'Total Calories Burned',
              value: totalCalories.toStringAsFixed(1),
              icon: Icons.local_fire_department,
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildCaloriesChart(workouts)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(List<Map<String, dynamic>> workouts) {
    final Map<String, double> caloriesByDate = {};
    for (var workout in workouts) {
      final date = workout['date'] as String;
      double calories = 0;
      final exercises = workout['exercises'] as List<Map<String, dynamic>>;
      for (var exercise in exercises) {
        if (exercise['isCompleted'] as bool? ?? false) {
          calories += ((exercise['duration'] as num) / 60) * (exercise['caloriesPerMinute'] as num).toDouble();
        }
      }
      caloriesByDate[date] = (caloriesByDate[date] ?? 0) + calories;
    }

    final List<FlSpot> spots = [];
    final dates = caloriesByDate.keys.toList()..sort();
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), caloriesByDate[dates[i]]!));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Збільшуємо простір для нижніх міток
              interval: 1, // Інтервал між мітками
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Додаємо відступ зверху для міток
                    child: Text(
                      dates[index].split('.')[0], // Показуємо лише день
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Простір для лівих міток
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: accentColor,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: accentColor.withOpacity(0.3)),
          ),
        ],
        extraLinesData: ExtraLinesData(),
      ),
    );
  }
}