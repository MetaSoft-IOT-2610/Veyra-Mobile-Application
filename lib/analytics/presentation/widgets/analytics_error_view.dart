import 'package:flutter/material.dart';

import '../../../shared/presentation/theme/app_colors.dart';

class AnalyticsErrorView extends StatelessWidget {
  const AnalyticsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.error_outline, color: AppColors.danger),
    title: const Text('No se cargaron las metricas'),
    subtitle: Text(message),
    trailing: IconButton(
      tooltip: 'Reintentar',
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
    ),
  );
}
