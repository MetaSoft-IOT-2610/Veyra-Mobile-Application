import 'package:flutter/material.dart';

import '../../../iam/presentation/pages/login_page.dart';
import '../../infrastructure/local/token_manager.dart';

class SetupRequiredPage extends StatelessWidget {
  const SetupRequiredPage({super.key});

  void _performLogout(BuildContext context) {
    TokenManager.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Required'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.laptop_chromebook,
                size: 80,
                color: Colors.teal.shade200,
              ),
              const SizedBox(height: 24),
              const Text(
                'Configuration required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This account is not fully configured yet. Complete the '
                'required setup on the web platform before using the mobile '
                'application.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _performLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
