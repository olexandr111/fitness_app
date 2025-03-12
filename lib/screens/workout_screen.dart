import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../cards/workout_card.dart';
import '../colors.dart';
import '../database/workout_database.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final WorkoutDatabase _db = WorkoutDatabase();
  List<Map<String, dynamic>> _exercises =
      []; // Список вправ для нового тренування
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  final List<String> _categories = [
    'Cardio',
    'Strength',
    'Stretching',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildForm(),
              const SizedBox(height: 20),
              Expanded(child: _buildWorkoutList()),
            ],
          ),
        ),
      ),
    );
  }

  // Форма для введення даних
  bool _isFormExpanded = false; // Стан форми (згорнута/розгорнута)

  Widget _buildForm() {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          width: 220,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isFormExpanded = !_isFormExpanded; // Змінюємо стан форми
              });
            },
            child: Text(
              _isFormExpanded ? 'Hide' : ' + Add Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(), // Порожній віджет, коли форма прихована
          secondChild: Card(
            color: cardColor,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Exercise Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    decoration:
                        const InputDecoration(labelText: 'Duration (seconds)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _caloriesController,
                    decoration:
                        const InputDecoration(labelText: 'Calories per Minute'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDatePicker(),
                  const SizedBox(height: 10),
                  _buildTimePicker(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addExerciseToWorkout,
                    child: const Text('Add Exercise to Workout'),
                  ),
                  const SizedBox(height: 10),
                  if (_exercises.isNotEmpty)
                    Text('Exercises in Workout: ${_exercises.length}',
                        style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _exercises.isNotEmpty ? _addWorkout : null,
                    child: const Text('Save Workout'),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(),
          crossFadeState: _isFormExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  // Вибір дати
  Widget _buildDatePicker() {
    return TextField(
      controller: TextEditingController(
        text: _selectedDate != null
            ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
            : '',
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Date',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onPressed: _pickDate,
        ),
      ),
    );
  }

  // Вибір часу
  Widget _buildTimePicker() {
    return TextField(
      controller: TextEditingController(
        text: _selectedTime != null ? _selectedTime!.format(context) : '',
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Time',
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time, color: Colors.white),
          onPressed: _pickTime,
        ),
      ),
    );
  }

  // Список тренувань
  Widget _buildWorkoutList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('workouts').listenable(),
      builder: (context, Box box, _) {
        final workouts = _db.getWorkouts();
        if (workouts.isEmpty) {
          return const Center(
            child: Text('No workouts yet!', style: TextStyle(fontSize: 18)),
          );
        }
        return ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return WorkoutCard(
              workout: workout,
              onEdit: () => _editWorkout(workout, index),
              onDelete: () => _deleteWorkout(index),
              onToggleExerciseComplete: (exerciseIndex) =>
                  _toggleComplete(index, exerciseIndex),
            ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms);
          },
        );
      },
    );
  }

  // Вибір дати
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  // Вибір часу
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  // Додавання вправи до тренування
  void _addExerciseToWorkout() {
    if (!_validateInput()) return;

    final exercise = {
      'name': _nameController.text,
      'duration': int.parse(_durationController.text),
      'caloriesPerMinute': double.parse(_caloriesController.text),
      'category': _selectedCategory ?? 'Other',
      'isCompleted': false,
    };

    setState(() {
      _exercises.add(exercise);
    });

    _nameController.clear();
    _durationController.clear();
    _caloriesController.clear();
    _selectedCategory = null;
  }

  // Додавання тренування
  void _addWorkout() {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    final workout = {
      'exercises': _exercises,
      'date': _selectedDate != null
          ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
          : 'No date selected',
      'time': _selectedTime != null
          ? _selectedTime!.format(context)
          : 'No time selected',
    };

    print('Saving workout: $workout');

    _db.saveWorkout(workout);
    _clearForm();
    setState(() {
      _exercises.clear();
      print('Exercises cleared after save');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout added')),
    );
  }

  // Редагування тренування
  void _editWorkout(Map<String, dynamic> workout, int index) async {
    setState(() {
      _exercises.clear();
      _exercises.addAll(List<Map<String, dynamic>>.from(workout['exercises']));
      _selectedDate = DateFormat('dd.MM.yyyy').parse(workout['date']);
      _selectedTime = TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(workout['time']),
      );
    });

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workout'),
        content: SingleChildScrollView(child: _buildForm()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addWorkout();
              _db.deleteWorkout(index); // Видаляємо старе тренування
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Видалення тренування
  void _deleteWorkout(int index) {
    _db.deleteWorkout(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout deleted')),
    );
  }

  // Позначити вправу як виконану/невиконану

  void _toggleComplete(int workoutIndex, int exerciseIndex) {
    final workouts = _db.getWorkouts();
    if (workoutIndex >= 0 && workoutIndex < workouts.length) {
      final workout = workouts[workoutIndex];
      final exercises = List<Map<String, dynamic>>.from(workout['exercises']);
      if (exerciseIndex >= 0 && exerciseIndex < exercises.length) {
        exercises[exerciseIndex]['isCompleted'] =
            !(exercises[exerciseIndex]['isCompleted'] ?? false);
        workout['exercises'] = exercises;
        _db.updateWorkout(workoutIndex, workout);
        setState(() {}); // Оновлюємо UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Exercise marked as ${exercises[exerciseIndex]['isCompleted'] ? 'completed' : 'incomplete'}')),
        );
      }
    }
  }

  // Валідація введених даних
  bool _validateInput() {
    if (_nameController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _caloriesController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }
    try {
      int.parse(_durationController.text);
      double.parse(_caloriesController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid number format')),
      );
      return false;
    }
    return true;
  }

  // Очищення форми
  void _clearForm() {
    _nameController.clear();
    _durationController.clear();
    _caloriesController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = null;
    });
  }
}
