import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../colors.dart';
import '../database/goal_database.dart';
import '../database/workout_database.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalDatabase _db = GoalDatabase();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String? _selectedType;
  final List<String> _goalTypes = ['Calories', 'Workouts'];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor(context),
                AppColors.primaryColor(context).withOpacity(0.8),
              ],
            ),
          ),
        ),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        color: AppColors.backgroundColor(context),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGoalForm(),
            const SizedBox(height: 20),
            Expanded(child: _buildGoalList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.cardColor(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Goal Type',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              items: _goalTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: 'Target Value',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addGoal,
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('goals').listenable(),
      builder: (context, Box box, _) {
        final goals = _db.getGoals();
        if (goals.isEmpty) {
          return Center(
            child: Text(
              'No goals yet!',
              style: TextStyle(fontSize: 18, color: AppColors.textColor(context)),
            ),
          );
        }
        return ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final progress = _calculateGoalProgress(goal);
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppColors.cardColor(context),
              child: ListTile(
                title: Text(
                  '${goal['name']} (${goal['type']})',
                  style: TextStyle(color: AppColors.textColor(context)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target: ${goal['target']}',
                      style: TextStyle(color: AppColors.secondaryTextColor(context)),
                    ),
                    LinearProgressIndicator(
                      value: progress,
                      color: AppColors.accentColor(context),
                      backgroundColor: AppColors.secondaryTextColor(context).withOpacity(0.3),
                    ),
                    Text(
                      'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(color: AppColors.secondaryTextColor(context)),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => _db.deleteGoal(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateGoalProgress(Map<String, dynamic> goal) {
    final workouts = WorkoutDatabase().getWorkouts();
    double progress = 0;
    if (goal['type'] == 'Calories') {
      double totalCalories = 0;
      for (var workout in workouts) {
        final exercises = (workout['exercises'] as List<dynamic>).cast<Map<String, dynamic>>();
        for (var exercise in exercises) {
          if (exercise['isCompleted'] as bool? ?? false) {
            totalCalories += ((exercise['duration'] as num) / 60) * (exercise['caloriesPerMinute'] as num).toDouble();
          }
        }
      }
      progress = totalCalories / (goal['target'] as num);
    } else if (goal['type'] == 'Workouts') {
      final completedWorkouts = workouts.where((w) {
        final exercises = (w['exercises'] as List<dynamic>).cast<Map<String, dynamic>>();
        return exercises.every((e) => e['isCompleted'] as bool? ?? false);
      }).length;
      progress = completedWorkouts / (goal['target'] as num);
    }
    return progress.clamp(0, 1);
  }

  void _addGoal() {
    if (_nameController.text.isEmpty || _targetController.text.isEmpty || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final goal = {
      'name': _nameController.text,
      'type': _selectedType,
      'target': double.parse(_targetController.text),
    };

    _db.saveGoal(goal);
    _nameController.clear();
    _targetController.clear();
    setState(() => _selectedType = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal added')),
    );
  }
}