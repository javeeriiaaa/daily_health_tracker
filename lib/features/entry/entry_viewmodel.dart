import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/health_entry.dart';
import '../../../core/services/firestore_service.dart';

class EntryViewModel extends ChangeNotifier {
  final TextEditingController waterController = TextEditingController();
  final TextEditingController sleepController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  int _selectedMood = 3;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  int get selectedMood => _selectedMood;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void setMood(int mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> saveEntry() async {
    if (!_validateInputs()) return;

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Check if entry already exists for this date
      final existingEntry = await FirestoreService.getHealthEntryByDate(
        _selectedDate,
      );

      final entry = HealthEntry(
        id: existingEntry?.id ?? const Uuid().v4(),
        date: _selectedDate,
        waterIntake: double.tryParse(waterController.text) ?? 0,
        sleepHours: double.tryParse(sleepController.text) ?? 0,
        steps: int.tryParse(stepsController.text) ?? 0,
        mood: _selectedMood,
        weight: double.tryParse(weightController.text) ?? 0,
        createdAt: existingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existingEntry != null) {
        await FirestoreService.updateHealthEntry(entry);
        _successMessage = 'Entry updated successfully!';
      } else {
        await FirestoreService.addHealthEntry(entry);
        _successMessage = 'Entry saved successfully!';
      }

      _clearForm();
    } catch (e) {
      _error = 'Failed to save entry: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateInputs() {
    if (waterController.text.isEmpty ||
        sleepController.text.isEmpty ||
        stepsController.text.isEmpty ||
        weightController.text.isEmpty) {
      _error = 'Please fill in all fields';
      notifyListeners();
      return false;
    }

    final water = double.tryParse(waterController.text);
    final sleep = double.tryParse(sleepController.text);
    final steps = int.tryParse(stepsController.text);
    final weight = double.tryParse(weightController.text);

    if (water == null || water < 0) {
      _error = 'Please enter a valid water intake';
      notifyListeners();
      return false;
    }

    if (sleep == null || sleep < 0 || sleep > 24) {
      _error = 'Please enter valid sleep hours (0-24)';
      notifyListeners();
      return false;
    }

    if (steps == null || steps < 0) {
      _error = 'Please enter valid step count';
      notifyListeners();
      return false;
    }

    if (weight == null || weight <= 0) {
      _error = 'Please enter a valid weight';
      notifyListeners();
      return false;
    }

    return true;
  }

  void _clearForm() {
    waterController.clear();
    sleepController.clear();
    stepsController.clear();
    weightController.clear();
    _selectedMood = 3;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    waterController.dispose();
    sleepController.dispose();
    stepsController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
