import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/dependency_injection.dart';
import '../bloc/nursing_bloc.dart';

class ResidentDirectoryPage extends StatelessWidget {
  final int nursingHomeId;

  const ResidentDirectoryPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Disparamos el evento de la lista
      create: (_) => locator<NursingBloc>()
        ..add(LoadResidentListEvent(nursingHomeId: nursingHomeId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resident Directory'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<NursingBloc, NursingState>(
          builder: (context, state) {
            if (state is NursingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            else if (state is NursingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<NursingBloc>().add(
                        LoadResidentListEvent(nursingHomeId: nursingHomeId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Escuchamos el estado correcto
            else if (state is NursingListLoaded) {
              final residents = state.residents;

              if (residents.isEmpty) {
                return const Center(child: Text('No residents registered.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: residents.length,
                itemBuilder: (context, index) {
                  final resident = residents[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(resident.firstName.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(
                        resident.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Usamos status ya que roomNumber no existe en la entidad Resident
                      subtitle: Text('Status: ${resident.status}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View details for ${resident.firstName}')),
                        );
                      },
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Initializing resident loading...'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue.shade700,
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
      ),
    );
  }
}
