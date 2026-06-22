import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/di/dependency_injection.dart';
import 'app/observers/app_bloc_observer.dart';
import 'doctor/presentation/pages/doctor_portal_page.dart';
import 'family/presentation/pages/family_portal_page.dart';
import 'iam/presentation/pages/login_page.dart';
import 'shared/infrastructure/local/token_manager.dart';
import 'shared/presentation/pages/admin_main_layout_page.dart';
import 'shared/presentation/pages/setup_required_page.dart';
import 'shared/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await TokenManager.initialize();
  await initDependencies();

  runApp(const VeyraEnterpriseApp());
}

class VeyraEnterpriseApp extends StatelessWidget {
  const VeyraEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veyra Mobile App',
      theme: AppTheme.light,
      home: _initialPage(),
    );
  }

  Widget _initialPage() {
    if (!TokenManager.isAuthenticated) return const LoginPage();

    final roles = TokenManager.getRoles();
    if (roles.contains('ROLE_FAMILIAR')) return const FamilyPortalPage();

    if (roles.contains('ROLE_DOCTOR')) {
      final staffId = TokenManager.getStaffId();
      final nursingHomeId = TokenManager.getNursingHomeId();
      if (staffId != null && nursingHomeId != null) {
        return DoctorPortalPage(staffId: staffId, nursingHomeId: nursingHomeId);
      }
    }

    if (roles.contains('ROLE_ADMIN')) {
      final nursingHomeId = TokenManager.getNursingHomeId();
      if (nursingHomeId != null) {
        return AdminMainLayoutPage(nursingHomeId: nursingHomeId);
      }
      return const SetupRequiredPage();
    }

    return const LoginPage();
  }
}
