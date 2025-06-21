import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_entry.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'health_entries';

  static Future<void> addHealthEntry(HealthEntry entry) async {
    await _firestore.collection(_collection).add(entry.toFirestore());
  }

  static Future<void> updateHealthEntry(HealthEntry entry) async {
    await _firestore
        .collection(_collection)
        .doc(entry.id)
        .update(entry.toFirestore());
  }

  static Future<void> deleteHealthEntry(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  static Stream<List<HealthEntry>> getHealthEntries() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthEntry.fromFirestore(doc))
              .toList(),
        );
  }

  static Future<HealthEntry?> getHealthEntryByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return HealthEntry.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  static Stream<List<HealthEntry>> getHealthEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthEntry.fromFirestore(doc))
              .toList(),
        );
  }
}
