import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';
import '../../presenters/activity_visual_presenter.dart';

class ActivityDashboardCard extends StatelessWidget {
  const ActivityDashboardCard({
    super.key,
    required this.activity,
    this.residentName,
    this.staffName,
  });

  final Activity activity;
  final String? residentName;
  final String? staffName;

  @override
  Widget build(BuildContext context) {
    final status = activityVisualStatus(activity.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(status.icon, color: status.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatActivityTime(activity.schedule.startTime)} - ${formatActivityTime(activity.schedule.endTime)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.elderly_outlined,
              text: residentName ?? 'Residente no encontrado',
            ),
            const SizedBox(height: 6),
            _InfoLine(
              icon: Icons.badge_outlined,
              text: staffName ?? 'Personal no encontrado',
            ),
            if (activity.isRecurring) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  const _RecurringBadge(label: 'Recurrente', repeat: true),
                  ...activity.recurringDays.map(
                    (day) => _RecurringBadge(label: activityDayLabel(day)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
    ),
  );
}

class _RecurringBadge extends StatelessWidget {
  const _RecurringBadge({required this.label, this.repeat = false});

  final String label;
  final bool repeat;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (repeat) ...[
          const Icon(Icons.repeat, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    ),
  );
}
