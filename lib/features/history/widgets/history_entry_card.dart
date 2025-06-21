import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/health_entry.dart';

class HistoryEntryCard extends StatelessWidget {
  final HealthEntry entry;
  final VoidCallback onDelete;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(entry.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    Icons.water_drop,
                    'Water',
                    '${entry.waterIntake.toInt()}ml',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    Icons.bedtime,
                    'Sleep',
                    '${entry.sleepHours.toStringAsFixed(1)}h',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    Icons.directions_walk,
                    'Steps',
                    '${entry.steps}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    Icons.mood,
                    'Mood',
                    _getMoodEmoji(entry.mood),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricItem(
              context,
              Icons.monitor_weight,
              'Weight',
              '${entry.weight.toStringAsFixed(1)}kg',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
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
