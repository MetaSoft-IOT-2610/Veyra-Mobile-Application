import 'package:flutter/material.dart';

import '../../../activities/domain/entities/activity.dart';
import '../../../shared/presentation/theme/app_colors.dart';

String familyActivityTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String familyActivityType(String value) => switch (value.toUpperCase()) {
  'MEAL' => 'Comida',
  'BATH' => 'Bano',
  'RISK_PROFILE' => 'Perfil de riesgo',
  'RECREATIONAL' => 'Recreativa',
  _ => value,
};

String familyActivityDay(String value) => switch (value.toUpperCase()) {
  'MON' || 'MONDAY' => 'Lun',
  'TUE' || 'TUESDAY' => 'Mar',
  'WED' || 'WEDNESDAY' => 'Mie',
  'THU' || 'THURSDAY' => 'Jue',
  'FRI' || 'FRIDAY' => 'Vie',
  'SAT' || 'SATURDAY' => 'Sab',
  'SUN' || 'SUNDAY' => 'Dom',
  _ => value,
};

({String label, IconData icon, Color color}) familyActivityStatus(
  ActivityStatus status,
) => switch (status) {
  ActivityStatus.pending => (
    label: 'PENDIENTE',
    icon: Icons.schedule_outlined,
    color: AppColors.warning,
  ),
  ActivityStatus.inProgress => (
    label: 'EN CURSO',
    icon: Icons.play_circle_outline,
    color: AppColors.cyan,
  ),
  ActivityStatus.completed => (
    label: 'COMPLETADA',
    icon: Icons.check_circle_outline,
    color: AppColors.success,
  ),
  ActivityStatus.cancelled => (
    label: 'CANCELADA',
    icon: Icons.cancel_outlined,
    color: AppColors.danger,
  ),
};
