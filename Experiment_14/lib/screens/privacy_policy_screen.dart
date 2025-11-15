import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "We respect your privacy. Your data is stored securely and will never be shared with third parties.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
