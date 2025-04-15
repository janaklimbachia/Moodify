import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> logMood(String userId, String mood) async {
    final timestamp = DateTime.now().toIso8601String();

    await _db.child("moodHistory/$userId").push().set({
      'mood': mood,
      'timestamp': timestamp,
    });
  }
}
