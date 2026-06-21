import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../doctor/presentation/pages/doctor_portal_page.dart';
import '../../../family/presentation/pages/family_portal_page.dart';
import '../../../shared/presentation/pages/admin_main_layout_page.dart';
import '../../../shared/presentation/pages/setup_required_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login/login_card.dart';
import '../widgets/login/login_footer_text.dart';
import '../widgets/login/login_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      PerformLoginEvent(
        _usernameController.text.trim(),
        _passwordController.text,
      ),
    );
  }

  void _handleAuthError(BuildContext context, AuthError state) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_isSetupRequiredError(state.message)) {
      _goToPage(context, const SetupRequiredPage());
      return;
    }

    _showErrorMessage(context, state.message);
  }

  bool _isSetupRequiredError(String message) {
    return message.contains('Requiere configuración inicial') ||
        message.contains('404');
  }

  void _handleAuthSuccess(BuildContext context, AuthSuccess state) {
    final session = state.session;

    if (session.isDoctor) {
      final staffId = session.staffId;
      final nursingHomeId = session.nursingHomeId;

      if (staffId == null || nursingHomeId == null) {
        _showErrorMessage(
          context,
          'No se pudo cargar la información del doctor.',
        );
        return;
      }

      _goToPage(
        context,
        DoctorPortalPage(staffId: staffId, nursingHomeId: nursingHomeId),
      );
      return;
    }

    if (session.isFamily) {
      _goToPage(
        context,
        session.requiresPersonProfileSetup
            ? const SetupRequiredPage()
            : const FamilyPortalPage(),
      );
      return;
    }

    if (session.requiresNursingHomeSetup && session.administratorId != null) {
      _goToPage(context, const SetupRequiredPage());
      return;
    }

    final nursingHomeId = session.nursingHomeId;

    if (nursingHomeId == null) {
      _showErrorMessage(
        context,
        'No se pudo cargar la casa de reposo asociada a esta cuenta.',
      );
      return;
    }

    _goToPage(context, AdminMainLayoutPage(nursingHomeId: nursingHomeId));
  }

  void _goToPage(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF7F6), Color(0xFFF7FBFF), Color(0xFFE8F1FF)],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  _handleAuthError(context, state);
                }

                if (state is AuthSuccess) {
                  _handleAuthSuccess(context, state);
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const LoginHeader(),
                                const SizedBox(height: 28),
                                LoginCard(
                                  formKey: _formKey,
                                  usernameController: _usernameController,
                                  passwordController: _passwordController,
                                  passwordFocusNode: _passwordFocusNode,
                                  isLoading: isLoading,
                                  onSubmit: () => _submitLogin(context),
                                ),
                                const SizedBox(height: 20),
                                const LoginFooterText(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
