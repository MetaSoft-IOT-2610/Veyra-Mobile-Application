import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../domain/entities/activity.dart';
import '../bloc/activities_bloc.dart';

/// Page responsible for displaying and monitoring today's
/// scheduled activities for a nursing home.
///
/// This screen provides administrators and caregivers with
/// a centralized view of daily activities, including:
/// - Activity title.
/// - Scheduled time range.
/// - Current execution status.
/// - Visual status indicators.
///
/// Architecture:
/// - Layer: Presentation
/// - Pattern: BLoC
/// - Data Source: ActivitiesBloc
///
/// The page only consumes domain entities and does not
/// contain business logic.
class ActivitiesPage extends StatelessWidget {
  /// Identifier of the nursing home whose activities
  /// should be displayed.
  final int nursingHomeId;

  /// Creates a new [ActivitiesPage].
  ///
  /// Requires a valid [nursingHomeId] to retrieve
  /// activities from the application layer.
  const ActivitiesPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  /// Formats a [DateTime] into a human-readable
  /// 24-hour time representation.
  ///
  /// Example:
  /// - 08:30
  /// - 14:45
  ///
  /// Parameters:
  /// - [time]: Date to format.
  ///
  /// Returns:
  /// - Formatted time string.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Builds a visual badge representing the current
  /// activity status.
  ///
  /// Each status is displayed using a distinct color
  /// and label to improve readability.
  ///
  /// Parameters:
  /// - [status]: Current activity status.
  ///
  /// Returns:
  /// - A styled [Chip] widget.
  Widget _buildStatusChip(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Chip(
          label: const Text(
            'Completed',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green.shade50,
          side: BorderSide.none,
        );

      case ActivityStatus.inProgress:
        return Chip(
          label: const Text(
            'In Progress',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue.shade50,
          side: BorderSide.none,
        );

      case ActivityStatus.cancelled:
        return Chip(
          label: const Text(
            'Cancelled',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red.shade50,
          side: BorderSide.none,
        );

      case ActivityStatus.scheduled:
      default:
        return Chip(
          label: const Text(
            'Scheduled',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange.shade50,
          side: BorderSide.none,
        );
    }
  }

  /// Builds the activities monitoring page.
  ///
  /// A new [ActivitiesBloc] instance is created and
  /// immediately instructed to load today's activities
  /// for the selected nursing home.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<ActivitiesBloc>()
        ..add(
          FetchTodayActivitiesEvent(
            nursingHomeId: nursingHomeId,
          ),
        ),

      child: Scaffold(
        backgroundColor: Colors.blue.shade50,

        appBar: AppBar(
          title: const Text(
            'Activity Monitoring',
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),

        body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, state) {
            /// Loading state.
            ///
            /// Displayed while activities are being fetched.
            if (state is ActivitiesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            /// Error state.
            ///
            /// Displayed when the application layer returns
            /// an error during data retrieval.
            else if (state is ActivitiesError) {
              return Center(
                child: Text(
                  'Failed to load activities: ${state.message}',
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              );
            }

            /// Loaded state.
            ///
            /// Displays today's activities.
            else if (state is ActivitiesLoaded) {
              final activities = state.todayActivities;

              /// Empty state.
              if (activities.isEmpty) {
                return const Center(
                  child: Text(
                    'No activities scheduled for today.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              /// Activity list.
              return ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: activities.length,

                itemBuilder: (context, index) {
                  final activity = activities[index];

                  final startTimeStr =
                  _formatTime(activity.schedule.startTime);

                  final endTimeStr =
                  _formatTime(activity.schedule.endTime);

                  return Card(
                    elevation: 1,

                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(4.0),

                      child: ListTile(
                        /// Activity icon container.
                        leading: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: const Icon(
                            Icons.event_note,
                            color: Colors.blue,
                          ),
                        ),

                        /// Activity title.
                        title: Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// Scheduled time range.
                        subtitle: Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$startTimeStr - $endTimeStr',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Current activity status.
                        trailing: _buildStatusChip(
                          activity.status,
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            /// Initial state.
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
