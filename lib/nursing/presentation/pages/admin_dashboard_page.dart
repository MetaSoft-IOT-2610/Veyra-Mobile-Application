import 'package:flutter/material.dart';

import '../../../activities/presentation/widgets/today_activities_widget.dart';
import '../../../analytics/presentation/widgets/analytics_dashboard_widget.dart';
import '../../../hcm/presentation/widgets/active_staff_widget.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/dashboard_section.dart';
import '../widgets/resident_summary_widget.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
    required this.nursingHomeId,
    this.onOpenStaffDirectory,
  });

  final int nursingHomeId;
  final VoidCallback? onOpenStaffDirectory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const _DashboardAppBarTitle()),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.list(
              children: [
                DashboardHeader(nursingHomeId: nursingHomeId),
                const SizedBox(height: 20),
                ResidentSummaryWidget(nursingHomeId: nursingHomeId),
                const SizedBox(height: 16),
                DashboardSection(
                  title: 'Operational Analysis',
                  subtitle: 'Revenue, New Hires, and Staff Turnover',
                  icon: Icons.insights_outlined,
                  initiallyExpanded: true,
                  child: AnalyticsDashboardWidget(nursingHomeId: nursingHomeId),
                ),
                const SizedBox(height: 12),
                DashboardSection(
                  title: 'Today\'s Activities',
                  subtitle: 'Daily schedule of the nursing home',
                  icon: Icons.event_available_outlined,
                  initiallyExpanded: true,
                  child: TodayActivitiesWidget(nursingHomeId: nursingHomeId),
                ),
                const SizedBox(height: 12),
                DashboardSection(
                  title: 'Active Staff',
                  subtitle: 'Available staff in the nursing home',
                  icon: Icons.medical_services_outlined,
                  child: ActiveStaffWidget(
                    nursingHomeId: nursingHomeId,
                    onViewDirectory: onOpenStaffDirectory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAppBarTitle extends StatelessWidget {
  const _DashboardAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Clinical Summary'),
        SizedBox(height: 2),
        Text(
          'Operations Center',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
