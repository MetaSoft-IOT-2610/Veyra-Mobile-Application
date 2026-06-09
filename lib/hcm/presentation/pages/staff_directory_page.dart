import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';

/// Presentation page responsible for displaying the nursing home's
/// staff directory.
///
/// This page serves as the main entry point for staff management
/// within the Presentation layer. It interacts with the [StaffBloc]
/// to retrieve and display active staff members associated with a
/// specific nursing home.
///
/// Features:
/// - Automatically loads active staff members on page initialization.
/// - Displays loading, error, empty, and loaded states.
/// - Provides retry functionality when data retrieval fails.
/// - Shows staff information in a scrollable list.
/// - Displays employee status using visual indicators.
/// - Provides an action button for future staff registration features.
class StaffDirectoryPage extends StatelessWidget {
  /// Unique identifier of the nursing home whose staff directory
  /// should be displayed.
  final int nursingHomeId;

  /// Creates a new [StaffDirectoryPage].
  ///
  /// The [nursingHomeId] parameter is required to retrieve
  /// staff information for the corresponding nursing home.
  const StaffDirectoryPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  /// Builds the page and initializes the [StaffBloc].
  ///
  /// Upon creation, a [LoadActiveStaffEvent] is dispatched
  /// to load all active staff members associated with the
  /// provided nursing home.
  ///
  /// State Handling:
  /// - [StaffLoading]: Displays a loading indicator.
  /// - [StaffError]: Displays an error message and retry button.
  /// - [StaffLoaded]: Displays the staff directory.
  /// - Default: Displays an initialization message.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Directorio del Personal'),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<StaffBloc, StaffState>(
          builder: (context, state) {
            if (state is StaffLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is StaffError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),

                    /// Displays the error message returned
                    /// by the application layer.
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    /// Allows the user to retry loading staff data.
                    ElevatedButton(
                      onPressed: () => context.read<StaffBloc>().add(
                        LoadActiveStaffEvent(nursingHomeId),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is StaffLoaded) {
              /// Collection of active staff members retrieved
              /// from the application layer.
              final staffList = state.staffMembers;

              if (staffList.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay personal registrado en esta sede.',
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final employee = staffList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    child: ListTile(
                      /// Displays the employee's initials.
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          employee.firstName
                              .substring(0, 1)
                              .toUpperCase(),
                        ),
                      ),

                      /// Displays the employee's full name.
                      title: Text(
                        '${employee.firstName} ${employee.lastName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// Displays the employee's role.
                      ///
                      /// Assumes the domain entity exposes a
                      /// `role` property.
                      subtitle: Text(
                        'Role: ${employee.role}',
                      ),

                      /// Visual status indicator.
                      ///
                      /// Assumes the domain entity exposes a
                      /// `status` property.
                      trailing: _buildStatusChip(
                        employee.status,
                      ),

                      /// Placeholder action for future navigation
                      /// to the employee details page.
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'View profile of ${employee.firstName}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text(
                'Initializing staff directory...',
              ),
            );
          },
        ),

        /// Floating action button intended for future staff
        /// registration functionality.
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Future implementation:
            // Navigate to Create Staff Member page.
          },
          backgroundColor: Colors.teal.shade700,
          child: const Icon(
            Icons.person_add_alt_1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Builds a visual status badge for an employee.
  ///
  /// Parameters:
  /// - [status]: Current employee status.
  ///
  /// Returns a [Chip] widget indicating whether
  /// the employee is active or inactive.
  ///
  /// Supported values:
  /// - `ACTIVE` → Green "Active" badge.
  /// - Any other value → Red "Inactive" badge.
  Widget _buildStatusChip(String status) {
    final isActive = status.toUpperCase() == 'ACTIVE';

    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive
              ? Colors.green.shade800
              : Colors.red.shade800,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive
          ? Colors.green.shade100
          : Colors.red.shade100,
      padding: EdgeInsets.zero,
    );
  }
}
