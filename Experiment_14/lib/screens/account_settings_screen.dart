import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text("Delete Account"),
          ),
        ],
      ),
    );
  }
}
