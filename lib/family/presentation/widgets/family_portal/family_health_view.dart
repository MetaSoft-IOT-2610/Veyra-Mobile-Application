import 'package:flutter/material.dart';

import '../../../domain/entities/family_portal_data.dart';
import 'family_components.dart';
import 'family_health_components.dart';

class FamilyHealthView extends StatelessWidget {
  const FamilyHealthView({super.key, required this.data});

  final FamilyPortalData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('family-health'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        FamilyHealthHeader(
          vitalSigns: data.vitalSigns.length,
          allergies: data.allergies.length,
          devices: data.devices.length,
        ),
        const SizedBox(height: 14),
        FamilySectionCard(
          title: 'Signos vitales',
          subtitle: 'Ultimas mediciones disponibles',
          icon: Icons.monitor_heart_outlined,
          children: data.vitalSigns.isEmpty
              ? const [
                  FamilyEmptySection(message: 'Sin mediciones registradas.'),
                ]
              : data.vitalSigns
                    .map(
                      (item) => FamilyHealthTile(
                        icon: Icons.favorite_outline,
                        title: item.measurementId,
                        badge: item.severityLevel,
                      ),
                    )
                    .toList(),
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'Alergias',
          subtitle: 'Alertas importantes para el cuidado',
          icon: Icons.warning_amber_outlined,
          children: data.allergies.isEmpty
              ? const [FamilyEmptySection(message: 'Sin alergias registradas.')]
              : data.allergies
                    .map(
                      (item) => FamilyHealthTile(
                        icon: Icons.health_and_safety_outlined,
                        title: item.allergenName,
                        subtitle: [
                          item.typeOfAllergy,
                          item.reaction,
                        ].where((value) => value.isNotEmpty).join(' - '),
                        badge: item.severityLevel,
                      ),
                    )
                    .toList(),
        ),
        const SizedBox(height: 12),
        FamilySectionCard(
          title: 'Dispositivos',
          subtitle: 'Equipos asociados al residente',
          icon: Icons.watch_outlined,
          children: data.devices.isEmpty
              ? const [
                  FamilyEmptySection(message: 'Sin dispositivos asignados.'),
                ]
              : data.devices
                    .map(
                      (item) => FamilyHealthTile(
                        icon: Icons.sensors_outlined,
                        title: item.deviceType,
                        subtitle: item.macAddress,
                        badge: item.status,
                      ),
                    )
                    .toList(),
        ),
      ],
    );
  }
}
