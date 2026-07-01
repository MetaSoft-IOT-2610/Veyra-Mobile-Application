import 'package:flutter/material.dart';

import '../../../shared/presentation/theme/app_colors.dart';
import '../../domain/entities/activity.dart';

typedef ActivityVisualStatus = ({String label, IconData icon, Color color});

String formatActivityTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String activityDayLabel(String value) => switch (value.toUpperCase()) {
  'MON' || 'MONDAY' => 'Mon',
  'TUE' || 'TUESDAY' => 'Tue',
  'WED' || 'WEDNESDAY' => 'Wed',
  'THU' || 'THURSDAY' => 'Thu',
  'FRI' || 'FRIDAY' => 'Fri',
  'SAT' || 'SATURDAY' => 'Sat',
  'SUN' || 'SUNDAY' => 'Sun',
  _ => value,
};

ActivityVisualStatus activityVisualStatus(ActivityStatus status) =>
    switch (status) {
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
