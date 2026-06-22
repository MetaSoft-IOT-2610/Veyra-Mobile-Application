import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/core/config/app_capabilities.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/relative.dart';
import '../../domain/entities/resident.dart';
import '../../domain/entities/resident_health_record.dart';
import '../bloc/nursing_bloc.dart';

class ResidentDetailPage extends StatefulWidget {
  final int nursingHomeId;
  final Resident resident;

  const ResidentDetailPage({
    super.key,
    required this.nursingHomeId,
    required this.resident,
  });

  @override
  State<ResidentDetailPage> createState() => _ResidentDetailPageState();
}

class _ResidentDetailPageState extends State<ResidentDetailPage> {
  late Resident _resident;

  @override
  void initState() {
    super.initState();
    _resident = widget.resident;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<NursingBloc>()
        ..add(
          LoadResidentDetailsEvent(
            nursingHomeId: widget.nursingHomeId,
            residentId: _resident.id,
          ),
        ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.blue.shade50,
          appBar: AppBar(
            title: Text(_resident.fullName),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'Details'),
                Tab(icon: Icon(Icons.meeting_room_outlined), text: 'Room'),
                Tab(icon: Icon(Icons.monitor_heart_outlined), text: 'Health'),
                Tab(icon: Icon(Icons.family_restroom_outlined), text: 'Family'),
              ],
            ),
          ),
          body: BlocConsumer<NursingBloc, NursingState>(
            listener: (context, state) {
              if (state is NursingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state is ResidentActionSuccess) {
                if (state.resident != null) {
                  setState(() => _resident = state.resident!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<NursingBloc>().add(
                  LoadResidentDetailsEvent(
                    nursingHomeId: widget.nursingHomeId,
                    residentId: _resident.id,
                  ),
                );
              }
            },
            builder: (context, state) {
              final details = state is ResidentDetailsLoaded ? state : null;
              return TabBarView(
                children: [
                  _DetailsTab(resident: _resident),
                  _RoomTab(
                    nursingHomeId: widget.nursingHomeId,
                    resident: _resident,
                  ),
                  _HealthTab(
                    resident: _resident,
                    isLoading: state is NursingLoading,
                    allergies: details?.allergies ?? const [],
                    conditions: details?.medicalConditions ?? const [],
                    vitalSigns: details?.vitalSigns ?? const [],
                  ),
                  _FamilyTab(
                    nursingHomeId: widget.nursingHomeId,
                    resident: _resident,
                    isLoading: state is NursingLoading,
                    familyUsers: details?.familyUsers ?? const [],
                    relatives: details?.relatives ?? const [],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Resident resident;

  const _DetailsTab({required this.resident});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = resident.photo.startsWith('http');
    final initial = resident.firstName.isEmpty
        ? '?'
        : resident.firstName[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: hasPhoto
                      ? NetworkImage(resident.photo)
                      : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          initial,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade700,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  resident.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        _InfoCard(
          title: 'Resident',
          icon: Icons.elderly,
          children: [
            _InfoRow('Identifier', resident.id.toString()),
            _InfoRow('Person profile', resident.personProfileId.toString()),
            _InfoRow('Status', resident.status),
          ],
        ),
        _InfoCard(
          title: 'Legal representative',
          icon: Icons.assignment_ind_outlined,
          children: [
            _InfoRow('Name', resident.legalRepresentativeName),
            _InfoRow('Phone', resident.legalRepresentativePhoneNumber),
          ],
        ),
        _InfoCard(
          title: 'Emergency contact',
          icon: Icons.contact_emergency_outlined,
          children: [
            _InfoRow('Name', resident.emergencyContactName),
            _InfoRow('Phone', resident.emergencyContactPhoneNumber),
          ],
        ),
      ],
    );
  }
}

class _RoomTab extends StatelessWidget {
  final int nursingHomeId;
  final Resident resident;

  const _RoomTab({required this.nursingHomeId, required this.resident});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room, size: 56, color: Colors.blue.shade700),
            const SizedBox(height: 16),
            Text(
              resident.roomId == null
                  ? 'No room assigned'
                  : 'Room ID: ${resident.roomId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (!AppCapabilities.isReadOnly) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: const Text('Assign room'),
                onPressed: () => _showAssignRoomDialog(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAssignRoomDialog(BuildContext context) {
    final bloc = context.read<NursingBloc>();
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign room'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Room number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              bloc.add(
                AssignResidentRoomEvent(
                  nursingHomeId: nursingHomeId,
                  residentId: resident.id,
                  roomNumber: controller.text,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

class _HealthTab extends StatelessWidget {
  final Resident resident;
  final bool isLoading;
  final List<ResidentAllergy> allergies;
  final List<ResidentMedicalCondition> conditions;
  final List<ResidentVitalSign> vitalSigns;

  const _HealthTab({
    required this.resident,
    required this.isLoading,
    required this.allergies,
    required this.conditions,
    required this.vitalSigns,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ListSection(
          title: 'Vital signs',
          icon: Icons.monitor_heart_outlined,
          action: null,
          emptyText: 'No vital signs recorded.',
          children: vitalSigns
              .map(
                (item) => ListTile(
                  title: Text(item.measurementId),
                  trailing: _Badge(item.severityLevel),
                ),
              )
              .toList(),
        ),
        _ListSection(
          title: 'Allergies',
          icon: Icons.warning_amber_outlined,
          action: AppCapabilities.isReadOnly
              ? null
              : () => _showAllergyDialog(context),
          emptyText: 'No allergies registered.',
          children: allergies
              .map(
                (item) => ListTile(
                  title: Text(item.allergenName),
                  subtitle: Text('${item.typeOfAllergy} - ${item.reaction}'),
                  trailing: _Badge(item.severityLevel),
                ),
              )
              .toList(),
        ),
        _ListSection(
          title: 'Medical conditions',
          icon: Icons.medical_information_outlined,
          action: AppCapabilities.isReadOnly
              ? null
              : () => _showConditionDialog(context),
          emptyText: 'No medical conditions registered.',
          children: conditions
              .map(
                (item) => ListTile(
                  title: Text(item.diagnosisName),
                  subtitle: Text('${item.diagnosisDate} - ${item.notes}'),
                  trailing: _Badge(item.status),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showAllergyDialog(BuildContext context) {
    final bloc = context.read<NursingBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final allergen = TextEditingController();
    final reaction = TextEditingController();
    var type = 'FOOD';
    var severity = 'NORMAL';
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Register allergy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: allergen,
                decoration: const InputDecoration(labelText: 'Allergen name'),
              ),
              TextField(
                controller: reaction,
                decoration: const InputDecoration(labelText: 'Reaction'),
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                items:
                    const [
                          'FOOD',
                          'DRUG',
                          'ENVIRONMENTAL',
                          'INSECT',
                          'LATEX',
                          'CHEMICAL',
                          'OTHER',
                        ]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                onChanged: (v) => setState(() => type = v ?? type),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                initialValue: severity,
                items: const ['NORMAL', 'MEDIUM', 'HIGH', 'CRITICAL']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => severity = v ?? severity),
                decoration: const InputDecoration(labelText: 'Severity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (allergen.text.trim().isEmpty ||
                    reaction.text.trim().isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Complete allergen and reaction.'),
                    ),
                  );
                  return;
                }
                bloc.add(
                  RegisterResidentAllergyEvent(
                    residentId: resident.id,
                    allergenName: allergen.text,
                    reaction: reaction.text,
                    typeOfAllergy: type,
                    severityLevel: severity,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConditionDialog(BuildContext context) {
    final bloc = context.read<NursingBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final diagnosis = TextEditingController();
    final notes = TextEditingController();
    var status = 'ACTIVE';
    var date = DateTime.now();
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Register condition'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diagnosis,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const ['ACTIVE', 'RESOLVED', 'CHRONIC']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) => setState(() => status = v ?? status),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (diagnosis.text.trim().isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Complete diagnosis name.')),
                  );
                  return;
                }
                bloc.add(
                  RegisterMedicalConditionEvent(
                    residentId: resident.id,
                    diagnosisName: diagnosis.text,
                    diagnosisDate: date,
                    status: status,
                    notes: notes.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyTab extends StatelessWidget {
  final int nursingHomeId;
  final Resident resident;
  final bool isLoading;
  final List<FamilyUser> familyUsers;
  final List<Relative> relatives;

  const _FamilyTab({
    required this.nursingHomeId,
    required this.resident,
    required this.isLoading,
    required this.familyUsers,
    required this.relatives,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ListSection(
          title: 'Assigned family',
          icon: Icons.family_restroom_outlined,
          action: AppCapabilities.isReadOnly
              ? null
              : () => _showRelativeDialog(context),
          emptyText: 'No relatives assigned to this resident.',
          children: relatives
              .map(
                (relative) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    child: const Icon(Icons.person_outline),
                  ),
                  title: Text(relative.fullName),
                  subtitle: Text(relative.email),
                  trailing: _Badge(
                    relative.hasUser ? 'User #${relative.userId}' : 'Pending',
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showRelativeDialog(BuildContext context) {
    final bloc = context.read<NursingBloc>();
    final messenger = ScaffoldMessenger.of(context);
    FamilyUser? selectedUser;

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign family to ${resident.fullName}'),
          content: SizedBox(
            width: 420,
            child: familyUsers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No family email accounts available.'),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: familyUsers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = familyUsers[index];
                            final selected = selectedUser?.id == user.id;
                            return ListTile(
                              selected: selected,
                              onTap: () => setState(() => selectedUser = user),
                              title: Text(user.displayName),
                              subtitle: Text(user.email),
                              trailing: Icon(
                                selected
                                    ? Icons.check_circle
                                    : Icons.person_outline,
                                color: selected ? Colors.blue : null,
                              ),
                            );
                          },
                        ),
                      ),
                      if (selectedUser != null) ...[
                        const SizedBox(height: 12),
                        _SelectedFamilyPreview(user: selectedUser!),
                      ],
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: familyUsers.isEmpty
                  ? null
                  : () {
                      final user = selectedUser;
                      if (user == null) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Select a family account.'),
                          ),
                        );
                        return;
                      }
                      bloc.add(
                        CreateResidentRelativeEvent(
                          nursingHomeId: nursingHomeId,
                          residentId: resident.id,
                          familyUser: user,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedFamilyPreview extends StatelessWidget {
  final FamilyUser user;

  const _SelectedFamilyPreview({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.person_add_alt_1, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(user.email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value.isEmpty ? 'N/A' : value),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? action;
  final String emptyText;
  final List<Widget> children;

  const _ListSection({
    required this.title,
    required this.icon,
    required this.action,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (action != null)
                  IconButton(
                    tooltip: 'Add',
                    onPressed: action,
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
            if (children.isEmpty)
              Padding(padding: const EdgeInsets.all(16), child: Text(emptyText))
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text), padding: EdgeInsets.zero);
  }
}
