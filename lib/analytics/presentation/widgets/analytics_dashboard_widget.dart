import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import 'analytics_error_view.dart';

class AnalyticsDashboardWidget extends StatelessWidget {
  const AnalyticsDashboardWidget({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (_) =>
          locator<AnalyticsBloc>()
            ..add(LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is AnalyticsError) {
            return AnalyticsErrorView(
              message: state.message,
              onRetry: () => context.read<AnalyticsBloc>().add(
                LoadOperationalMetricsEvent(nursingHomeId: nursingHomeId),
              ),
            );
          }
          return state is AnalyticsLoaded
              ? _MetricsGrid(state: state)
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.state});

  final AnalyticsLoaded state;

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
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            _MetricCard(
              'Incoming',
              '${state.admissionsCount}',
              Icons.login_rounded,
            ),
            _MetricCard(
              'New Hires',
              '${state.hiresCount}',
              Icons.person_add_alt_outlined,
            ),
            _MetricCard(
              'Terminations',
              '${state.terminationsCount}',
              Icons.person_remove_alt_1_outlined,
              warning: state.terminationsCount > 0,
            ),
            _MetricCard(
              'Turnover',
              '$turnover%',
              Icons.sync_alt_rounded,
              warning: turnover > 80,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _BalanceTile(balance: balance),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.label, this.value, this.icon, {this.warning = false});

  final String label;
  final String value;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.primary;
    final background = warning ? AppColors.warningSoft : AppColors.primaryLight;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final stable = balance >= 0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(
          stable ? Icons.check_circle_outline : Icons.warning_amber,
          color: stable ? AppColors.success : AppColors.warning,
        ),
        title: Text(
          stable ? 'Stable coverage' : 'Review coverage',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          stable
              ? '$balance net contracts this year'
              : '${balance.abs()} terminations more than new hires',
        ),
      ),
    );
  }
}
