import 'package:flutter/material.dart';
import '../../../core/models/health_entry.dart';
import '../../../core/services/firestore_service.dart';

class DashboardViewModel extends ChangeNotifier {
  HealthEntry? _todayEntry;
  List<HealthEntry> _weeklyEntries = [];
  bool _isLoading = false;
  String? _error;

  HealthEntry? get todayEntry => _todayEntry;
  List<HealthEntry> get weeklyEntries => _weeklyEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardViewModel() {
    loadTodayEntry();
    loadWeeklyEntries();
  }

  Future<void> loadTodayEntry() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      _todayEntry = await FirestoreService.getHealthEntryByDate(today);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyEntries() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      FirestoreService.getHealthEntriesInRange(weekStart, weekEnd).listen((
        entries,
      ) {
        _weeklyEntries = entries;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  double get weeklyWaterAverage {
    if (_weeklyEntries.isEmpty) return 0;
    final total = _weeklyEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.waterIntake,
    );
    return total / _weeklyEntries.length;
  }

  double get weeklySleepAverage {
    if (_weeklyEntries.isEmpty) return 0;
    final total = _weeklyEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.sleepHours,
    );
    return total / _weeklyEntries.length;
  }

  double get weeklyStepsAverage {
    if (_weeklyEntries.isEmpty) return 0;
    final total = _weeklyEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.steps.toDouble(),
    );
    return total / _weeklyEntries.length;
  }

  void refresh() {
    loadTodayEntry();
    loadWeeklyEntries();
  }
}
