import 'package:flutter/material.dart';

import '../../../../nursing/domain/entities/resident.dart';
import 'resident_list_tile.dart';

class ResidentDirectory extends StatelessWidget {
  const ResidentDirectory({
    super.key,
    required this.residents,
    required this.nursingHomeId,
  });

  final List<Resident> residents;
  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    if (residents.isEmpty) {
      return const _EmptyResidentsView();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: residents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return ResidentListTile(
          resident: residents[index],
          nursingHomeId: nursingHomeId,
        );
      },
    );
  }
}

class _EmptyResidentsView extends StatelessWidget {
  const _EmptyResidentsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 64,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 14),
            const Text(
              'No residents registered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17324D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Residents assigned to this nursing home will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
