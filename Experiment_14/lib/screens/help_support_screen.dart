import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Need help?\n\nContact us at support@wanderlist.app",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
