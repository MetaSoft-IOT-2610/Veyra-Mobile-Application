import 'package:flutter/material.dart';

class LoginFooterText extends StatelessWidget {
  const LoginFooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Cuidado, seguimiento y administración en un solo lugar.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Colors.blueGrey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
