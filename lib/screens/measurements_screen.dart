import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../colors.dart';
import '../database/measurement_database.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  _MeasurementsScreenState createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final MeasurementDatabase db = MeasurementDatabase();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Body Measurements'),
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
              _buildMeasurementForm(),
              const SizedBox(height: 20),
              Expanded(child: _buildMeasurementList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementForm() {
    return Card(
      color: AppColors.cardColor(context),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _waistController,
              decoration: InputDecoration(
                labelText: 'Waist (cm)',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hipsController,
              decoration: InputDecoration(
                labelText: 'Hips (cm)',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(
                text: _selectedDate != null
                    ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
                    : '',
              ),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Select Date',
                labelStyle: TextStyle(color: AppColors.secondaryTextColor(context)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColors.accentColor(context)),
                  onPressed: _pickDate,
                ),
              ),
              style: TextStyle(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMeasurement,
              child: const Text('Add Measurement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('measurements').listenable(),
      builder: (context, Box box, _) {
        final measurements = db.getMeasurements();
        if (measurements.isEmpty) {
          return Center(
            child: Text(
              'No measurements yet!',
              style: TextStyle(fontSize: 18, color: AppColors.textColor(context)),
            ),
          );
        }
        return Column(
          children: [
            Expanded(child: _buildWeightChart(measurements)),
            Expanded(
              child: ListView.builder(
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return ListTile(
                    title: Text(
                      'Date: ${measurement['date']}',
                      style: TextStyle(color: AppColors.textColor(context)),
                    ),
                    subtitle: Text(
                      'Weight: ${measurement['weight']} kg, Waist: ${measurement['waist']} cm, Hips: ${measurement['hips']} cm',
                      style: TextStyle(color: AppColors.secondaryTextColor(context)),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[400]),
                      onPressed: () => db.deleteMeasurement(index),
                    ),
                    tileColor: AppColors.cardColor(context),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeightChart(List<Map<String, dynamic>> measurements) {
    final List<FlSpot> spots = [];
    final dates = measurements.map((m) => m['date'] as String).toList()..sort();
    for (int i = 0; i < dates.length; i++) {
      final measurement = measurements.firstWhere((m) => m['date'] == dates[i]);
      spots.add(FlSpot(i.toDouble(), measurement['weight'] as double));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.secondaryTextColor(context).withOpacity(0.3),
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Text(
                    dates[index].split('.')[0], // Показуємо лише день
                    style: TextStyle(color: AppColors.textColor(context), fontSize: 12),
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
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(color: AppColors.textColor(context), fontSize: 12),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.secondaryTextColor(context).withOpacity(0.5)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accentColor(context),
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentColor(context).withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

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

  void _addMeasurement() {
    if (_weightController.text.isEmpty ||
        _waistController.text.isEmpty ||
        _hipsController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final measurement = {
      'weight': double.parse(_weightController.text),
      'waist': double.parse(_waistController.text),
      'hips': double.parse(_hipsController.text),
      'date': DateFormat('dd.MM.yyyy').format(_selectedDate!),
    };

    db.saveMeasurement(measurement);
    _weightController.clear();
    _waistController.clear();
    _hipsController.clear();
    setState(() => _selectedDate = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurement added')),
    );
  }
}