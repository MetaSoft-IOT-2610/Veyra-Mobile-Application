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
                label: 'Alergias',
                value: data.allergies.length,
                icon: Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FamilyOverviewMetric(
                label: 'Dispositivos',
                value: data.devices.length,
                icon: Icons.sensors_outlined,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FamilyOverviewMetric(
                label: 'Actividades',
                value: data.activities.length,
                icon: Icons.event_note_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FamilySectionCard(
          title: 'Informacion personal',
          subtitle: 'Datos registrados por la residencia',
          icon: Icons.badge_outlined,
          children: [
            FamilyDetailRow(label: 'DNI', value: profile.dni),
            FamilyDetailRow(
              label: 'Edad',
              value: profile.age > 0 ? '${profile.age} anos' : '',
            ),
            FamilyDetailRow(label: 'Nacimiento', value: profile.birthDate),
            FamilyDetailRow(label: 'Telefono', value: profile.phoneNumber),
            FamilyDetailRow(label: 'Correo', value: profile.emailAddress),
          ],
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'Contacto de emergencia',
          icon: Icons.contact_emergency_outlined,
          children: [
            FamilyDetailRow(
              label: 'Nombre',
              value: resident.emergencyContactName,
            ),
            FamilyDetailRow(
              label: 'Telefono',
              value: resident.emergencyContactPhoneNumber,
            ),
          ],
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'Mi vinculacion',
          icon: Icons.family_restroom_outlined,
          children: [
            FamilyDetailRow(label: 'Familiar', value: data.relative.fullName),
            FamilyDetailRow(label: 'Correo', value: data.relative.email),
          ],
        ),
      ],
    );
  }
}
