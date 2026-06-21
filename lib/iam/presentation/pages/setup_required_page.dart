import 'package:flutter/material.dart';

import '../../../shared/infrastructure/local/token_manager.dart';
import 'login_page.dart';

/// Informational page displayed when an authenticated user
/// has not yet completed the initial nursing home setup.
///
/// This page blocks access to operational features until the
/// organization has been configured through the web platform.
///
/// Responsibilities:
/// - Inform the user that setup is still pending.
/// - Explain the required onboarding process.
/// - Provide a secure sign-out mechanism.
/// - Clear the active session before returning to the login page.
class SetupRequiredPage extends StatelessWidget {
  /// Creates a new [SetupRequiredPage].
  const SetupRequiredPage({super.key});

  /// Performs a secure logout operation.
  ///
  /// This method:
  /// 1. Removes the stored authentication token.
  /// 2. Clears the entire navigation stack.
  /// 3. Redirects the user to the [LoginPage].
  ///
  /// This guarantees that protected screens cannot be
  /// accessed again through back navigation.
  void _performLogout(BuildContext context) {
    /// Clears the authentication token from local storage.
    TokenManager.clear();

    debugPrint(
      '[Auth] User session terminated. Authentication token removed.',
    );

    /// Navigates to the login page while removing all
    /// previous routes from the navigation stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
          (Route<dynamic> route) => false,
    );
  }

  /// Builds the setup-required screen.
  ///
  /// The page displays:
  /// - A setup illustration.
  /// - An onboarding explanation.
  /// - A sign-out action.
  ///
  /// Users are instructed to complete the nursing home
  /// registration process through the web platform before
  /// accessing mobile application features.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /// Page title displayed in the application bar.
        title: const Text('Setup Required'),

        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Visual indicator representing desktop/web setup.
              Icon(
                Icons.laptop_chromebook,
                size: 80,
                color: Colors.teal.shade200,
              ),

              const SizedBox(height: 24),

              /// Welcome message shown to newly authenticated users.
              const Text(
                'Welcome to Veyra Mobile App!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// Explains why access is currently restricted
              /// and provides onboarding instructions.
              const Text(
                'Your nursing home has not been configured yet.\n\n'
                    'Please access the web platform from a desktop computer '
                    'to register your facility, staff members, and residents '
                    'before using the mobile application.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              /// Sign-out button.
              ///
              /// Clears the current session and returns
              /// the user to the authentication screen.
              ElevatedButton.icon(
                onPressed: () => _performLogout(context),

                icon: const Icon(
                  Icons.logout,
                ),

                label: const Text(
                  'Sign Out',
                ),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
