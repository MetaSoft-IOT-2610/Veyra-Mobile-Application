import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../hcm/domain/entities/staff_member.dart';
import '../../../hcm/domain/repositories/i_staff_repository.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';
import '../../../shared/core/config/app_capabilities.dart';
import '../../domain/entities/activity.dart';
import '../bloc/activities_bloc.dart';

class ActivitiesPage extends StatelessWidget {
  final int nursingHomeId;

  const ActivitiesPage({super.key, required this.nursingHomeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<ActivitiesBloc>()
            ..add(FetchTodayActivitiesEvent(nursingHomeId: nursingHomeId)),
      child: _ActivitiesView(nursingHomeId: nursingHomeId),
    );
  }
}

class _ActivitiesView extends StatefulWidget {
  final int nursingHomeId;

  const _ActivitiesView({required this.nursingHomeId});

  @override
  State<_ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<_ActivitiesView> {
  ActivityStatus? _selectedStatus;
  late final Future<_ActivityFormOptions> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadActivityFormOptions(widget.nursingHomeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<ActivitiesBloc>().add(
              FetchTodayActivitiesEvent(nursingHomeId: widget.nursingHomeId),
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: AppCapabilities.isReadOnly
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateActivitySheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear'),
            ),
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          if (state is ActivitiesLoaded && state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is ActivitiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ActivitiesError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<ActivitiesBloc>().add(
                FetchTodayActivitiesEvent(nursingHomeId: widget.nursingHomeId),
              ),
            );
          }

          final activities = switch (state) {
            ActivitiesLoaded(:final todayActivities) => todayActivities,
            ActivitiesActionInProgress(:final todayActivities) =>
              todayActivities,
            _ => const <Activity>[],
          };

          final filtered = _selectedStatus == null
              ? activities
              : activities
                    .where((activity) => activity.status == _selectedStatus)
                    .toList();

          return FutureBuilder<_ActivityFormOptions>(
            future: _optionsFuture,
            builder: (context, snapshot) {
              final residentsById = {
                for (final resident in snapshot.data?.residents ?? <Resident>[])
                  resident.id: resident.fullName,
                for (final resident in snapshot.data?.residents ?? <Resident>[])
                  if (resident.personProfileId > 0)
                    resident.personProfileId: resident.fullName,
              };
              final staffById = {
                for (final staff in snapshot.data?.staff ?? <StaffMember>[])
                  staff.id: staff.fullName,
                for (final staff in snapshot.data?.staff ?? <StaffMember>[])
                  if (staff.personProfileId > 0)
                    staff.personProfileId: staff.fullName,
              };

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ActivitiesBloc>().add(
                    FetchTodayActivitiesEvent(
                      nursingHomeId: widget.nursingHomeId,
                    ),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _ActivitySummary(activities: activities),
                    const SizedBox(height: 16),
                    _StatusFilters(
                      selectedStatus: _selectedStatus,
                      onChanged: (status) {
                        setState(() => _selectedStatus = status);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const LinearProgressIndicator(),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const SizedBox(height: 12),
                    if (state is ActivitiesActionInProgress)
                      const LinearProgressIndicator(),
                    if (state is ActivitiesActionInProgress)
                      const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const _EmptyState()
                    else
                      ...filtered.map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActivityCard(
                            activity: activity,
                            residentName: residentsById[activity.residentId],
                            staffName: staffById[activity.healthcareStaffId],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateActivitySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ActivitiesBloc>(),
        child: _CreateActivitySheet(nursingHomeId: widget.nursingHomeId),
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  final List<Activity> activities;

  const _ActivitySummary({required this.activities});

  @override
  Widget build(BuildContext context) {
    final pending = activities
        .where((activity) => activity.status == ActivityStatus.pending)
        .length;
    final inProgress = activities
        .where((activity) => activity.status == ActivityStatus.inProgress)
        .length;
    final completed = activities
        .where((activity) => activity.status == ActivityStatus.completed)
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Pendientes',
            value: pending.toString(),
            icon: Icons.schedule_outlined,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'En curso',
            value: inProgress.toString(),
            icon: Icons.play_circle_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryTile(
            label: 'Completadas',
            value: completed.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final ActivityStatus? selectedStatus;
  final ValueChanged<ActivityStatus?> onChanged;

  const _StatusFilters({required this.selectedStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Todas',
            selected: selectedStatus == null,
            onSelected: () => onChanged(null),
          ),
          _FilterChip(
            label: 'Pendientes',
            selected: selectedStatus == ActivityStatus.pending,
            onSelected: () => onChanged(ActivityStatus.pending),
          ),
          _FilterChip(
            label: 'En curso',
            selected: selectedStatus == ActivityStatus.inProgress,
            onSelected: () => onChanged(ActivityStatus.inProgress),
          ),
          _FilterChip(
            label: 'Completadas',
            selected: selectedStatus == ActivityStatus.completed,
            onSelected: () => onChanged(ActivityStatus.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final String? residentName;
  final String? staffName;

  const _ActivityCard({
    required this.activity,
    this.residentName,
    this.staffName,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(activity.status);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(status.icon, color: status.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_typeLabel(activity.type)} · ${residentName ?? 'Residente no encontrado'} · ${staffName ?? 'Personal no encontrado'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: activity.status),
              ],
            ),
            if (activity.isRecurring) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Chip(
                    avatar: Icon(Icons.repeat, size: 16),
                    label: Text('Recurrente'),
                  ),
                  ...activity.recurringDays.map(
                    (day) => Chip(label: Text(_dayLabel(day))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Esta actividad es una plantilla recurrente. No se completa desde aqui para no cerrar toda la recurrencia.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ActivityStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final presentation = _statusPresentation(status);

    return Chip(
      label: Text(
        presentation.label,
        style: TextStyle(
          color: presentation.color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: presentation.color.withValues(alpha: 0.10),
      side: BorderSide.none,
    );
  }
}

class _CreateActivitySheet extends StatefulWidget {
  final int nursingHomeId;

  const _CreateActivitySheet({required this.nursingHomeId});

  @override
  State<_CreateActivitySheet> createState() => _CreateActivitySheetState();
}

class _CreateActivitySheetState extends State<_CreateActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  late final Future<_ActivityFormOptions> _optionsFuture;
  int? _residentId;
  int? _staffId;
  String _type = 'RECREATIONAL';
  bool _isRecurring = false;
  final Set<String> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadActivityFormOptions(widget.nursingHomeId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nueva actividad',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  prefixIcon: Icon(Icons.event_note_outlined),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'MEAL', child: Text('Comida')),
                  DropdownMenuItem(value: 'BATH', child: Text('Baño')),
                  DropdownMenuItem(
                    value: 'RISK_PROFILE',
                    child: Text('Perfil de riesgo'),
                  ),
                  DropdownMenuItem(
                    value: 'RECREATIONAL',
                    child: Text('Recreativa'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              FutureBuilder<_ActivityFormOptions>(
                future: _optionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }

                  final options = snapshot.data!;
                  return Column(
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _residentId,
                        decoration: const InputDecoration(
                          labelText: 'Residente',
                          prefixIcon: Icon(Icons.elderly_outlined),
                        ),
                        items: options.residents
                            .map(
                              (resident) => DropdownMenuItem(
                                value: resident.id,
                                child: Text(resident.fullName),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null ? 'Required' : null,
                        onChanged: options.residents.isEmpty
                            ? null
                            : (value) => setState(() => _residentId = value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _staffId,
                        decoration: const InputDecoration(
                          labelText: 'Personal responsable',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: options.staff
                            .map(
                              (staff) => DropdownMenuItem(
                                value: staff.id,
                                child: Text(
                                  '${staff.fullName} · ${staff.role}',
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) => value == null ? 'Required' : null,
                        onChanged: options.staff.isEmpty
                            ? null
                            : (value) => setState(() => _staffId = value),
                      ),
                      if (options.residents.isEmpty || options.staff.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            options.residents.isEmpty
                                ? 'Primero registra residentes para crear actividades.'
                                : 'Primero registra personal activo para asignar actividades.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Actividad recurrente'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    if (!value) _selectedDays.clear();
                  });
                },
              ),
              if (_isRecurring)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dayOptions
                      .map(
                        (day) => FilterChip(
                          label: Text(_dayLabel(day)),
                          selected: _selectedDays.contains(day),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Crear actividad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_residentId == null || _staffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona residente y personal.')),
      );
      return;
    }
    if (_isRecurring && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un dia.')),
      );
      return;
    }

    context.read<ActivitiesBloc>().add(
      CreateActivityEvent(
        nursingHomeId: widget.nursingHomeId,
        residentId: _residentId!,
        healthcareStaffId: _staffId!,
        type: _type,
        title: _titleController.text,
        isRecurring: _isRecurring,
        recurringDays: _selectedDays.toList(),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ActivityFormOptions {
  final List<Resident> residents;
  final List<StaffMember> staff;

  const _ActivityFormOptions({required this.residents, required this.staff});
}

Future<_ActivityFormOptions> _loadActivityFormOptions(int nursingHomeId) async {
  final nursingRepository = locator<INursingRepository>();
  final staffRepository = locator<IStaffRepository>();

  final residentsResult = await nursingRepository.getResidents(nursingHomeId);
  final staffResult = await staffRepository.getStaffByNursingHome(
    nursingHomeId,
  );

  final residents = residentsResult.fold<List<Resident>>(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
  final staff = staffResult.fold<List<StaffMember>>(
    (failure) => throw Exception(failure.message),
    (data) => data.where((member) => member.isActive).toList(),
  );

  return _ActivityFormOptions(residents: residents, staff: staff);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: Text('No hay actividades para mostrar.')),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPresentation {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });
}

_StatusPresentation _statusPresentation(ActivityStatus status) {
  return switch (status) {
    ActivityStatus.pending => const _StatusPresentation(
      label: 'Pendiente',
      icon: Icons.schedule_outlined,
      color: Colors.orange,
    ),
    ActivityStatus.inProgress => const _StatusPresentation(
      label: 'En curso',
      icon: Icons.play_circle_outline,
      color: Colors.blue,
    ),
    ActivityStatus.completed => const _StatusPresentation(
      label: 'Completada',
      icon: Icons.check_circle_outline,
      color: Colors.green,
    ),
    ActivityStatus.cancelled => const _StatusPresentation(
      label: 'Cancelada',
      icon: Icons.cancel_outlined,
      color: Colors.red,
    ),
  };
}

String _typeLabel(String type) {
  return switch (type.toUpperCase()) {
    'MEAL' => 'Comida',
    'BATH' => 'Baño',
    'RISK_PROFILE' => 'Perfil de riesgo',
    'RECREATIONAL' => 'Recreativa',
    _ => type,
  };
}

String _dayLabel(String day) {
  return switch (day.toUpperCase()) {
    'MON' => 'Lun',
    'TUE' => 'Mar',
    'WED' => 'Mie',
    'THU' => 'Jue',
    'FRI' => 'Vie',
    'SAT' => 'Sab',
    'SUN' => 'Dom',
    'MONDAY' => 'Lun',
    'TUESDAY' => 'Mar',
    'WEDNESDAY' => 'Mie',
    'THURSDAY' => 'Jue',
    'FRIDAY' => 'Vie',
    'SATURDAY' => 'Sab',
    'SUNDAY' => 'Dom',
    _ => day,
  };
}

const _dayOptions = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
