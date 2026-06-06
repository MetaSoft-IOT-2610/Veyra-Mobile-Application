import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../bloc/staff_bloc.dart';

class ActiveStaffWidget extends StatelessWidget {
  final int nursingHomeId;

  const ActiveStaffWidget({Key? key, required this.nursingHomeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffBloc>(
      create: (_) => locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) return const Center(child: CircularProgressIndicator());
          if (state is StaffError) return Text('Error: ${state.message}', style: const TextStyle(color: Colors.red));

          if (state is StaffLoaded) {
            return Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Text('Personal de Turno', style: TextStyle(fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.badge, color: Colors.indigo),
                  ),
                  const Divider(height: 1),
                  if (state.staffMembers.isEmpty)
                    const Padding(padding: EdgeInsets.all(16), child: Text('No hay personal asignado actualmente.')),
                  ...state.staffMembers.take(5).map((staff) => ListTile(
                    leading: CircleAvatar(child: Text(staff.firstName[0])),
                    title: Text(staff.fullName),
                    subtitle: Text(staff.role),
                    trailing: const Icon(Icons.circle, color: Colors.green, size: 12),
                  )).toList(),
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
