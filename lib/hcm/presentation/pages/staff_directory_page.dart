import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';
import 'staff_detail_page.dart';

class StaffDirectoryPage extends StatelessWidget {
  final int nursingHomeId;

  const StaffDirectoryPage({super.key, required this.nursingHomeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
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

            if (state is StaffError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
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
                ),
              );
            }

            if (state is StaffLoaded) {
              final staffList = state.staffMembers;

              if (staffList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay personal registrado en esta sede.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final employee = staffList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () async {
                        final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) =>
                                StaffDetailPage(staffMember: employee),
                          ),
                        );
                        if (changed == true && context.mounted) {
                          context.read<StaffBloc>().add(
                            LoadActiveStaffEvent(nursingHomeId),
                          );
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        child: Text(
                          employee.firstName.isNotEmpty
                              ? employee.firstName[0].toUpperCase()
                              : '#',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        employee.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Person profile: ${employee.personProfileId}'),
                            if (employee.emailAddress.isNotEmpty)
                              Text(employee.emailAddress),
                            if (employee.phoneNumber.isNotEmpty)
                              Text(employee.phoneNumber),
                            if (employee.emergencyContactName.isNotEmpty)
                              Text(
                                'Emergency: ${employee.emergencyContactName}',
                              ),
                          ],
                        ),
                      ),
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
