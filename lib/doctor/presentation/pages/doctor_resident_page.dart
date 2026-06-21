import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/entities/resident_health_record.dart';
import '../../domain/entities/resident_clinical_record.dart';
import '../bloc/doctor_clinical_bloc.dart';

class DoctorResidentPage extends StatefulWidget {
  final Resident resident;
  final int nursingHomeId;

  const DoctorResidentPage({
    super.key,
    required this.resident,
    required this.nursingHomeId,
  });

  @override
  State<DoctorResidentPage> createState() => _DoctorResidentPageState();
}

class _DoctorResidentPageState extends State<DoctorResidentPage> {
  late final DoctorClinicalBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = locator<DoctorClinicalBloc>()
      ..add(LoadDoctorClinicalRecordEvent(widget.resident.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.resident.fullName),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.monitor_heart_outlined), text: 'Vitals'),
                Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Allergies'),
                Tab(icon: Icon(Icons.medical_information_outlined), text: 'Conditions'),
              ],
            ),
          ),
          body: BlocConsumer<DoctorClinicalBloc, DoctorClinicalState>(
            listener: (context, state) {
              if (state is DoctorClinicalLoaded &&
                  state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.successMessage!)),
                );
              }
              if (state is DoctorClinicalError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is DoctorClinicalInitial ||
                  state is DoctorClinicalLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DoctorClinicalError) {
                return Center(
                  child: FilledButton.icon(
                    onPressed: () => _bloc.add(
                      LoadDoctorClinicalRecordEvent(widget.resident.id),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                );
              }

              final record = (state as DoctorClinicalLoaded).record;
              return TabBarView(
                children: [
                  _VitalSignsTab(record: record),
                  _AllergiesTab(
                    record: record,
                    onAdd: () => _showAllergyDialog(context),
                  ),
                  _ConditionsTab(
                    record: record,
                    onAdd: () => _showConditionDialog(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAllergyDialog(BuildContext context) async {
    final allergen = TextEditingController();
    final reaction = TextEditingController();
    var type = 'FOOD';
    var severity = 'MILD';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register allergy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: allergen,
                  decoration: const InputDecoration(labelText: 'Allergen'),
                ),
                TextField(
                  controller: reaction,
                  decoration: const InputDecoration(labelText: 'Reaction'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const ['FOOD', 'MEDICATION', 'ENVIRONMENTAL', 'OTHER']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => type = value);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: const ['MILD', 'MODERATE', 'SEVERE']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => severity = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      _bloc.add(
        RegisterDoctorAllergyEvent(
          residentId: widget.resident.id,
          allergenName: allergen.text,
          reaction: reaction.text,
          typeOfAllergy: type,
          severityLevel: severity,
        ),
      );
    }
    allergen.dispose();
    reaction.dispose();
  }

  Future<void> _showConditionDialog(BuildContext context) async {
    final diagnosis = TextEditingController();
    final notes = TextEditingController();
    var diagnosisDate = DateTime.now();
    var status = 'ACTIVE';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register medical condition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: diagnosis,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Diagnosis date'),
                  subtitle: Text(_formatDate(diagnosisDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: diagnosisDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selected != null) {
                      setDialogState(() => diagnosisDate = selected);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const ['ACTIVE', 'CONTROLLED', 'RESOLVED']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => status = value);
                  },
                ),
                TextField(
                  controller: notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      _bloc.add(
        RegisterDoctorMedicalConditionEvent(
          residentId: widget.resident.id,
          diagnosisName: diagnosis.text,
          diagnosisDate: diagnosisDate,
          status: status,
          notes: notes.text,
        ),
      );
    }
    diagnosis.dispose();
    notes.dispose();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _VitalSignsTab extends StatelessWidget {
  final ResidentClinicalRecord record;

  const _VitalSignsTab({required this.record});

  @override
  Widget build(BuildContext context) {
    return _ClinicalList<ResidentVitalSign>(
      items: record.vitalSigns,
      emptyMessage: 'No vital signs received from monitoring devices.',
      itemBuilder: (item) => ListTile(
        leading: const Icon(Icons.monitor_heart_outlined),
        title: Text(item.measurementId),
        trailing: _StatusChip(item.severityLevel),
      ),
    );
  }
}

class _AllergiesTab extends StatelessWidget {
  final ResidentClinicalRecord record;
  final VoidCallback onAdd;

  const _AllergiesTab({required this.record, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return _ClinicalList<ResidentAllergy>(
      items: record.allergies,
      emptyMessage: 'No allergies registered.',
      action: FloatingActionButton(
        tooltip: 'Register allergy',
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
      itemBuilder: (item) => ListTile(
        leading: const Icon(Icons.warning_amber_outlined),
        title: Text(item.allergenName),
        subtitle: Text('${item.typeOfAllergy} - ${item.reaction}'),
        trailing: _StatusChip(item.severityLevel),
      ),
    );
  }
}

class _ConditionsTab extends StatelessWidget {
  final ResidentClinicalRecord record;
  final VoidCallback onAdd;

  const _ConditionsTab({required this.record, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return _ClinicalList<ResidentMedicalCondition>(
      items: record.medicalConditions,
      emptyMessage: 'No medical conditions registered.',
      action: FloatingActionButton(
        tooltip: 'Register medical condition',
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
      itemBuilder: (item) => ListTile(
        leading: const Icon(Icons.medical_information_outlined),
        title: Text(item.diagnosisName),
        subtitle: Text(
          item.notes.isEmpty
              ? item.diagnosisDate
              : '${item.diagnosisDate}\n${item.notes}',
        ),
        isThreeLine: item.notes.isNotEmpty,
        trailing: _StatusChip(item.status),
      ),
    );
  }
}

class _ClinicalList<T> extends StatelessWidget {
  final List<T> items;
  final String emptyMessage;
  final Widget Function(T item) itemBuilder;
  final Widget? action;

  const _ClinicalList({
    required this.items,
    required this.emptyMessage,
    required this.itemBuilder,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        items.isEmpty
            ? Center(child: Text(emptyMessage, textAlign: TextAlign.center))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) => itemBuilder(items[index]),
              ),
        if (action != null)
          Positioned(right: 16, bottom: 16, child: action!),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F1F1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
