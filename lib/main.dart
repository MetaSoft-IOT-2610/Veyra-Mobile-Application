import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/di/dependency_injection.dart';
import 'app/observers/app_bloc_observer.dart';
import 'nursing/presentation/pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await initDependencies();

  runApp(const VeyraEnterpriseApp());
}

class VeyraEnterpriseApp extends StatelessWidget {
  const VeyraEnterpriseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <-- Agrega esta línea
      title: 'Veyra Enterprise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AdminDashboardPage(nursingHomeId: 1),
    );
  }
}
