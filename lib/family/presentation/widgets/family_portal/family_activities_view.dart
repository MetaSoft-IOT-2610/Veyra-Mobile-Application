import 'package:flutter/material.dart';

import '../../../domain/entities/family_portal_data.dart';
import 'family_activity_components.dart';
import 'family_components.dart';

class FamilyActivitiesView extends StatelessWidget {
  const FamilyActivitiesView({super.key, required this.data});

  final FamilyPortalData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('family-activities'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        FamilyAgendaHeader(activities: data.activities),
        const SizedBox(height: 14),
        if (data.activities.isEmpty)
          const FamilySectionCard(
            title: 'Agenda del residente',
            icon: Icons.event_available_outlined,
            children: [
              FamilyEmptySection(
                message: 'No hay actividades programadas para este residente.',
              ),
            ],
          )
        else
          ...data.activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FamilyActivityCard(activity: activity),
            ),
          ),
      ],
    );
  }
}
