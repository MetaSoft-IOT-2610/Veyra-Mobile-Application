import 'package:flutter/material.dart';

import '../../../account/presentation/pages/profile_page.dart';
import '../../../activities/presentation/pages/activities_page.dart';
import '../../../hcm/presentation/pages/staff_directory_page.dart';
import '../../../nursing/presentation/pages/admin_dashboard_page.dart';
import '../../../nursing/presentation/pages/resident_directory_page.dart';
import '../../../shared/infrastructure/local/token_manager.dart';

/// Main application layout for nursing home administrators.
///
/// Acts as the navigation shell after a successful authentication.
/// Uses [IndexedStack] to preserve every page's state while switching tabs.
class AdminMainLayoutPage extends StatefulWidget {
  final int nursingHomeId;

  const AdminMainLayoutPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  State<AdminMainLayoutPage> createState() => _AdminMainLayoutPageState();
}

class _AdminMainLayoutPageState extends State<AdminMainLayoutPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // The administrator ID was stored in TokenManager during authentication.
    // It is needed by ProfilePage to query the active subscription.
    final int administratorId = TokenManager.getAdministratorId() ?? 0;

    _pages = [
      AdminDashboardPage(nursingHomeId: widget.nursingHomeId),
      ResidentDirectoryPage(nursingHomeId: widget.nursingHomeId),
      StaffDirectoryPage(nursingHomeId: widget.nursingHomeId),
      ActivitiesPage(nursingHomeId: widget.nursingHomeId),
      ProfilePage(administratorId: administratorId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.elderly_outlined),
            selectedIcon: Icon(Icons.elderly),
            label: 'Residentes',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Personal',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Actividades',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
