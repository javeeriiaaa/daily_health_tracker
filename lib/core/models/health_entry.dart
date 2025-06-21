import 'package:cloud_firestore/cloud_firestore.dart';

class HealthEntry {
  final String id;
  final DateTime date;
  final double waterIntake; // in ml
  final double sleepHours;
  final int steps;
  final int mood; // 1-5 scale
  final double weight; // in kg
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthEntry({
    required this.id,
    required this.date,
    required this.waterIntake,
    required this.sleepHours,
    required this.steps,
    required this.mood,
    required this.weight,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthEntry(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      waterIntake: (data['waterIntake'] ?? 0.0).toDouble(),
      sleepHours: (data['sleepHours'] ?? 0.0).toDouble(),
      steps: data['steps'] ?? 0,
      mood: data['mood'] ?? 3,
      weight: (data['weight'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'waterIntake': waterIntake,
      'sleepHours': sleepHours,
      'steps': steps,
      'mood': mood,
      'weight': weight,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HealthEntry copyWith({
    String? id,
    DateTime? date,
    double? waterIntake,
    double? sleepHours,
    int? steps,
    int? mood,
    double? weight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
      mood: mood ?? this.mood,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
