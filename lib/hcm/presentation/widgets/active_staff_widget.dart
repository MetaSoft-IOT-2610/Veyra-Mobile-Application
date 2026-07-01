import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../bloc/staff_bloc.dart';
import '../pages/staff_directory_page.dart';

class ActiveStaffWidget extends StatelessWidget {
  const ActiveStaffWidget({
    super.key,
    required this.nursingHomeId,
    this.onViewDirectory,
  });

  final int nursingHomeId;
  final VoidCallback? onViewDirectory;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaffBloc>(
      create: (_) =>
          locator<StaffBloc>()..add(LoadActiveStaffEvent(nursingHomeId)),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is StaffError) {
            return _StaffMessage(text: state.message, error: true);
          }
          if (state is! StaffLoaded) return const SizedBox.shrink();

          final staff = state.staffMembers
              .where((item) => item.isActive)
              .toList();
          if (staff.isEmpty) {
            return const _StaffMessage(
              text: 'There are currently no active staff members assigned.',
            );
          }

          return Column(
            children: [
              ...staff
                  .take(4)
                  .map(
                    (item) => _StaffTile(
                      initials: item.firstName.isEmpty
                          ? '#'
                          : item.firstName[0].toUpperCase(),
                      photo: item.photo,
                      name: item.fullName,
                      subtitle: item.emailAddress.isNotEmpty
                          ? item.emailAddress
                          : item.role == 'Unassigned'
                          ? 'Profile #${item.personProfileId}'
                          : item.role,
                    ),
                  ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openDirectory(context),
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('View complete directory'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openDirectory(BuildContext context) async {
    if (onViewDirectory != null) {
      onViewDirectory!();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffDirectoryPage(nursingHomeId: nursingHomeId),
      ),
    );
    if (context.mounted) {
      context.read<StaffBloc>().add(LoadActiveStaffEvent(nursingHomeId));
    }
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    required this.initials,
    required this.photo,
    required this.name,
    required this.subtitle,
  });

  final String initials;
  final String photo;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: photo.startsWith('http')
              ? NetworkImage(photo)
              : null,
          child: photo.startsWith('http')
              ? null
              : Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(width: 11),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.circle, color: AppColors.success, size: 10),
      ],
    ),
  );
}

class _StaffMessage extends StatelessWidget {
  const _StaffMessage({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: error ? AppColors.dangerSoft : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: error ? AppColors.danger : AppColors.textSecondary,
      ),
    ),
  );
}
