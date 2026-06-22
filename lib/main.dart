import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/di/dependency_injection.dart';
import 'app/observers/app_bloc_observer.dart';
import 'iam/presentation/pages/login_page.dart';
import 'shared/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Bloc.observer = AppBlocObserver();

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
      home: const LoginPage(),
    );
  }
}
