import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../domain/entities/family_portal_data.dart';
import 'family_components.dart';
import 'family_overview_components.dart';

class FamilyOverviewView extends StatelessWidget {
  const FamilyOverviewView({super.key, required this.data});

  final FamilyPortalData data;

  @override
  Widget build(BuildContext context) {
    final resident = data.resident;
    final profile = data.residentProfile;
    return ListView(
      key: const PageStorageKey('family-overview'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        FamilyResidentHero(
          name: resident.fullName,
          photo: profile.photo,
          room: resident.roomId,
          status: resident.status,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FamilyOverviewMetric(
                label: 'Allergies',
                value: data.allergies.length,
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FamilyOverviewMetric(
                label: 'Devices',
                value: data.devices.length,
                icon: Icons.sensors_outlined,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FamilyOverviewMetric(
                label: 'Activities',
                value: data.activities.length,
                icon: Icons.event_note_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FamilySectionCard(
          title: 'Personal Information',
          subtitle: 'Data recorded by the nursing home',
          icon: Icons.badge_outlined,
          children: [
            FamilyDetailRow(label: 'DNI', value: profile.dni),
            FamilyDetailRow(
              label: 'Age',
              value: profile.age > 0 ? '${profile.age} years' : '',
            ),
            FamilyDetailRow(label: 'Birth Date', value: profile.birthDate),
            FamilyDetailRow(label: 'Phone Number', value: profile.phoneNumber),
            FamilyDetailRow(label: 'Email', value: profile.emailAddress),
          ],
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'Emergency Contact',
          icon: Icons.contact_emergency_outlined,
          children: [
            FamilyDetailRow(
              label: 'Name',
              value: resident.emergencyContactName,
            ),
            FamilyDetailRow(
              label: 'Phone Number',
              value: resident.emergencyContactPhoneNumber,
            ),
          ],
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'My Connection',
          icon: Icons.family_restroom_outlined,
          children: [
            FamilyDetailRow(label: 'Relative', value: data.relative.fullName),
            FamilyDetailRow(label: 'Email', value: data.relative.email),
          ],
        ),
      ],
    );
  }
}
