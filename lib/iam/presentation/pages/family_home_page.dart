import 'package:flutter/material.dart';

import '../../../profiles/domain/entities/person_profile.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import 'login_page.dart';

class FamilyHomePage extends StatelessWidget {
  final PersonProfile? profile;

  const FamilyHomePage({super.key, this.profile});

  void _signOut(BuildContext context) {
    TokenManager.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Family Portal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.family_restroom,
                size: 80,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Veyra',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                profile == null
                    ? 'Your family account is ready. Resident information will appear here once it is linked from the web platform.'
                    : 'Profile created for ${profile!.fullName}. Resident information will appear here once it is linked from the web platform.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              if (profile != null) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 1,
                  child: ListTile(
                    leading: const Icon(Icons.assignment_ind),
                    title: Text(profile!.fullName),
                    subtitle: Text('DNI: ${profile!.dni}'),
                    trailing: Text('#${profile!.id}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
