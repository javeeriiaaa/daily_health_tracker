import 'package:daily_health_tracker/features/entry/entry_viewmodel.dart';
import 'package:daily_health_tracker/features/entry/widgets/metric_input_field.dart';
import 'package:daily_health_tracker/features/entry/widgets/mood_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Add Health Entry')),
      body: Consumer<EntryViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(context, viewModel),
                const SizedBox(height: 24),
                _buildMetricsSection(context, viewModel),
                const SizedBox(height: 24),
                _buildMoodSection(context, viewModel),
                const SizedBox(height: 32),
                _buildSaveButton(context, viewModel),
                if (viewModel.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(context, viewModel.error!),
                ],
                if (viewModel.successMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildSuccessMessage(context, viewModel.successMessage!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, EntryViewModel viewModel) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Date'),
        subtitle: Text(
          DateFormat('EEEE, MMMM d, y').format(viewModel.selectedDate),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: viewModel.selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            viewModel.setDate(date);
          }
        },
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, EntryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        MetricInputField(
          controller: viewModel.waterController,
          label: 'Water Intake',
          suffix: 'ml',
          icon: Icons.water_drop,
          color: Colors.blue,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        MetricInputField(
          controller: viewModel.sleepController,
          label: 'Sleep Hours',
          suffix: 'hours',
          icon: Icons.bedtime,
          color: Colors.purple,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
        MetricInputField(
          controller: viewModel.stepsController,
          label: 'Steps',
          suffix: 'steps',
          icon: Icons.directions_walk,
          color: Colors.green,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        MetricInputField(
          controller: viewModel.weightController,
          label: 'Weight',
          suffix: 'kg',
          icon: Icons.monitor_weight,
          color: Colors.orange,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildMoodSection(BuildContext context, EntryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        MoodSelector(
          selectedMood: viewModel.selectedMood,
          onMoodSelected: viewModel.setMood,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, EntryViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () {
                viewModel.clearMessages();
                viewModel.saveEntry();
              },
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Entry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
