import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../../../shared/presentation/widgets/clinical_state_view.dart';
import '../../../shared/presentation/widgets/directory_header.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../bloc/nursing_bloc.dart';
import 'resident_detail_page.dart';

class ResidentDirectoryPage extends StatelessWidget {
  const ResidentDirectoryPage({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<NursingBloc>()
            ..add(LoadResidentListEvent(nursingHomeId: nursingHomeId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Residentes')),
        body: BlocBuilder<NursingBloc, NursingState>(
          builder: (context, state) {
            if (state is NursingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NursingError) {
              return ClinicalStateView(
                icon: Icons.cloud_off_outlined,
                title: 'No se pudo cargar el directorio',
                message: state.message,
                isError: true,
                onRetry: () => context.read<NursingBloc>().add(
                  LoadResidentListEvent(nursingHomeId: nursingHomeId),
                ),
              );
            }
            if (state is! NursingListLoaded) return const SizedBox.shrink();
            if (state.residents.isEmpty) {
              return const ClinicalStateView(
                icon: Icons.elderly_outlined,
                title: 'Sin residentes',
                message: 'No hay residentes registrados en esta sede.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: state.residents.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return DirectoryHeader(
                    icon: Icons.elderly_outlined,
                    title: 'Censo de residentes',
                    subtitle: 'Informacion y seguimiento clinico',
                    count: state.residents.length,
                  );
                }
                final resident = state.residents[index - 1];
                return _ResidentCard(
                  name: resident.fullName,
                  initial: resident.firstName.isEmpty
                      ? '?'
                      : resident.firstName[0].toUpperCase(),
                  photo: resident.photo,
                  status: resident.status,
                  room: resident.roomId,
                  contact: resident.emergencyContactName,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResidentDetailPage(
                        nursingHomeId: nursingHomeId,
                        resident: resident,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  const _ResidentCard({
    required this.name,
    required this.initial,
    required this.photo,
    required this.status,
    required this.room,
    required this.contact,
    required this.onTap,
  });

  final String name;
  final String initial;
  final String photo;
  final String status;
  final int? room;
  final String contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: photo.startsWith('http')
                  ? NetworkImage(photo)
                  : null,
              child: photo.startsWith('http')
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room == null ? 'Habitacion pendiente' : 'Habitacion $room',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (contact.isNotEmpty)
                    Text(
                      'Emergencia: $contact',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusPill(status: status),
                const SizedBox(height: 10),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
