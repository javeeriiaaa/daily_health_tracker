import 'package:daily_health_tracker/features/settings/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationSection(context, viewModel),
                const SizedBox(height: 24),
                _buildAboutSection(context),
                if (viewModel.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(context, viewModel),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Daily Reminders'),
                subtitle: const Text('Get reminded to log your health data'),
                value: viewModel.notificationsEnabled,
                onChanged: viewModel.setNotificationsEnabled,
                secondary: const Icon(Icons.notifications),
              ),
              if (viewModel.notificationsEnabled) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(viewModel.reminderTime.format(context)),
                  leading: const Icon(Icons.schedule),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showTimePicker(context, viewModel),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Contact Support'),
                leading: const Icon(Icons.support),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Open contact support
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, SettingsViewModel viewModel) {
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
              viewModel.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: viewModel.clearError,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: viewModel.reminderTime,
    );

    if (time != null) {
      await viewModel.setReminderTime(time);
    }
  }
}
