import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';
import '../pages/staff_directory_page.dart';

class ActiveStaffWidget extends StatelessWidget {
  final int nursingHomeId;
  final VoidCallback? onViewDirectory;

  const ActiveStaffWidget({
    super.key,
    required this.nursingHomeId,
    this.onViewDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffBloc>(
      create: (_) =>
          locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StaffError) {
            return Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            );
          }

          if (state is StaffLoaded) {
            final activeStaff = state.staffMembers
                .where((staff) => staff.isActive)
                .toList();

            return Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    title: Text(
                      'On-Duty Staff',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(Icons.badge, color: Colors.indigo),
                  ),
                  const Divider(height: 1),
                  if (activeStaff.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No staff members are currently assigned.'),
                    ),
                  ...activeStaff
                      .take(5)
                      .map(
                        (staff) => ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              staff.firstName.isNotEmpty
                                  ? staff.firstName[0].toUpperCase()
                                  : '#',
                            ),
                          ),
                          title: Text(staff.fullName),
                          subtitle: Text(
                            staff.emailAddress.isNotEmpty
                                ? staff.emailAddress
                                : staff.role == 'Unassigned'
                                ? 'Person profile: ${staff.personProfileId}'
                                : staff.role,
                          ),
                          trailing: Icon(
                            Icons.circle,
                            color: staff.isActive ? Colors.green : Colors.grey,
                            size: 12,
                          ),
                        ),
                      ),
                  const Divider(height: 1),
                  TextButton(
                    onPressed: () async {
                      if (onViewDirectory != null) {
                        onViewDirectory!();
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StaffDirectoryPage(nursingHomeId: nursingHomeId),
                        ),
                      );
                      if (context.mounted) {
                        context.read<StaffBloc>().add(
                          LoadActiveStaffEvent(nursingHomeId),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                    ),
                    child: const Text('View Full Directory'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
