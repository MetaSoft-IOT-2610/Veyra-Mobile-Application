import 'package:flutter/material.dart';

import '../../../activities/domain/entities/activity.dart';
import '../../../shared/presentation/theme/app_colors.dart';

String familyActivityTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String familyActivityType(String value) => switch (value.toUpperCase()) {
  'MEAL' => 'Meal',
  'BATH' => 'Bath',
  'RISK_PROFILE' => 'Risk Profile',
  'RECREATIONAL' => 'Recreational',
  _ => value,
};

String familyActivityDay(String value) => switch (value.toUpperCase()) {
  'MON' || 'MONDAY' => 'Mon',
  'TUE' || 'TUESDAY' => 'Tue',
  'WED' || 'WEDNESDAY' => 'Wed',
  'THU' || 'THURSDAY' => 'Thu',
  'FRI' || 'FRIDAY' => 'Fri',
  'SAT' || 'SATURDAY' => 'Sat',
  'SUN' || 'SUNDAY' => 'Sun',
  _ => value,
};

({String label, IconData icon, Color color}) familyActivityStatus(
  ActivityStatus status,
) => switch (status) {
  ActivityStatus.pending => (
    label: 'PENDING',
    icon: Icons.schedule_outlined,
    color: AppColors.warning,
  ),
  ActivityStatus.inProgress => (
    label: 'IN PROGRESS',
    icon: Icons.play_circle_outline,
    color: AppColors.cyan,
  ),
  ActivityStatus.completed => (
    label: 'COMPLETED',
    icon: Icons.check_circle_outline,
    color: AppColors.success,
  ),
  ActivityStatus.cancelled => (
    label: 'CANCELLED',
    icon: Icons.cancel_outlined,
    color: AppColors.danger,
  ),
};
