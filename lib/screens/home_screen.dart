import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../colors.dart'; // Переконайтеся, що файл із кольорами правильний
import 'goal_screen.dart';
import 'measurements_screen.dart';
import 'stats_screen.dart';
import 'training_plan_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true, // Дозволяє фону заходити під AppBar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70), // Збільшуємо висоту
          child: AppBar(
            toolbarHeight: 65,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                    accentColor.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            title: const Text(
              'Fitness App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 1.5,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(
              begin: -0.2,
              end: 0,
              duration: 800.ms,
              curve: Curves.easeOutCubic,
            ),
            centerTitle: true,
            elevation: 8, // Тінь для глибини
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // Закруглені нижні краї
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () {
                // Тут можна додати відкриття бокового меню
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu coming soon!')),
                );
              },
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor.withOpacity(0.9),
                backgroundColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Workouts',
                    icon: Icons.fitness_center,
                    destination: const WorkoutScreen(),
                    delay: 100.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Training Plans',
                    icon: Icons.calendar_today,
                    destination: const TrainingPlansScreen(),
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Goals',
                    icon: Icons.flag,
                    destination: const GoalsScreen(),
                    delay: 300.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Statistics',
                    icon: Icons.bar_chart,
                    destination: const StatsScreen(),
                    delay: 400.ms,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    title: 'Body Measurements',
                    icon: Icons.straighten,
                    destination: const MeasurementsScreen(),
                    delay: 500.ms,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget destination,
        required Duration delay,
      }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: accentColor.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: delay).slideY(
      begin: 0.3,
      end: 0,
      duration: 600.ms,
      delay: delay,
      curve: Curves.easeOutCubic,
    );
  }
}