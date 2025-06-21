import 'package:flutter/material.dart';
import '../../../core/models/health_entry.dart';
import '../../../core/services/firestore_service.dart';

class HistoryViewModel extends ChangeNotifier {
  List<HealthEntry> _entries = [];
  List<HealthEntry> _filteredEntries = [];
  bool _isLoading = false;
  String? _error;
  DateTimeRange? _selectedDateRange;

  List<HealthEntry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  HistoryViewModel() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FirestoreService.getHealthEntries().listen((entries) {
        _entries = entries;
        _applyFilter();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    _applyFilter();
  }

  void clearFilter() {
    _selectedDateRange = null;
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedDateRange == null) {
      _filteredEntries = List.from(_entries);
    } else {
      _filteredEntries = _entries.where((entry) {
        return entry.date.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            entry.date.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    try {
      await FirestoreService.deleteHealthEntry(id);
    } catch (e) {
      _error = 'Failed to delete entry: ${e.toString()}';
      notifyListeners();
    }
  }

  void refresh() {
    loadEntries();
  }
}
