import 'package:daily_health_tracker/features/dashboard/dashboard_viewmodel.dart';
import 'package:daily_health_tracker/features/dashboard/widgets/health_metric_card.dart';
import 'package:daily_health_tracker/features/dashboard/widgets/weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardViewModel>().refresh(),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => viewModel.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context),
                  const SizedBox(height: 24),
                  _buildTodaySection(context, viewModel),
                  const SizedBox(height: 24),
                  _buildWeeklySection(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF8B7CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'How are you feeling today?',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    final todayEntry = viewModel.todayEntry;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (todayEntry == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No entry for today',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the Add Entry tab to log your health metrics',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              HealthMetricCard(
                title: 'Water',
                value: '${todayEntry.waterIntake.toInt()}ml',
                icon: Icons.water_drop,
                color: Colors.blue,
                progress: todayEntry.waterIntake / 2000,
              ),
              HealthMetricCard(
                title: 'Sleep',
                value: '${todayEntry.sleepHours.toStringAsFixed(1)}h',
                icon: Icons.bedtime,
                color: Colors.purple,
                progress: todayEntry.sleepHours / 8,
              ),
              HealthMetricCard(
                title: 'Steps',
                value: '${todayEntry.steps}',
                icon: Icons.directions_walk,
                color: Colors.green,
                progress: todayEntry.steps / 10000,
              ),
              HealthMetricCard(
                title: 'Mood',
                value: _getMoodEmoji(todayEntry.mood),
                icon: Icons.mood,
                color: Colors.orange,
                progress: todayEntry.mood / 5,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildWeeklySection(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Trends',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        WeeklyChart(entries: viewModel.weeklyEntries),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAverageCard(
                context,
                'Avg Water',
                '${viewModel.weeklyWaterAverage.toInt()}ml',
                Icons.water_drop,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAverageCard(
                context,
                'Avg Sleep',
                '${viewModel.weeklySleepAverage.toStringAsFixed(1)}h',
                Icons.bedtime,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAverageCard(
                context,
                'Avg Steps',
                '${viewModel.weeklyStepsAverage.toInt()}',
                Icons.directions_walk,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAverageCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}
