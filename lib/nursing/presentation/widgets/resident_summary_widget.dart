import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/di/dependency_injection.dart';
import '../bloc/nursing_bloc.dart';

class ResidentSummaryWidget extends StatelessWidget {
  final int nursingHomeId;

  const ResidentSummaryWidget({Key? key, required this.nursingHomeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NursingBloc>(
      create: (_) => locator<NursingBloc>()..add(LoadResidentSummaryEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<NursingBloc, NursingState>(
        builder: (context, state) {
          if (state is NursingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is NursingError) {
            return Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text('Error al cargar censo'),
                subtitle: Text(state.message),
              ),
            );
          }

          if (state is NursingSummaryLoaded) {
            final summary = state.summary;
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt, color: Colors.blue, size: 28),
                        const SizedBox(width: 12),
                        Text('Censo Actual', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(context, 'Residentes', summary.totalResidents.toString(), Icons.person),
                        _buildStat(context, 'Camas Libres', summary.availableRooms.toString(), Icons.bed),
                        _buildStat(context, 'Ocupación', '${summary.occupancyRate.toStringAsFixed(1)}%', Icons.pie_chart),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}