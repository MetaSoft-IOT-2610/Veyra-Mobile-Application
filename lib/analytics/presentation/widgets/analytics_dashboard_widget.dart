import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra_mobile_app/analytics/presentation/bloc/analytics_state.dart'
    show AnalyticsState, AnalyticsLoaded, AnalyticsLoading, AnalyticsError;
import 'package:veyra_mobile_app/app/di/dependency_injection.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';

class AnalyticsDashboardWidget extends StatelessWidget {
  final int nursingHomeId;

  const AnalyticsDashboardWidget({super.key, required this.nursingHomeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (context) =>
          locator<AnalyticsBloc>()
            ..add(LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Análisis Operativo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => context.read<AnalyticsBloc>().add(
                      LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId),
                    ),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state is AnalyticsLoading)
                const Center(child: CircularProgressIndicator()),
              if (state is AnalyticsError)
                Card(
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.error, color: Colors.red),
                    title: Text('Error cargando métricas: ${state.message}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<AnalyticsBloc>().add(
                        LoadOperationalMetricsEvent(
                          nursingHomeId: nursingHomeId,
                        ),
                      ),
                    ),
                  ),
                ),
              if (state is AnalyticsLoaded) _MetricsGrid(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final AnalyticsLoaded state;

  const _MetricsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final turnover = state.hiresCount == 0
        ? (state.terminationsCount > 0 ? 100 : 0)
        : ((state.terminationsCount / state.hiresCount) * 100).round();
    final balance = state.hiresCount - state.terminationsCount;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.55,
          children: [
            _MetricCard(
              title: 'Ingresos residentes',
              value: state.admissionsCount.toString(),
              icon: Icons.elderly,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'Altas staff',
              value: state.hiresCount.toString(),
              icon: Icons.badge_outlined,
              color: Colors.green,
            ),
            _MetricCard(
              title: 'Bajas staff',
              value: state.terminationsCount.toString(),
              icon: Icons.person_remove_alt_1_outlined,
              color: state.terminationsCount > 0 ? Colors.orange : Colors.green,
            ),
            _MetricCard(
              title: 'Rotación',
              value: '$turnover%',
              icon: Icons.trending_down,
              color: turnover > 80 ? Colors.red : Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(
              balance >= 0 ? Icons.trending_up : Icons.warning_amber_outlined,
              color: balance >= 0 ? Colors.green : Colors.orange,
            ),
            title: Text(balance >= 0 ? 'Staff estable' : 'Revisar cobertura'),
            subtitle: Text(
              balance >= 0
                  ? 'Hay $balance contratos netos en el año.'
                  : 'Hay ${balance.abs()} bajas más que altas en el año.',
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
