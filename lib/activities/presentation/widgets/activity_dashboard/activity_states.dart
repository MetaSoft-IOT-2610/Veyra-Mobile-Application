import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/clinical_state_view.dart';

class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({super.key});

  @override
  Widget build(BuildContext context) => const ClinicalStateView(
    icon: Icons.event_available_outlined,
    title: 'Agenda libre',
    message: 'No hay actividades para mostrar con este filtro.',
  );
}

class ActivityErrorState extends StatelessWidget {
  const ActivityErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ClinicalStateView(
    icon: Icons.cloud_off_outlined,
    title: 'No se pudo cargar la agenda',
    message: message,
    isError: true,
    onRetry: onRetry,
  );
}
