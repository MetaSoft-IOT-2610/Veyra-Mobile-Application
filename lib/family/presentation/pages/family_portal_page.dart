import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activities/domain/entities/activity.dart';
import '../../../app/di/dependency_injection.dart';
import '../../../iam/presentation/pages/login_page.dart';
import '../../../nursing/domain/entities/resident_health_record.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../../domain/entities/family_portal_data.dart';
import '../bloc/family_portal_bloc.dart';

class FamilyPortalPage extends StatefulWidget {
  const FamilyPortalPage({super.key});

  @override
  State<FamilyPortalPage> createState() => _FamilyPortalPageState();
}

class _FamilyPortalPageState extends State<FamilyPortalPage> {
  int _selectedIndex = 0;
  late final FamilyPortalBloc _bloc;
  late final int _userId;

  @override
  void initState() {
    super.initState();
    _userId = TokenManager.getUserId() ?? 0;
    _bloc = locator<FamilyPortalBloc>()..add(LoadFamilyPortalEvent(_userId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _signOut() {
    TokenManager.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Family Portal'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _bloc.add(LoadFamilyPortalEvent(_userId)),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<FamilyPortalBloc, FamilyPortalState>(
          builder: (context, state) {
            if (state is FamilyPortalLoading || state is FamilyPortalInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FamilyPortalUnlinked) {
              return _MessageState(
                icon: Icons.person_search_outlined,
                title: 'No resident assigned',
                message:
                    'The nursing home administrator must link your account to a resident before information appears here.',
                onRetry: () => _bloc.add(LoadFamilyPortalEvent(_userId)),
              );
            }
            if (state is FamilyPortalError) {
              return _MessageState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load portal',
                message: state.message,
                onRetry: () => _bloc.add(LoadFamilyPortalEvent(_userId)),
              );
            }

            final data = (state as FamilyPortalLoaded).data;
            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(LoadFamilyPortalEvent(_userId));
              },
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _OverviewView(data: data),
                  _HealthView(data: data),
                  _ActivitiesView(data: data),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              selectedIcon: Icon(Icons.monitor_heart),
              label: 'Health',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Activities',
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  final FamilyPortalData data;

  const _OverviewView({required this.data});

  @override
  Widget build(BuildContext context) {
    final resident = data.resident;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF146C94),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.elderly, size: 34, color: Color(0xFF146C94)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resident.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resident.roomId == null
                          ? 'Room pending'
                          : 'Room ${resident.roomId}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: resident.status),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Resident information',
          icon: Icons.badge_outlined,
          children: [
            _DetailRow(label: 'Admission', value: resident.admissionDate),
            _DetailRow(
              label: 'Emergency contact',
              value: resident.emergencyContactName,
            ),
            _DetailRow(
              label: 'Emergency phone',
              value: resident.emergencyContactPhoneNumber,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Current summary',
          icon: Icons.insights_outlined,
          children: [
            _DetailRow(
              label: 'Allergies',
              value: data.allergies.length.toString(),
            ),
            _DetailRow(
              label: 'Medical conditions',
              value: data.medicalConditions.length.toString(),
            ),
            _DetailRow(
              label: 'Activities',
              value: data.activities.length.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

class _HealthView extends StatelessWidget {
  final FamilyPortalData data;

  const _HealthView({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _HealthSection<ResidentVitalSign>(
          title: 'Vital signs',
          icon: Icons.monitor_heart_outlined,
          items: data.vitalSigns,
          emptyText: 'No vital signs recorded.',
          itemBuilder: (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.measurementId),
            trailing: _StatusBadge(text: item.severityLevel),
          ),
        ),
        const SizedBox(height: 12),
        _HealthSection<ResidentAllergy>(
          title: 'Allergies',
          icon: Icons.warning_amber_outlined,
          items: data.allergies,
          emptyText: 'No allergies registered.',
          itemBuilder: (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.allergenName),
            subtitle: Text('${item.typeOfAllergy} - ${item.reaction}'),
            trailing: _StatusBadge(text: item.severityLevel),
          ),
        ),
        const SizedBox(height: 12),
        _HealthSection<ResidentMedicalCondition>(
          title: 'Medical conditions',
          icon: Icons.medical_information_outlined,
          items: data.medicalConditions,
          emptyText: 'No medical conditions registered.',
          itemBuilder: (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.diagnosisName),
            subtitle: Text('${item.diagnosisDate}\n${item.notes}'),
            isThreeLine: item.notes.isNotEmpty,
            trailing: _StatusBadge(text: item.status),
          ),
        ),
      ],
    );
  }
}

class _ActivitiesView extends StatelessWidget {
  final FamilyPortalData data;

  const _ActivitiesView({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.activities.isEmpty) {
      return const _EmptyList(
        icon: Icons.event_busy_outlined,
        message: 'No activities scheduled for this resident.',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: data.activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final activity = data.activities[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.event_available)),
            title: Text(activity.title),
            subtitle: Text(
              activity.isRecurring && activity.recurringDays.isNotEmpty
                  ? '${activity.type} - ${activity.recurringDays.join(', ')}'
                  : activity.type,
            ),
            trailing: _StatusBadge(text: _activityStatus(activity.status)),
          ),
        );
      },
    );
  }

  String _activityStatus(ActivityStatus status) {
    return switch (status) {
      ActivityStatus.pending => 'PENDING',
      ActivityStatus.inProgress => 'IN PROGRESS',
      ActivityStatus.completed => 'COMPLETED',
      ActivityStatus.cancelled => 'CANCELLED',
    };
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF146C94)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

class _HealthSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final String emptyText;
  final Widget Function(T item) itemBuilder;

  const _HealthSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      icon: icon,
      children: items.isEmpty
          ? [Padding(padding: const EdgeInsets.all(8), child: Text(emptyText))]
          : items.map(itemBuilder).toList(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.trim().isEmpty ? 'Not available' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;

  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyList({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 64, color: Colors.blueGrey),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}
