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
          color: AppColors.backgroundColor(context), // Динамічний колір фону
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
      color: AppColors.cardColor(context), // Динамічний колір картки
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Plan Name',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              style: TextStyle(color: AppColors.textColor(context)), // Динамічний колір тексту
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _daysController,
              decoration: InputDecoration(
                labelText: 'Number of Days',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor(context), // Динамічний колір кнопки
                foregroundColor: Colors.white,
              ),
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
          return Center(
            child: Text(
              'No plans yet!',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textColor(context), // Динамічний колір тексту
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return ListTile(
              title: Text(
                plan['name'],
                style: TextStyle(color: AppColors.textColor(context)),
              ),
              subtitle: Text(
                'Duration: ${plan['days']} days',
                style: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[400], // Червоний для видалення
                ),
                onPressed: () => _db.deletePlan(index),
              ),
              tileColor: AppColors.cardColor(context), // Динамічний колір фону плитки
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          },
        );
      },
    );
  }

  void _addPlan() {
    if (_nameController.text.isEmpty || _daysController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields',
            style: TextStyle(color: AppColors.textColor(context)),
          ),
          backgroundColor: AppColors.cardColor(context),
        ),
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
      SnackBar(
        content: Text(
          'Plan added',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
        backgroundColor: AppColors.cardColor(context),
      ),
    );
  }
}