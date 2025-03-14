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
          appBar: AppBar(
            title: const Text('Statistics'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor(context), // Динамічний колір AppBar
                    AppColors.primaryColor(context).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            color: AppColors.backgroundColor(context), // Динамічний колір фону
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppColors.textColor(context)), // Динамічний колір тексту
              ),
            ),
          ),
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
          totalCalories +=
              ((exercise['duration'] as num) / 60) * (exercise['caloriesPerMinute'] as num).toDouble();
          totalDuration += (exercise['duration'] as num).toInt();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor(context), // Динамічний колір AppBar
                AppColors.primaryColor(context).withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: AppColors.backgroundColor(context), // Динамічний колір фону
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
            Expanded(child: _buildCaloriesChart(context, workouts)), // Передаємо context
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, List<Map<String, dynamic>> workouts) {
    final Map<String, double> caloriesByDate = {};
    for (var workout in workouts) {
      final date = workout['date'] as String;
      double calories = 0;
      final exercises = workout['exercises'] as List<Map<String, dynamic>>;
      for (var exercise in exercises) {
        if (exercise['isCompleted'] as bool? ?? false) {
          calories +=
              ((exercise['duration'] as num) / 60) * (exercise['caloriesPerMinute'] as num).toDouble();
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
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.secondaryTextColor(context).withOpacity(0.3), // Динамічний колір сітки
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppColors.secondaryTextColor(context).withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[index].split('.')[0],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor(context), // Динамічний колір тексту
                      ),
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
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor(context), // Динамічний колір тексту
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.secondaryTextColor(context).withOpacity(0.5), // Динамічний колір межі
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accentColor(context), // Динамічний колір лінії
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentColor(context).withOpacity(0.3), // Динамічний колір області
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(),
      ),
    );
  }
}