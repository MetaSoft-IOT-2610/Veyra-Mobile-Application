import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../../../profiles/presentation/pages/create_person_profile_page.dart';
import '../../../shared/presentation/pages/admin_main_layout_page.dart';
import '../bloc/auth_bloc.dart';
import 'sign_up_page.dart';
import 'setup_required_page.dart';

/// Authentication page responsible for handling user login.
///
/// This page serves as the entry point to the application and
/// allows users to authenticate using their credentials.
///
/// Responsibilities:
/// - Capture user credentials.
/// - Dispatch authentication requests through [AuthBloc].
/// - Display loading and error states.
/// - Redirect authenticated users to the appropriate dashboard.
/// - Provide a simple and secure login experience.
class LoginPage extends StatelessWidget {
  /// Creates a new [LoginPage].
  LoginPage({Key? key}) : super(key: key);

  /// Controller used to capture the username input.
  final TextEditingController _usernameController = TextEditingController();

  /// Controller used to capture the password input.
  final TextEditingController _passwordController = TextEditingController();

  /// Builds the login page and provides the [AuthBloc]
  /// through dependency injection.
  ///
  /// State Handling:
  /// - [AuthLoading]: Displays a loading indicator and disables login.
  /// - [AuthError]: Displays an error message or redirects to Setup.
  /// - [AuthSuccess]: Navigates to the dashboard.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      /// Injects the authentication BLoC from the service locator.
      create: (_) => locator<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),

            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(32.0),

                child: BlocConsumer<AuthBloc, AuthState>(
                  /// Handles side effects such as navigation
                  /// and displaying error messages.
                  listener: (context, state) {
                    /// Authentication failed.
                    if (state is AuthError) {
                      // Ocultamos cualquier mensaje previo
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      // FIX: Verificamos si es el error de "Base de datos vacía / Sin Casa de Reposo"
                      if (state.message.contains(
                            'Requiere configuración inicial',
                          ) ||
                          state.message.contains('404')) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SetupRequiredPage(),
                          ),
                        );
                      }
                      // Si es un error normal (contraseña incorrecta, sin internet, etc.)
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                    /// Authentication succeeded.
                    ///
                    /// Redirects the user to the nursing home's
                    /// administrative dashboard using the identifier
                    /// returned by the authentication process.
                    else if (state is AuthSuccess) {
                      if (state.session.isFamily) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => CreatePersonProfilePage(),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AdminMainLayoutPage(
                            nursingHomeId: state.session.nursingHomeId!,
                          ),
                        ),
                      );
                    }
                  },

                  /// Rebuilds the UI whenever the authentication
                  /// state changes.
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Application logo/icon.
                        const Icon(
                          Icons.health_and_safety,
                          size: 80,
                          color: Colors.blue,
                        ),

                        const SizedBox(height: 16),

                        /// Application title.
                        const Text(
                          'Veyra Mobile App',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Username input field.
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Password input field.
                        ///
                        /// Characters are hidden to
                        /// improve security.
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// Login button.
                        ///
                        /// Disabled while authentication
                        /// is in progress.
                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    /// Hides the
                                    /// keyboard before
                                    /// processing login.
                                    FocusScope.of(context).unfocus();

                                    /// Dispatches the
                                    /// login request.
                                    context.read<AuthBloc>().add(
                                      PerformLoginEvent(
                                        _usernameController.text,
                                        _passwordController.text,
                                      ),
                                    );
                                  },

                            /// Displays a loading indicator
                            /// while authentication is running.
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SignUpPage(),
                                    ),
                                  );
                                },
                          child: const Text('Create a new account'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
