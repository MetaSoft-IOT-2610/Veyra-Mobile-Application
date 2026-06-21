import 'package:flutter/material.dart';

import '../../../../nursing/domain/entities/resident.dart';
import '../../pages/doctor_resident_page.dart';

class ResidentListTile extends StatelessWidget {
  const ResidentListTile({
    super.key,
    required this.resident,
    required this.nursingHomeId,
  });

  final Resident resident;
  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    final initial = resident.firstName.isEmpty
        ? '?'
        : resident.firstName[0].toUpperCase();

    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.blueGrey.shade50),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE6F4F3),
          child: Text(
            initial,
            style: const TextStyle(
              color: Color(0xFF176B70),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          resident.fullName,
          style: const TextStyle(
            color: Color(0xFF17324D),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            resident.roomId == null
                ? 'Room assignment pending'
                : 'Room ${resident.roomId}',
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorResidentPage(
              resident: resident,
              nursingHomeId: nursingHomeId,
            ),
          ),
        ),
      ),
    );
  }
}
