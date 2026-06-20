import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/dependency_injection.dart';
import '../bloc/nursing_bloc.dart';
import 'create_resident_page.dart';
import 'resident_detail_page.dart';

class ResidentDirectoryPage extends StatelessWidget {
  final int nursingHomeId;

  const ResidentDirectoryPage({Key? key, required this.nursingHomeId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<NursingBloc>()
            ..add(LoadResidentListEvent(nursingHomeId: nursingHomeId)),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: const Text('Directorio de Residentes'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Registrar'),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      CreateResidentPage(nursingHomeId: nursingHomeId),
                ),
              );

              if (created == true && context.mounted) {
                context.read<NursingBloc>().add(
                  LoadResidentListEvent(nursingHomeId: nursingHomeId),
                );
              }
            },
          ),
        ),
        body: BlocBuilder<NursingBloc, NursingState>(
          builder: (context, state) {
            if (state is NursingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NursingError) {
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
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<NursingBloc>().add(
                          LoadResidentListEvent(nursingHomeId: nursingHomeId),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is NursingListLoaded) {
              final residents = state.residents;

              if (residents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.elderly_outlined,
                          size: 56,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay residentes registrados en esta sede.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: residents.length,
                itemBuilder: (context, index) {
                  final resident = residents[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResidentDetailPage(
                              nursingHomeId: nursingHomeId,
                              resident: resident,
                            ),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade800,
                        child: Text(
                          resident.firstName.isNotEmpty
                              ? resident.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        resident.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Person profile: ${resident.personProfileId}'),
                            if (resident.legalRepresentativeName.isNotEmpty)
                              Text(
                                'Representative: ${resident.legalRepresentativeName}',
                              ),
                            if (resident.emergencyContactName.isNotEmpty)
                              Text(
                                'Emergency: ${resident.emergencyContactName}',
                              ),
                          ],
                        ),
                      ),
                      trailing: _buildStatusChip(resident.status),
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
