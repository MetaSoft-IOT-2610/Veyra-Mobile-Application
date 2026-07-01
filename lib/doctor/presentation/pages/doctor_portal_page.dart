import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../iam/presentation/pages/login_page.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../bloc/doctor_bloc.dart';
import '../widgets/doctor_portal/doctor_error_view.dart';
import '../widgets/doctor_portal/doctor_overview.dart';
import '../widgets/doctor_portal/resident_directory.dart';

class DoctorPortalPage extends StatefulWidget {
  const DoctorPortalPage({
    super.key,
    required this.staffId,
    required this.nursingHomeId,
  });

  final int staffId;
  final int nursingHomeId;

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

  void _refreshResidents() {
    _bloc.add(LoadDoctorResidentsEvent(widget.nursingHomeId));
  }

  void _signOut() {
    TokenManager.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _changeTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FA),
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Portal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Resident Services',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _refreshResidents,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (context, state) {
            if (state is DoctorInitial || state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorError) {
              return DoctorErrorView(
                message: state.message,
                onRetry: _refreshResidents,
              );
            }

            if (state is! DoctorResidentsLoaded) {
              return DoctorErrorView(
                message: 'Unexpected clinical portal state.',
                onRetry: _refreshResidents,
              );
            }

            final residents = state.residents;

            return IndexedStack(
              index: _selectedIndex,
              children: [
                DoctorOverview(
                  staffId: widget.staffId,
                  residents: residents,
                  onOpenDirectory: () => _changeTab(1),
                ),
                ResidentDirectory(
                  residents: residents,
                  nursingHomeId: widget.nursingHomeId,
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: NavigationBar(
          height: 74,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDFF3F2),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Residents',
            ),
          ],
        ),
      ),
    );
  }
}
