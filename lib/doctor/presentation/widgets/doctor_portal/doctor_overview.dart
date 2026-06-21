import 'package:flutter/material.dart';

import '../../../../nursing/domain/entities/resident.dart';
import 'doctor_metric_tile.dart';

class DoctorOverview extends StatelessWidget {
  const DoctorOverview({
    super.key,
    required this.staffId,
    required this.residents,
    required this.onOpenDirectory,
  });

  final int staffId;
  final List<Resident> residents;
  final VoidCallback onOpenDirectory;

  @override
  Widget build(BuildContext context) {
    final activeResidents = residents
        .where((resident) => resident.status.toUpperCase() == 'ACTIVE')
        .length;

    final pendingRooms = residents
        .where((resident) => resident.roomId == null)
        .length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _DoctorWelcomeCard(staffId: staffId),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: DoctorMetricTile(
                label: 'Residents',
                value: residents.length.toString(),
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DoctorMetricTile(
                label: 'Active',
                value: activeResidents.toString(),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DoctorMetricTile(
          label: 'Room assignment pending',
          value: pendingRooms.toString(),
          icon: Icons.meeting_room_outlined,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onOpenDirectory,
          icon: const Icon(Icons.folder_shared_outlined),
          label: const Text('Open resident directory'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFF176B70),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorWelcomeCard extends StatelessWidget {
  const _DoctorWelcomeCard({required this.staffId});

  final int staffId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF176B70), Color(0xFF1C8C88)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF176B70).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF176B70),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinical workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Staff record #$staffId',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
