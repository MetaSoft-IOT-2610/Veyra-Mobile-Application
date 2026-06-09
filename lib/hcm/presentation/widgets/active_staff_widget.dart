import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';
import '../pages/staff_directory_page.dart';

/// Dashboard widget responsible for displaying a summarized view
/// of active staff members assigned to a nursing home.
///
/// This widget is intended for dashboard and overview screens where
/// only a subset of staff information is required.
///
/// Features:
/// - Automatically loads active staff members.
/// - Displays loading, error, and success states.
/// - Shows up to five staff members for quick access.
/// - Provides visual indicators for active employees.
/// - Includes navigation to the complete staff directory.
class ActiveStaffWidget extends StatelessWidget {
  /// Unique identifier of the nursing home whose active
  /// staff members should be displayed.
  final int nursingHomeId;

  /// Creates a new [ActiveStaffWidget].
  ///
  /// The [nursingHomeId] is required to retrieve
  /// the corresponding staff information.
  const ActiveStaffWidget({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  /// Builds the widget tree and initializes the [StaffBloc].
  ///
  /// Upon creation, a [LoadActiveStaffEvent] is dispatched
  /// to retrieve active staff members from the application layer.
  ///
  /// State Handling:
  /// - [StaffLoading]: Displays a loading indicator.
  /// - [StaffError]: Displays an error message.
  /// - [StaffLoaded]: Displays the active staff summary.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffBloc>(
      create: (_) =>
      locator<StaffBloc>()
        ..add(LoadActiveStaffEvent(nursingHomeId)),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          /// Loading state.
          if (state is StaffLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// Error state.
          if (state is StaffError) {
            return Text(
              'Error: ${state.message}',
              style: const TextStyle(
                color: Colors.red,
              ),
            );
          }

          /// Success state.
          if (state is StaffLoaded) {
            return Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  /// Widget header.
                  const ListTile(
                    title: Text(
                      'On-Duty Staff',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Icon(
                      Icons.badge,
                      color: Colors.indigo,
                    ),
                  ),

                  const Divider(height: 1),

                  /// Empty state.
                  if (state.staffMembers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No staff members are currently assigned.',
                      ),
                    ),

                  /// Displays a maximum of five staff members
                  /// to keep the dashboard concise.
                  ...state.staffMembers
                      .take(5)
                      .map(
                        (staff) => ListTile(
                      /// Displays the first letter of the
                      /// employee's first name.
                      leading: CircleAvatar(
                        child: Text(
                          staff.firstName[0],
                        ),
                      ),

                      /// Employee full name.
                      title: Text(
                        staff.fullName,
                      ),

                      /// Employee role or position.
                      subtitle: Text(
                        staff.role,
                      ),

                      /// Active status indicator.
                      trailing: const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                  )
                      .toList(),

                  /// Navigation button displayed only when
                  /// staff members exist.
                  if (state.staffMembers.isNotEmpty) ...[
                    const Divider(height: 1),

                    /// Navigates to the complete staff directory page.
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StaffDirectoryPage(
                                  nursingHomeId:
                                  nursingHomeId,
                                ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape:
                        const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(
                            bottom: Radius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                      child: const Text(
                        'View Full Directory',
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          /// Fallback state.
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
