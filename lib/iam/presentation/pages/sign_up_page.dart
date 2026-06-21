import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../nursing/presentation/pages/create_nursing_home_page.dart';
import '../bloc/auth_bloc.dart';
import 'login_page.dart';

enum SignUpRole { family, administrator }

/// Page used to register a new account based on the selected user role.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  SignUpRole _selectedRole = SignUpRole.family;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Create Account'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    if (state is AuthSignUpSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Account created. You can sign in now.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    }

                    if (state is AuthAdministratorSignUpSuccess) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => CreateNursingHomePage(
                            administratorId: state.administratorId,
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    final isFamily = _selectedRole == SignUpRole.family;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFamily
                              ? Icons.family_restroom
                              : Icons.admin_panel_settings,
                          size: 72,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isFamily
                              ? 'Create Family Account'
                              : 'Create Administrator Account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<SignUpRole>(
                          segments: const [
                            ButtonSegment<SignUpRole>(
                              value: SignUpRole.family,
                              icon: Icon(Icons.family_restroom),
                              label: Text('Family'),
                            ),
                            ButtonSegment<SignUpRole>(
                              value: SignUpRole.administrator,
                              icon: Icon(Icons.business),
                              label: Text('Administrator'),
                            ),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: isLoading
                              ? null
                              : (selection) {
                                  setState(() {
                                    _selectedRole = selection.first;
                                  });
                                },
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _usernameController,
                          keyboardType: isFamily
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: isFamily ? 'Email' : 'Username',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              isFamily ? Icons.email_outlined : Icons.person,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
                                    final bloc = context.read<AuthBloc>();

                                    if (isFamily) {
                                      bloc.add(
                                        PerformSignUpEvent(
                                          username: _usernameController.text,
                                          password: _passwordController.text,
                                          confirmPassword:
                                              _confirmPasswordController.text,
                                        ),
                                      );
                                      return;
                                    }

                                    bloc.add(
                                      PerformAdministratorSignUpEvent(
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                        confirmPassword:
                                            _confirmPasswordController.text,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isFamily
                                        ? 'Create Family Account'
                                        : 'Create Administrator Account',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Already have an account? Sign In'),
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
