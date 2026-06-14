import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../bloc/activities_bloc.dart';

/// Dashboard widget responsible for displaying today's
/// scheduled activities for a nursing home.
///
/// This widget:
/// - Retrieves today's activities through the Activities BLoC.
/// - Displays loading, error, and success states.
/// - Presents activity schedules in a user-friendly format.
/// - Highlights completed activities visually.
///
/// Architecture:
/// - Layer: Presentation
/// - Pattern: BLoC
/// - Data Source: ActivitiesBloc
///
/// The widget is designed to be embedded inside dashboard
/// screens and overview pages.
class TodayActivitiesWidget extends StatelessWidget {
  /// Identifier of the nursing home whose activities
  /// should be displayed.
  final int nursingHomeId;

  /// Creates a new [TodayActivitiesWidget].
  ///
  /// Requires a valid [nursingHomeId] to retrieve
  /// activity information.
  const TodayActivitiesWidget({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  /// Formats a [DateTime] value into a user-friendly
  /// HH:mm representation.
  ///
  /// Example:
  /// - 09:30
  /// - 14:45
  ///
  /// Parameters:
  /// - [time]: DateTime to format.
  ///
  /// Returns:
  /// - A formatted time string.
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Builds the widget tree.
  ///
  /// A new [ActivitiesBloc] instance is provided and
  /// immediately instructed to load today's activities
  /// for the specified nursing home.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActivitiesBloc>(
      create: (_) => locator<ActivitiesBloc>()
        ..add(
          FetchTodayActivitiesEvent(
            nursingHomeId: nursingHomeId,
          ),
        ),

      child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
        builder: (context, state) {
          /// Loading state.
          ///
          /// Displays a compact loading indicator while
          /// activities are being retrieved.
          if (state is ActivitiesLoading) {
            return const LinearProgressIndicator();
          }

          /// Error state.
          ///
          /// Displays the error returned by the application layer.
          if (state is ActivitiesError) {
            return Text(
              'Error: ${state.message}',
              style: const TextStyle(
                color: Colors.red,
              ),
            );
          }

          /// Success state.
          ///
          /// Displays today's activities.
          if (state is ActivitiesLoaded) {
            final activities = state.todayActivities;

            return Card(
              elevation: 2,

              child: Column(
                children: [
                  /// Section header.
                  const ListTile(
                    title: Text(
                      'Today\'s Activities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                  ),

                  const Divider(height: 1),

                  /// Empty state.
                  ///
                  /// Displayed when no activities are scheduled
                  /// for the current day.
                  if (activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No activities scheduled for today.',
                      ),
                    ),

                  /// Activity list.
                  ///
                  /// Each activity displays:
                  /// - Title
                  /// - Time range
                  /// - Completion indicator (if applicable)
                  ...activities.map((activity) {
                    final startTimeStr =
                    _formatTime(activity.schedule.startTime);

                    final endTimeStr =
                    _formatTime(activity.schedule.endTime);

                    return ListTile(
                      /// Activity icon.
                      leading: const Icon(
                        Icons.event_available,
                        color: Colors.green,
                      ),

                      /// Activity title.
                      ///
                      /// Uses the domain entity's `title`
                      /// property, aligned with the backend's
                      /// ubiquitous language.
                      title: Text(
                        activity.title,
                      ),

                      /// Scheduled time range.
                      subtitle: Text(
                        '$startTimeStr - $endTimeStr',
                      ),

                      /// Visual indicator for completed activities.
                      trailing: activity.status.name == 'completed'
                          ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                          : null,
                    );
                  }).toList(),
                ],
              ),
            );
          }

          /// Initial or unknown state.
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
