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
/// Lazily builds each tab the first time it is opened and then preserves its state.
class AdminMainLayoutPage extends StatefulWidget {
  final int nursingHomeId;

  const AdminMainLayoutPage({Key? key, required this.nursingHomeId})
    : super(key: key);

  @override
  State<AdminMainLayoutPage> createState() => _AdminMainLayoutPageState();
}

class _AdminMainLayoutPageState extends State<AdminMainLayoutPage> {
  int _currentIndex = 0;

  late final List<WidgetBuilder> _pageBuilders;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    TokenManager.saveNursingHomeId(widget.nursingHomeId);

    // These IDs are stored during authentication and used by the profile tab.
    final int userId = TokenManager.getUserId() ?? 0;
    final int administratorId = TokenManager.getAdministratorId() ?? 0;

    _pageBuilders = [
      (_) => AdminDashboardPage(nursingHomeId: widget.nursingHomeId),
      (_) => ResidentDirectoryPage(nursingHomeId: widget.nursingHomeId),
      (_) => StaffDirectoryPage(nursingHomeId: widget.nursingHomeId),
      (_) => ActivitiesPage(nursingHomeId: widget.nursingHomeId),
      (_) => ProfilePage(userId: userId, administratorId: administratorId),
    ];
    _pages = List<Widget?>.filled(_pageBuilders.length, null);
    _pages[_currentIndex] = _pageBuilders[_currentIndex](context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [for (final page in _pages) page ?? const SizedBox.shrink()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _pages[index] ??= _pageBuilders[index](context);
            _currentIndex = index;
          });
        },
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
