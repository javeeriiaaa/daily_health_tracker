import 'package:daily_health_tracker/features/history/history_viewmodel.dart';
import 'package:daily_health_tracker/features/history/widgets/history_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'filter':
                      await _showDateRangePicker(context, viewModel);
                      break;
                    case 'clear':
                      viewModel.clearFilter();
                      break;
                    case 'refresh':
                      viewModel.refresh();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 8),
                        Text('Filter by Date'),
                      ],
                    ),
                  ),
                  if (viewModel.selectedDateRange != null)
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear),
                          SizedBox(width: 8),
                          Text('Clear Filter'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
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

          if (viewModel.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.selectedDateRange != null
                        ? 'No entries found for selected date range'
                        : 'No health entries yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.selectedDateRange != null
                        ? 'Try adjusting your date filter'
                        : 'Start tracking your health by adding your first entry',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (viewModel.selectedDateRange != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filtered: ${DateFormat('MMM d, y').format(viewModel.selectedDateRange!.start)} - ${DateFormat('MMM d, y').format(viewModel.selectedDateRange!.end)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: viewModel.clearFilter,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => viewModel.refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.entries.length,
                    itemBuilder: (context, index) {
                      final entry = viewModel.entries[index];
                      return HistoryEntryCard(
                        entry: entry,
                        onDelete: () =>
                            _showDeleteDialog(context, viewModel, entry.id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    HistoryViewModel viewModel,
  ) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: viewModel.selectedDateRange,
    );

    if (dateRange != null) {
      viewModel.setDateRange(dateRange);
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    HistoryViewModel viewModel,
    String entryId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this health entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.deleteEntry(entryId);
    }
  }
}
