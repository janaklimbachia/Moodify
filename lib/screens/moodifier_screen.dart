import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/emotion_detector_service.dart';
import '../services/database_service.dart';
import '../services/spotify_service.dart';

class MoodifierScreen extends StatefulWidget {
  const MoodifierScreen({super.key});

  @override
  State<MoodifierScreen> createState() => _MoodifierScreenState();
}

class _MoodifierScreenState extends State<MoodifierScreen> {
  File? _image;
  String? _detectedMood;
  List<Map<String, dynamic>> _playlists = [];

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detectedMood = null;
        _playlists = [];
      });

      _analyzeMood();
    }
  }

  void _analyzeMood() async {
    setState(() {
      _detectedMood = "Analyzing...";
    });

    final mood = await EmotionDetectorService.detectMoodFromImage(_image!);

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? "anonymous";

    await DatabaseService().logMood(userId, mood);
    final fetchedPlaylists = await SpotifyService().getMoodPlaylists(mood);

    setState(() {
      _detectedMood = mood;
      _playlists = fetchedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodifier'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Capture your mood!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _image == null
                    ? const Icon(Icons.camera_alt,
                        size: 120, color: Colors.deepPurple)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, height: 200),
                      ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera),
                  label: const Text('Take a Photo'),
                ),
                const SizedBox(height: 20),
                if (_detectedMood != null)
                  Text(
                    'Mood: $_detectedMood',
                    style: const TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 20),
                if (_playlists.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spotify Playlists 🎶',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._playlists.map((playlist) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () =>
                                launchUrl(Uri.parse(playlist['url'])),
                            child: Row(
                              children: [
                                Image.network(playlist['image'], height: 50),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    playlist['name'],
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.open_in_new,
                                    color: Colors.deepPurple)
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
