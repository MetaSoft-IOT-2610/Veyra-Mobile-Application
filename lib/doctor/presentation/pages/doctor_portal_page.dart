import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../iam/presentation/pages/login_page.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../bloc/doctor_bloc.dart';
import 'doctor_resident_page.dart';

class DoctorPortalPage extends StatefulWidget {
  final int staffId;
  final int nursingHomeId;

  const DoctorPortalPage({
    super.key,
    required this.staffId,
    required this.nursingHomeId,
  });

  @override
  State<DoctorPortalPage> createState() => _DoctorPortalPageState();
}

class _DoctorPortalPageState extends State<DoctorPortalPage> {
  late final DoctorBloc _bloc;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _bloc = locator<DoctorBloc>()
      ..add(LoadDoctorResidentsEvent(widget.nursingHomeId));
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
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F8),
        appBar: AppBar(
          title: const Text('Clinical Portal'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _bloc.add(
                LoadDoctorResidentsEvent(widget.nursingHomeId),
              ),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorInitial || state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DoctorError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => _bloc.add(
                  LoadDoctorResidentsEvent(widget.nursingHomeId),
                ),
              );
            }

            final residents = (state as DoctorResidentsLoaded).residents;
            return IndexedStack(
              index: _selectedIndex,
              children: [
                _DoctorOverview(
                  staffId: widget.staffId,
                  residents: residents,
                  onOpenDirectory: () => setState(() => _selectedIndex = 1),
                ),
                _ResidentDirectory(
                  residents: residents,
                  nursingHomeId: widget.nursingHomeId,
                ),
              ],
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
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Residents',
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorOverview extends StatelessWidget {
  final int staffId;
  final List<Resident> residents;
  final VoidCallback onOpenDirectory;

  const _DoctorOverview({
    required this.staffId,
    required this.residents,
    required this.onOpenDirectory,
  });

  @override
  Widget build(BuildContext context) {
    final active = residents
        .where((resident) => resident.status.toUpperCase() == 'ACTIVE')
        .length;
    final withoutRoom = residents.where((resident) => resident.roomId == null).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF176B70),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xFF176B70),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clinical workspace',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Staff record #$staffId',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Residents',
                value: residents.length.toString(),
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                label: 'Active',
                value: active.toString(),
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricTile(
          label: 'Room assignment pending',
          value: withoutRoom.toString(),
          icon: Icons.meeting_room_outlined,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onOpenDirectory,
          icon: const Icon(Icons.folder_shared_outlined),
          label: const Text('Open resident directory'),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF176B70)),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResidentDirectory extends StatelessWidget {
  final List<Resident> residents;
  final int nursingHomeId;

  const _ResidentDirectory({
    required this.residents,
    required this.nursingHomeId,
  });

  @override
  Widget build(BuildContext context) {
    if (residents.isEmpty) {
      return const Center(child: Text('No residents registered.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: residents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final resident = residents[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                resident.firstName.isEmpty
                    ? '?'
                    : resident.firstName[0].toUpperCase(),
              ),
            ),
            title: Text(resident.fullName),
            subtitle: Text(
              resident.roomId == null
                  ? 'Room pending'
                  : 'Room ${resident.roomId}',
            ),
            trailing: const Icon(Icons.chevron_right),
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
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
