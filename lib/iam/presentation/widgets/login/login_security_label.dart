import 'package:flutter/material.dart';

class LoginSecurityLabel extends StatelessWidget {
  const LoginSecurityLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 18,
          color: Colors.blueGrey.shade500,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Secure access for authorized staff',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
