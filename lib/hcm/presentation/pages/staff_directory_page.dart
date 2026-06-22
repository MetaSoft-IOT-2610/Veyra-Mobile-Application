import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../../../shared/presentation/widgets/clinical_state_view.dart';
import '../../../shared/presentation/widgets/directory_header.dart';
import '../../../shared/presentation/widgets/status_pill.dart';
import '../bloc/staff_bloc.dart';
import 'staff_detail_page.dart';

class StaffDirectoryPage extends StatelessWidget {
  const StaffDirectoryPage({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Personal')),
        body: BlocBuilder<StaffBloc, StaffState>(
          builder: (context, state) {
            if (state is StaffLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StaffError) {
              return ClinicalStateView(
                icon: Icons.cloud_off_outlined,
                title: 'No se pudo cargar el personal',
                message: state.message,
                isError: true,
                onRetry: () => context.read<StaffBloc>().add(
                  LoadActiveStaffEvent(nursingHomeId),
                ),
              );
            }
            if (state is! StaffLoaded) return const SizedBox.shrink();
            if (state.staffMembers.isEmpty) {
              return const ClinicalStateView(
                icon: Icons.badge_outlined,
                title: 'Sin personal',
                message: 'No hay personal registrado en esta sede.',
              );
            }

            final active = state.staffMembers
                .where((item) => item.isActive)
                .length;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: state.staffMembers.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return DirectoryHeader(
                    icon: Icons.medical_services_outlined,
                    title: 'Equipo asistencial',
                    subtitle: '$active activos de ${state.staffMembers.length}',
                    count: state.staffMembers.length,
                  );
                }
                final employee = state.staffMembers[index - 1];
                return _StaffCard(
                  name: employee.fullName,
                  initial: employee.firstName.isEmpty
                      ? '#'
                      : employee.firstName[0].toUpperCase(),
                  photo: employee.photo,
                  status: employee.status,
                  role: employee.role,
                  email: employee.emailAddress,
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => StaffDetailPage(staffMember: employee),
                      ),
                    );
                    if (changed == true && context.mounted) {
                      context.read<StaffBloc>().add(
                        LoadActiveStaffEvent(nursingHomeId),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.name,
    required this.initial,
    required this.photo,
    required this.status,
    required this.role,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String initial;
  final String photo;
  final String status;
  final String role;
  final String email;
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
                    role == 'Unassigned' ? 'Rol no asignado' : role,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
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
