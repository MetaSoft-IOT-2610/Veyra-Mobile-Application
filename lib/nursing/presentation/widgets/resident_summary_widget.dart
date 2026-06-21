import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../shared/presentation/theme/app_colors.dart';
import '../bloc/nursing_bloc.dart';

class ResidentSummaryWidget extends StatelessWidget {
  const ResidentSummaryWidget({super.key, required this.nursingHomeId});

  final int nursingHomeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NursingBloc>(
      create: (_) =>
          locator<NursingBloc>()
            ..add(LoadResidentSummaryEvent(nursingHomeId: nursingHomeId)),
      child: BlocBuilder<NursingBloc, NursingState>(
        builder: (context, state) {
          if (state is NursingLoading) return const _LoadingCard();
          if (state is NursingError) return _ErrorCard(message: state.message);
          if (state is! NursingSummaryLoaded) return const SizedBox.shrink();

          final summary = state.summary;
          return _SummaryCard(
            residents: summary.totalResidents.toString(),
            rooms: summary.availableRooms.toString(),
            occupancy: '${summary.occupancyRate.toStringAsFixed(1)}%',
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.residents,
    required this.rooms,
    required this.occupancy,
  });

  final String residents;
  final String rooms;
  final String occupancy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _TitleIcon(),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Censo actual',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'EN VIVO',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Metric('Residentes', residents, Icons.elderly_outlined),
              ),
              const _Divider(),
              Expanded(
                child: _Metric('Camas libres', rooms, Icons.bed_outlined),
              ),
              const _Divider(),
              Expanded(
                child: _Metric(
                  'Ocupacion',
                  occupancy,
                  Icons.donut_large_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleIcon extends StatelessWidget {
  const _TitleIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.groups_outlined, color: AppColors.primary),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppColors.clinicalBlue, size: 21),
      const SizedBox(height: 7),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 58,
    child: VerticalDivider(color: AppColors.border),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.dangerSoft,
    child: ListTile(
      leading: const Icon(Icons.error_outline, color: AppColors.danger),
      title: const Text('No se pudo cargar el censo'),
      subtitle: Text(message),
    ),
  );
}
