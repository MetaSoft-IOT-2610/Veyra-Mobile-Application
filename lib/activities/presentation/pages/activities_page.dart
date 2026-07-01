import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../../domain/entities/activity.dart';
import '../bloc/activities_bloc.dart';
import '../models/activity_directory_options.dart';
import '../widgets/activity_dashboard/activity_card.dart';
import '../widgets/activity_dashboard/activity_filters.dart';
import '../widgets/activity_dashboard/activity_states.dart';
import '../widgets/activity_dashboard/activity_summary.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<ActivitiesBloc>()
            ..add(FetchTodayActivitiesEvent(nursingHomeId: nursingHomeId)),
      child: _ActivitiesView(nursingHomeId: nursingHomeId),
    );
  }
}

class _ActivitiesView extends StatefulWidget {
  const _ActivitiesView({required this.nursingHomeId});

  final int nursingHomeId;

  @override
  State<_ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<_ActivitiesView> {
  ActivityStatus? _selectedStatus;
  late final Future<ActivityDirectoryOptions> _options;

  @override
  void initState() {
    super.initState();
    _options = loadActivityDirectoryOptions(widget.nursingHomeId);
  }

  void _refresh() {
    context.read<ActivitiesBloc>().add(
      FetchTodayActivitiesEvent(nursingHomeId: widget.nursingHomeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Schedule'),
            SizedBox(height: 2),
            Text(
              'Today\'s Activities',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
          if (state is ActivitiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ActivitiesError) {
            return ActivityErrorState(
              message: state.message,
              onRetry: _refresh,
            );
          }

          final activities = switch (state) {
            ActivitiesLoaded(:final todayActivities) => todayActivities,
            ActivitiesActionInProgress(:final todayActivities) =>
              todayActivities,
            _ => const <Activity>[],
          };
          final visible = _selectedStatus == null
              ? activities
              : activities
                    .where((item) => item.status == _selectedStatus)
                    .toList();

          return FutureBuilder<ActivityDirectoryOptions>(
            future: _options,
            builder: (context, snapshot) {
              final header = <Widget>[
                ActivitySummary(activities: activities),
                const SizedBox(height: 14),
                ActivityFilters(
                  selected: _selectedStatus,
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator(),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SizedBox(height: 12),
              ];
              final contentCount = visible.isEmpty ? 1 : visible.length;

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  itemCount: header.length + contentCount,
                  itemBuilder: (context, index) {
                    if (index < header.length) return header[index];
                    if (visible.isEmpty) return const ActivityEmptyState();

                    final activity = visible[index - header.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ActivityDashboardCard(
                        activity: activity,
                        residentName:
                            snapshot.data?.residentNames[activity.residentId],
                        staffName: snapshot
                            .data
                            ?.staffNames[activity.healthcareStaffId],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
