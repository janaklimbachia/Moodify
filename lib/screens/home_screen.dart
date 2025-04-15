import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'moodbot_screen.dart';
import 'moodifier_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple.shade700,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodify'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Add Firebase signOut logic
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTile(
              context,
              icon: Icons.chat,
              label: 'Community Chat',
              screen: const ChatScreen(),
              textStyle: cardTextStyle,
            ),
            const SizedBox(height: 20),
            _buildTile(
              context,
              icon: Icons.psychology,
              label: 'moodBOT',
              screen: const MoodbotScreen(),
              textStyle: cardTextStyle,
            ),
            const SizedBox(height: 20),
            _build_
