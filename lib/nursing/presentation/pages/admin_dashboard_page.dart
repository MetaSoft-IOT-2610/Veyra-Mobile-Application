import 'package:flutter/material.dart';
import 'package:veyra_mobile_app/analytics/presentation/widgets/analytics_dashboard_widget.dart';
import 'package:veyra_mobile_app/activities/presentation/widgets/today_activities_widget.dart';
//import 'package:veyra_mobile_app/hcm/presentation/widgets/active_staff_widget.dart';
import 'package:veyra_mobile_app/nursing/presentation/widgets/resident_summary_widget.dart';

class AdminDashboardPage extends StatelessWidget {
  final int nursingHomeId;

  const AdminDashboardPage({
    Key? key,
    required this.nursingHomeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Visión General de la Residencia'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ResidentSummaryWidget(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 24),

                  AnalyticsDashboardWidget(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 24),

                  TodayActivitiesWidget(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 24),

                  //ActiveStaffWidget(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}