import 'package:flutter/material.dart';

import '../../../domain/entities/family_health_data.dart';
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
          measurements: data.measurements.length,
          allergies: data.allergies.length,
          devices: data.devices.length,
        ),
        const SizedBox(height: 14),
        FamilySectionCard(
          title: 'Signos vitales',
          subtitle: 'Última medición disponible',
          icon: Icons.monitor_heart_outlined,
          children: () {
            if (data.measurements.isEmpty) {
              return const [
                FamilyEmptySection(message: 'Sin mediciones registradas.'),
              ];
            }
            final sorted = List<FamilyMeasurement>.from(data.measurements)
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
            final latest = sorted.first;
            return [
              FamilyHealthTile(
                icon: Icons.favorite_outline,
                title: 'Frecuencia cardíaca',
                subtitle: latest.heartRate != null ? '${latest.heartRate} bpm' : '-- bpm',
              ),
              FamilyHealthTile(
                icon: Icons.thermostat_outlined,
                title: 'Temperatura ambiente',
                subtitle: latest.ambientTemperature != null ? '${latest.ambientTemperature!.toStringAsFixed(1)} °C' : '-- °C',
              ),
              FamilyHealthTile(
                icon: Icons.opacity_outlined,
                title: 'Saturación de oxígeno',
                subtitle: latest.oxygenSaturation != null ? '${latest.oxygenSaturation}%' : '--%',
              ),
            ];
          }(),
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
