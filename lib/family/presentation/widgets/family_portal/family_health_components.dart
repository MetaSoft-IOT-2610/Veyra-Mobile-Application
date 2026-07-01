import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import 'family_components.dart';

class FamilyHealthHeader extends StatelessWidget {
  const FamilyHealthHeader({
    super.key,
    required this.measurements,
    required this.allergies,
    required this.devices,
  });

  final int measurements;
  final int allergies;
  final int devices;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppColors.softShadow,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.health_and_safety_outlined,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Information shared by the residence',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          '$measurements measurements\n$allergies allergies',
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class FamilyHealthTile extends StatelessWidget {
  const FamilyHealthTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        if (badge != null && badge!.isNotEmpty) FamilyStatusBadge(text: badge!),
      ],
    ),
  );
}
