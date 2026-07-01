import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';

class ActivitySummary extends StatelessWidget {
  const ActivitySummary({super.key, required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    int count(ActivityStatus status) =>
        activities.where((item) => item.status == status).length;

    return Row(
      children: [
        Expanded(
          child: _Metric(
            label: 'Pending',
            value: count(ActivityStatus.pending),
            icon: Icons.schedule_outlined,
            color: AppColors.warning,
            background: AppColors.warningSoft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            label: 'In Progress',
            value: count(ActivityStatus.inProgress),
            icon: Icons.play_circle_outline,
            color: AppColors.cyan,
            background: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            label: 'Completed',
            value: count(ActivityStatus.completed),
            icon: Icons.check_circle_outline,
            color: AppColors.success,
            background: AppColors.successSoft,
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    ),
  );
}
