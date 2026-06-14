import 'package:flutter/material.dart';

import '../../../nursing/presentation/pages/admin_dashboard_page.dart';
import '../../../hcm/presentation/pages/staff_directory_page.dart';

/// Main application layout for nursing home administrators.
///
/// This page acts as the primary navigation container after a
/// successful authentication. It provides access to the core
/// modules of the system through a bottom navigation bar.
///
/// Responsibilities:
/// - Maintain the currently selected navigation tab.
/// - Preserve page state while switching tabs.
/// - Provide access to the application's main modules.
/// - Share the active nursing home identifier across modules.
///
/// Available Sections:
/// - Dashboard
/// - Residents
/// - Staff
/// - Activities
/// - Profile
class AdminMainLayoutPage extends StatefulWidget {
  /// Unique identifier of the nursing home currently
  /// associated with the authenticated administrator.
  final int nursingHomeId;

  /// Creates a new [AdminMainLayoutPage].
  ///
  /// The [nursingHomeId] is required to initialize
  /// child modules with the correct organizational context.
  const AdminMainLayoutPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  State<AdminMainLayoutPage> createState() =>
      _AdminMainLayoutPageState();
}

/// State responsible for managing navigation between
/// the application's primary sections.
class _AdminMainLayoutPageState
    extends State<AdminMainLayoutPage> {
  /// Index of the currently selected navigation tab.
  int _currentIndex = 0;

  /// Collection of pages available through the
  /// bottom navigation bar.
  ///
  /// The list is initialized during [initState]
  /// to ensure the nursing home identifier is
  /// properly propagated to child screens.
  late final List<Widget> _pages;

  /// Initializes all application sections.
  ///
  /// Each page receives the current nursing home
  /// identifier when required.
  @override
  void initState() {
    super.initState();

    _pages = [
      /// Dashboard module.
      AdminDashboardPage(
        nursingHomeId: widget.nursingHomeId,
      ),

      /// Residents module placeholder.
      const Center(
        child: Text(
          'Residents Screen (Under Construction)',
        ),
      ),

      /// Staff management module.
      StaffDirectoryPage(
        nursingHomeId: widget.nursingHomeId,
      ),

      /// Activities module placeholder.
      const Center(
        child: Text(
          'Activities Screen (Under Construction)',
        ),
      ),

      /// Profile module placeholder.
      const Center(
        child: Text(
          'Profile Screen (Under Construction)',
        ),
      ),
    ];
  }

  /// Updates the currently selected tab.
  ///
  /// Parameters:
  /// - [index]: Position of the selected navigation item.
  ///
  /// Triggers a UI rebuild to display the corresponding page.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Builds the main application layout.
  ///
  /// Uses an [IndexedStack] to preserve the state of
  /// all pages while switching between tabs.
  ///
  /// Benefits of [IndexedStack]:
  /// - Prevents page recreation.
  /// - Preserves scroll position.
  /// - Maintains BLoC and widget state.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Displays the currently selected page while
      /// preserving the state of all other pages.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      /// Main navigation component.
      ///
      /// Provides access to the application's
      /// primary modules.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: _onTabTapped,

        /// Material 3 styling.
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue.shade100,

        destinations: const [
          /// Dashboard section.
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),

          /// Residents section.
          NavigationDestination(
            icon: Icon(Icons.elderly_outlined),
            selectedIcon: Icon(Icons.elderly),
            label: 'Residents',
          ),

          /// Staff section.
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Staff',
          ),

          /// Activities section.
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Activities',
          ),

          /// User profile section.
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
