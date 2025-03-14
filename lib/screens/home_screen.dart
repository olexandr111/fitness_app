import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../colors.dart';
import '../theme_provider.dart';
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
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
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
            elevation: 8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
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
                icon: Icon(
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  size: 28,
                ),
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
              ),
              const SizedBox(width: 8),
            ],
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu coming soon!')),
                );
              },
            ),
          ),
        ),
        body: Container(
          color: AppColors.backgroundColor(context),
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: SingleChildScrollView(
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.cardColor(context),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentColor(context), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor(context),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accentColor(context),
                size: 18,
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
