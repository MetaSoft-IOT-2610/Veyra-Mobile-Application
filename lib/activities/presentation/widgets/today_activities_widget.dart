import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../bloc/activities_bloc.dart';

class TodayActivitiesWidget extends StatelessWidget {
  const TodayActivitiesWidget({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivitiesBloc>(
      create: (_) =>
          locator<ActivitiesBloc>()
            ..add(FetchTodayActivitiesEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
          if (state is ActivitiesLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            );
          }
          if (state is ActivitiesError) {
            return _Message(
              icon: Icons.cloud_off_outlined,
              text: state.message,
              color: AppColors.danger,
            );
          }
          if (state is! ActivitiesLoaded) return const SizedBox.shrink();
          if (state.todayActivities.isEmpty) {
            return const _Message(
              icon: Icons.event_available_outlined,
              text: 'No hay actividades programadas para hoy.',
              color: AppColors.primary,
            );
          }

          return Column(
            children: state.todayActivities
                .take(5)
                .map(
                  (activity) => _ActivityTile(
                    title: activity.title,
                    time:
                        '${_time(activity.schedule.startTime)} - '
                        '${_time(activity.schedule.endTime)}',
                    completed: activity.status.name == 'completed',
                    ongoing: activity.schedule.isOngoing,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.time,
    required this.completed,
    required this.ongoing,
  });

  final String title;
  final String time;
  final bool completed;
  final bool ongoing;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.success
        : ongoing
        ? AppColors.cyan
        : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.schedule_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (ongoing && !completed)
            const _StatusLabel(text: 'EN CURSO', color: AppColors.cyan),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}
