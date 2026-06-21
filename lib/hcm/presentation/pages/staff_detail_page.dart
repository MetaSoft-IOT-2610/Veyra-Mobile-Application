import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/core/config/app_capabilities.dart';
import '../../domain/entities/staff_contract.dart';
import '../../domain/entities/staff_member.dart';
import '../bloc/staff_bloc.dart';

class StaffDetailPage extends StatelessWidget {
  final StaffMember staffMember;

  const StaffDetailPage({super.key, required this.staffMember});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<StaffBloc>()..add(LoadStaffContractsEvent(staffMember.id)),
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(title: Text(staffMember.fullName)),
        body: BlocConsumer<StaffBloc, StaffState>(
          listener: (context, state) {
            if (state is StaffError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is StaffActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final contracts = state is StaffContractsLoaded
                ? state.contracts
                : <StaffContract>[];
            final isLoading = state is StaffLoading;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(
                  title: 'Staff member',
                  icon: Icons.badge_outlined,
                  children: [
                    _InfoRow('Identifier', staffMember.id.toString()),
                    _InfoRow(
                      'Person profile',
                      staffMember.personProfileId.toString(),
                    ),
                    _InfoRow('DNI', staffMember.dni),
                    _InfoRow('Email', staffMember.emailAddress),
                    _InfoRow('Phone', staffMember.phoneNumber),
                    _InfoRow('Status', staffMember.status),
                  ],
                ),
                _InfoCard(
                  title: 'Emergency contact',
                  icon: Icons.contact_emergency_outlined,
                  children: [
                    _InfoRow('Name', staffMember.emergencyContactName),
                    _InfoRow('Phone', staffMember.emergencyContactPhoneNumber),
                  ],
                ),
                _ContractsCard(
                  contracts: contracts,
                  isLoading: isLoading,
                  onAdd: () => _showContractDialog(context, contracts),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showContractDialog(
    BuildContext context,
    List<StaffContract> contracts,
  ) {
    final activeContract = _activeContract(contracts);
    if (activeContract != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This staff member already has an active contract until ${activeContract.endDate}.',
          ),
        ),
      );
      return;
    }

    final bloc = context.read<StaffBloc>();
    final typeController = TextEditingController(text: 'Full-time');
    var role = 'NURSE';
    var shift = 'DAY';
    var startDate = _nextContractStartDate(contracts);
    var endDate = DateTime.now().add(const Duration(days: 365));
    if (!endDate.isAfter(startDate)) {
      endDate = startDate.add(const Duration(days: 365));
    }

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add contract'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type of contract',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerTile(
                  label: 'Start date',
                  value: startDate,
                  firstDate: startDate,
                  onChanged: (value) {
                    setState(() {
                      startDate = value;
                      if (!endDate.isAfter(startDate)) {
                        endDate = startDate.add(const Duration(days: 365));
                      }
                    });
                  },
                ),
                _DatePickerTile(
                  label: 'End date',
                  value: endDate,
                  firstDate: startDate.add(const Duration(days: 1)),
                  onChanged: (value) => setState(() => endDate = value),
                ),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items:
                      const [
                            'DOCTOR',
                            'NURSE',
                            'CAREGIVER',
                            'COOK',
                            'ADMINISTRATIVE',
                          ]
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => role = value ?? role),
                ),
                DropdownButtonFormField<String>(
                  initialValue: shift,
                  decoration: const InputDecoration(labelText: 'Work shift'),
                  items: const ['DAY', 'NIGHT', 'DAWN']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) => setState(() => shift = value ?? shift),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (typeController.text.trim().isEmpty) return;
                if (!endDate.isAfter(startDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End date must be after start date.'),
                    ),
                  );
                  return;
                }
                bloc.add(
                  AddStaffContractEvent(
                    staffMemberId: staffMember.id,
                    startDate: startDate,
                    endDate: endDate,
                    typeOfContract: typeController.text,
                    staffRole: role,
                    workShift: shift,
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

  StaffContract? _activeContract(List<StaffContract> contracts) {
    for (final contract in contracts) {
      if (contract.isActive) return contract;
    }
    return null;
  }

  DateTime _nextContractStartDate(List<StaffContract> contracts) {
    final parsedEndDates = contracts
        .map((contract) => DateTime.tryParse(contract.endDate))
        .whereType<DateTime>()
        .toList();
    if (parsedEndDates.isEmpty) return DateTime.now();

    parsedEndDates.sort();
    final nextDate = parsedEndDates.last.add(const Duration(days: 1));
    final today = DateTime.now();
    if (nextDate.isBefore(today)) return today;
    return nextDate;
  }
}

class _ContractsCard extends StatelessWidget {
  final List<StaffContract> contracts;
  final bool isLoading;
  final VoidCallback onAdd;

  const _ContractsCard({
    required this.contracts,
    required this.isLoading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    StaffContract? activeContract;
    for (final contract in contracts) {
      if (contract.isActive) {
        activeContract = contract;
        break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Contracts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!AppCapabilities.isReadOnly)
                  IconButton(
                    tooltip: activeContract == null
                        ? 'Add contract'
                        : 'Active contract ends on ${activeContract.endDate}',
                    onPressed: activeContract == null && !isLoading
                        ? onAdd
                        : null,
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
            if (activeContract != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Icon(Icons.lock_clock, color: Colors.green.shade700),
                  title: const Text('Active contract in progress'),
                  subtitle: Text(
                    'New contracts can start after ${activeContract.endDate}.',
                  ),
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (contracts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No contracts registered.'),
              )
            else
              ...contracts.map(
                (contract) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${contract.staffRole} - ${contract.typeOfContract}',
                  ),
                  subtitle: Text(
                    '${contract.startDate} to ${contract.endDate} | ${contract.workShift}',
                  ),
                  trailing: _StatusChip(contract.status),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime value;
  final DateTime? firstDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerTile({
    required this.label,
    required this.value,
    this.firstDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
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
          Flexible(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final isActive = status.toUpperCase() == 'ACTIVE';
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.orange.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isActive ? Colors.green.shade50 : Colors.orange.shade50,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }
}
