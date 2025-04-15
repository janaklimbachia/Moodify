import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = FirebaseDatabase.instance.ref();
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  List<Map<String, String>> _moodLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodHistory();
  }

  void _fetchMoodHistory() async {
    final snapshot = await _db.child("moodHistory/$_userId").get();

    final List<Map<String, String>> logs = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        logs.add({
          'mood': value['mood'] ?? 'Unknown',
          'timestamp': value['timestamp'] ?? '',
        });
      });
    }

    logs.sort((a, b) => b['timestamp']!.compareTo(a['timestamp']!));

    setState(() {
      _moodLogs = logs;
      _loading = false;
    });
  }

  String _formatTime(String isoTime) {
    final dt = DateTime.parse(isoTime);
    return DateFormat.yMMMMd().add_jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood History"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _moodLogs.isEmpty
              ? const Center(child: Text("No mood history yet"))
              : ListView.builder(
                  itemCount: _moodLogs.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final entry = _moodLogs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mood, color: Colors.deepPurple),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['mood']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatTime(entry['timestamp']!),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
