import 'package:flutter/material.dart';

import 'login_button.dart';
import 'login_security_label.dart';
import 'login_text_field.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shadowColor: Colors.blueGrey.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                _buildTitle(),
                const SizedBox(height: 26),
                _buildUsernameField(context),
                const SizedBox(height: 18),
                _buildPasswordField(),
                const SizedBox(height: 28),
                LoginButton(
                  isLoading: widget.isLoading,
                  onPressed: widget.onSubmit,
                ),
                const SizedBox(height: 18),
                const LoginSecurityLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ingresa tus credenciales para acceder al sistema.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return LoginTextField(
      controller: widget.usernameController,
      enabled: !widget.isLoading,
      label: 'Usuario',
      hint: 'Ingresa tu usuario',
      icon: Icons.person_outline_rounded,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingrese su usuario.';
        }

        return null;
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(widget.passwordFocusNode);
      },
    );
  }

  Widget _buildPasswordField() {
    return LoginTextField(
      controller: widget.passwordController,
      focusNode: widget.passwordFocusNode,
      enabled: !widget.isLoading,
      label: 'Contraseña',
      hint: 'Ingresa tu contraseña',
      icon: Icons.lock_outline_rounded,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        tooltip: _isPasswordVisible
            ? 'Ocultar contraseña'
            : 'Mostrar contraseña',
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
        onPressed: widget.isLoading ? null : _togglePasswordVisibility,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese su contraseña.';
        }

        return null;
      },
      onFieldSubmitted: (_) {
        if (!widget.isLoading) {
          widget.onSubmit();
        }
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
}
