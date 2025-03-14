import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../colors.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int) onToggleExerciseComplete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleExerciseComplete,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = workout['exercises'] != null
        ? List<Map<String, dynamic>>.from(workout['exercises'])
        : <Map<String, dynamic>>[];
    final allCompleted = exercises.every((e) => e['isCompleted'] == true);

    print('Building WorkoutCard with exercises: $exercises'); // Перевіряємо дані

    return Card(
      color: allCompleted
          ? AppColors.accentColor(context).withOpacity(0.2)
          : AppColors.cardColor(context), // Динамічний колір картки
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Workout on ${workout['date']} at ${workout['time']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(context), // Динамічний колір тексту
          ),
        ),
        subtitle: Text(
          'Exercises: ${exercises.length}',
          style: TextStyle(color: AppColors.secondaryTextColor(context)),
        ),
        children: exercises.isEmpty
            ? [
          ListTile(
            title: Text(
              'No exercises available',
              style: TextStyle(color: AppColors.textColor(context)),
            ),
          )
        ]
            : exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final isCompleted = exercise['isCompleted'] as bool? ?? false;

          print('Exercise $index: ${exercise['name']}, isCompleted: $isCompleted');

          return ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (value) {
                print('Checkbox changed for exercise $index to $value');
                onToggleExerciseComplete(index);
              },
              activeColor: AppColors.accentColor(context), // Динамічний колір чекбокса
            ),
            title: Text(
              '${exercise['name']} (${exercise['category'] ?? 'Other'})',
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            subtitle: Text(
              'Duration: ${exercise['duration']}s, Calories: ${exercise['caloriesPerMinute']}/min',
              style: TextStyle(color: AppColors.secondaryTextColor(context)),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.timer,
                color: AppColors.accentColor(context), // Динамічний колір іконки
              ),
              onPressed: () => _startTimer(context, exercise['duration'] as int),
            ),
          );
        }).toList(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: AppColors.accentColor(context), // Динамічний колір
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red, // Залишаємо червоний для видалення
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer(BuildContext context, int duration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor(context), // Динамічний колір фону діалогу
        title: Text(
          'Exercise Timer',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
        content: Countdown(
          seconds: duration,
          build: (context, time) => Text(
            'Time remaining: ${time.toInt()}s',
            style: TextStyle(
              fontSize: 24,
              color: AppColors.textColor(context), // Динамічний колір тексту
            ),
          ),
          onFinished: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Exercise completed!',
                  style: TextStyle(color: AppColors.textColor(context)),
                ),
                backgroundColor: AppColors.cardColor(context),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.accentColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}