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
      color: allCompleted ? Colors.green.withOpacity(0.2) : cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Workout on ${workout['date']} at ${workout['time']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Exercises: ${exercises.length}'),
        children: exercises.isEmpty
            ? [const ListTile(title: Text('No exercises available'))]
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
              activeColor: accentColor,
            ),
            title: Text('${exercise['name']} (${exercise['category'] ?? 'Other'})'),
            subtitle: Text(
              'Duration: ${exercise['duration']}s, Calories: ${exercise['caloriesPerMinute']}/min',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.timer),
              onPressed: () => _startTimer(context, exercise['duration'] as int),
            ),
          );
        }).toList(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: accentColor),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
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
        title: const Text('Exercise Timer'),
        content: Countdown(
          seconds: duration,
          build: (context, time) => Text(
            'Time remaining: ${time.toInt()}s',
            style: const TextStyle(fontSize: 24),
          ),
          onFinished: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exercise completed!')),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}