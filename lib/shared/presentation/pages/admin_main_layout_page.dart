import 'package:flutter/material.dart';

import '../../../account/presentation/pages/profile_page.dart';
import '../../../activities/presentation/pages/activities_page.dart';
import '../../../hcm/presentation/pages/staff_directory_page.dart';
import '../../../nursing/presentation/pages/admin_dashboard_page.dart';
import '../../../nursing/presentation/pages/resident_directory_page.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../theme/app_colors.dart';

class AdminMainLayoutPage extends StatefulWidget {
  const AdminMainLayoutPage({super.key, required this.nursingHomeId});

  final int nursingHomeId;

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

    final userId = TokenManager.getUserId() ?? 0;
    final administratorId = TokenManager.getAdministratorId() ?? 0;

    _pageBuilders = [
      (_) => AdminDashboardPage(
        nursingHomeId: widget.nursingHomeId,
        onOpenStaffDirectory: () => _selectTab(2),
      ),
      (_) => ResidentDirectoryPage(nursingHomeId: widget.nursingHomeId),
      (_) => StaffDirectoryPage(nursingHomeId: widget.nursingHomeId),
      (_) => ActivitiesPage(nursingHomeId: widget.nursingHomeId),
      (_) => ProfilePage(userId: userId, administratorId: administratorId),
    ];

    _pages = List<Widget?>.filled(_pageBuilders.length, null);
    _pages[_currentIndex] = _pageBuilders[_currentIndex](context);
  }

  void _selectTab(int index) {
    setState(() {
      _pages[index] ??= _pageBuilders[index](context);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [for (final page in _pages) page ?? const SizedBox.shrink()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppColors.softShadow,
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Summary',
              ),
              NavigationDestination(
                icon: Icon(Icons.elderly_outlined),
                selectedIcon: Icon(Icons.elderly_rounded),
                label: 'Residents',
              ),
              NavigationDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge_rounded),
                label: 'Staff',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note_rounded),
                label: 'Agenda',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
