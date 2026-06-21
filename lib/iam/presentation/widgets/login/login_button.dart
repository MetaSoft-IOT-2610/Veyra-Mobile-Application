import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading ? _buildLoading() : _buildText(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      key: ValueKey('login-loading'),
      height: 24,
      width: 24,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
    );
  }

  Widget _buildText() {
    return const Row(
      key: ValueKey('login-text'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.login_rounded),
        SizedBox(width: 10),
        Text(
          'Ingresar',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
