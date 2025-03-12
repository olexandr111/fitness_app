import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../colors.dart';
import '../database/training_plan_database.dart';

class TrainingPlansScreen extends StatefulWidget {
  const TrainingPlansScreen({super.key});

  @override
  _TrainingPlansScreenState createState() => _TrainingPlansScreenState();
}

class _TrainingPlansScreenState extends State<TrainingPlansScreen> {
  final TrainingPlanDatabase _db = TrainingPlanDatabase();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Training Plans'),

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPlanForm(),
              const SizedBox(height: 20),
              Expanded(child: _buildPlanList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanForm() {
    return Card(
      color: cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Plan Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _daysController,
              decoration: const InputDecoration(labelText: 'Number of Days'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPlan,
              child: const Text('Add Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('training_plans').listenable(),
      builder: (context, Box box, _) {
        final plans = _db.getPlans();
        if (plans.isEmpty) {
          return const Center(
            child: Text('No plans yet!', style: TextStyle(fontSize: 18)),
          );
        }
        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return ListTile(
              title: Text(plan['name']),
              subtitle: Text('Duration: ${plan['days']} days'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _db.deletePlan(index),
              ),
            );
          },
        );
      },
    );
  }

  void _addPlan() {
    if (_nameController.text.isEmpty || _daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final plan = {
      'name': _nameController.text,
      'days': int.parse(_daysController.text),
      'progress': 0, // Прогрес плану
    };

    _db.savePlan(plan);
    _nameController.clear();
    _daysController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan added')),
    );
  }
}