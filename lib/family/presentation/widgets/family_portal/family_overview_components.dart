import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import 'family_components.dart';

class FamilyResidentHero extends StatelessWidget {
  const FamilyResidentHero({
    super.key,
    required this.name,
    required this.photo,
    required this.room,
    required this.status,
  });

  final String name;
  final String photo;
  final int? room;
  final String status;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo.startsWith('http');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.clinicalGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: Colors.white,
            backgroundImage: hasPhoto ? NetworkImage(photo) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.elderly, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  room == null ? 'Habitacion pendiente' : 'Habitacion $room',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          FamilyStatusBadge(text: status),
        ],
      ),
    );
  }
}

class FamilyOverviewMetric extends StatelessWidget {
  const FamilyOverviewMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    ),
  );
}
