import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';

/// Presentation page responsible for displaying the nursing home's
/// staff directory.
///
/// This page serves as a Read-Only monitoring dashboard for staff
/// management within the Presentation layer. It coordinates state
/// management through the [StaffBloc] and renders the appropriate UI.
///
/// Features:
/// - Loads staff members when the page is opened.
/// - Displays loading, error, empty, and success states.
/// - Provides a retry mechanism for failed requests.
/// - Displays employee information in a scrollable list.
class StaffDirectoryPage extends StatelessWidget {
  /// Identifier of the nursing home whose staff members
  /// should be displayed.
  final int nursingHomeId;

  /// Creates a new [StaffDirectoryPage].
  const StaffDirectoryPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Directorio del Personal'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocBuilder<StaffBloc, StaffState>(
          builder: (context, state) {
            if (state is StaffLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            else if (state is StaffError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
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

            else if (state is StaffLoaded) {
              final staffList = state.staffMembers;

              if (staffList.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay personal registrado en esta sede.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
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
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        child: Text(
                          employee.firstName.isNotEmpty
                              ? employee.firstName.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        '${employee.firstName} ${employee.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Rol: ${employee.role}'),
                      trailing: _buildStatusChip(employee.status),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Builds a visual status indicator for an employee.
  Widget _buildStatusChip(String status) {
    final isActive = status.toUpperCase() == 'ACTIVE';
    return Chip(
      label: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isActive ? Colors.green.shade50 : Colors.red.shade50,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}
