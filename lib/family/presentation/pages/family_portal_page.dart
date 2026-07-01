import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../iam/presentation/pages/login_page.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../../../shared/presentation/widgets/clinical_state_view.dart';
import '../bloc/family_portal_bloc.dart';
import '../widgets/family_portal/family_activities_view.dart';
import '../widgets/family_portal/family_health_view.dart';
import '../widgets/family_portal/family_overview_view.dart';

class FamilyPortalPage extends StatefulWidget {
  const FamilyPortalPage({super.key});

  @override
  State<FamilyPortalPage> createState() => _FamilyPortalPageState();
}

class _FamilyPortalPageState extends State<FamilyPortalPage> {
  int _selectedIndex = 0;
  late final FamilyPortalBloc _bloc;
  late final int _userId;

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _userId = TokenManager.getUserId() ?? 0;
    _bloc = locator<FamilyPortalBloc>()..add(LoadFamilyPortalEvent(_userId));

    _pollingTimer = Timer.periodic(const Duration(seconds: 50), (timer) {
      if (!_bloc.isClosed) {
        _bloc.add(PollMeasurementsEvent());
      }
    });
  }

  @override
  void dispose() {

    _pollingTimer?.cancel();
    _bloc.close();
    super.dispose();
  }

  void _refresh() => _bloc.add(LoadFamilyPortalEvent(_userId));

  void _signOut() {
    TokenManager.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mi familiar'),
              SizedBox(height: 2),
              Text(
                'Informacion de cuidado',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Cerrar sesion',
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<FamilyPortalBloc, FamilyPortalState>(
          builder: (context, state) {
            if (state is FamilyPortalLoading || state is FamilyPortalInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FamilyPortalUnlinked) {
              return ClinicalStateView(
                icon: Icons.person_search_outlined,
                title: 'Sin residente asignado',
                message:
                    'La residencia debe vincular tu cuenta con un residente.',
                onRetry: _refresh,
              );
            }
            if (state is FamilyPortalError) {
              return ClinicalStateView(
                icon: Icons.cloud_off_outlined,
                title: 'No se pudo cargar la informacion',
                message: state.message,
                isError: true,
                onRetry: _refresh,
              );
            }

            final data = (state as FamilyPortalLoaded).data;
            return IndexedStack(
              index: _selectedIndex,
              children: [
                FamilyOverviewView(data: data),
                FamilyHealthView(data: data),
                FamilyActivitiesView(data: data),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Resumen',
                ),
                NavigationDestination(
                  icon: Icon(Icons.monitor_heart_outlined),
                  selectedIcon: Icon(Icons.monitor_heart_rounded),
                  label: 'Salud',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_note_outlined),
                  selectedIcon: Icon(Icons.event_note_rounded),
                  label: 'Actividades',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
