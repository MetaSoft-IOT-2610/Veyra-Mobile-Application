import 'package:flutter/material.dart';

import '../../../domain/entities/family_portal_data.dart';
import 'family_activity_components.dart';
import 'family_components.dart';

class FamilyActivitiesView extends StatelessWidget {
  const FamilyActivitiesView({super.key, required this.data});

  final FamilyPortalData data;

  @override
  Widget build(BuildContext context) {
    final contentCount = data.activities.isEmpty ? 1 : data.activities.length;
    return ListView.builder(
      key: const PageStorageKey('family-activities'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: contentCount + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return FamilyAgendaHeader(activities: data.activities);
        }
        if (index == 1) return const SizedBox(height: 14);
        if (data.activities.isEmpty) {
          return const FamilySectionCard(
            title: 'Resident\'s schedule',
            icon: Icons.event_available_outlined,
            children: [
              FamilyEmptySection(
                message: 'No activities scheduled for this resident.',
              ),
            ],
          );
        }

        final activity = data.activities[index - 2];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FamilyActivityCard(activity: activity),
        );
      },
    );
  }
}
