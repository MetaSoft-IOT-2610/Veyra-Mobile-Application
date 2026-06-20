import 'package:flutter/material.dart';
import 'package:veyra_mobile_app/activities/presentation/widgets/today_activities_widget.dart';
import 'package:veyra_mobile_app/analytics/presentation/widgets/analytics_dashboard_widget.dart';
import 'package:veyra_mobile_app/hcm/presentation/widgets/active_staff_widget.dart';
import 'package:veyra_mobile_app/nursing/presentation/widgets/resident_summary_widget.dart';

class AdminDashboardPage extends StatelessWidget {
  final int nursingHomeId;
  final VoidCallback? onOpenStaffDirectory;

  const AdminDashboardPage({
    super.key,
    required this.nursingHomeId,
    this.onOpenStaffDirectory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Resumen ejecutivo'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _DashboardHeader(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 16),
                  ResidentSummaryWidget(nursingHomeId: nursingHomeId),
                  const SizedBox(height: 16),
                  _DashboardSection(
                    title: 'Analisis operativo',
                    subtitle: 'Ingresos, altas, bajas y rotacion del anio',
                    icon: Icons.insights_outlined,
                    child: AnalyticsDashboardWidget(
                      nursingHomeId: nursingHomeId,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DashboardSection(
                    title: 'Actividades de hoy',
                    subtitle: 'Agenda diaria de la residencia',
                    icon: Icons.event_available_outlined,
                    child: TodayActivitiesWidget(nursingHomeId: nursingHomeId),
                  ),
                  const SizedBox(height: 12),
                  _DashboardSection(
                    title: 'Personal activo',
                    subtitle: 'Equipo disponible y acceso al directorio',
                    icon: Icons.badge_outlined,
                    child: ActiveStaffWidget(
                      nursingHomeId: nursingHomeId,
                      onViewDirectory: onOpenStaffDirectory,
                    ),
                  ),
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

class _DashboardHeader extends StatelessWidget {
  final int nursingHomeId;

  const _DashboardHeader({required this.nursingHomeId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.home_work_outlined, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nursing home #$nursingHomeId',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vista rapida para revisar operacion, agenda y equipo.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        children: [Align(alignment: Alignment.centerLeft, child: child)],
      ),
    );
  }
}
