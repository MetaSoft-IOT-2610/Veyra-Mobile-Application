import 'package:flutter/material.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../domain/entities/activity.dart';

class ActivityFilters extends StatelessWidget {
  const ActivityFilters({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ActivityStatus? selected;
  final ValueChanged<ActivityStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <(String, ActivityStatus?)>[
      ('Todas', null),
      ('Pendientes', ActivityStatus.pending),
      ('En curso', ActivityStatus.inProgress),
      ('Completadas', ActivityStatus.completed),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(option.$1),
                  selected: selected == option.$2,
                  selectedColor: AppColors.primaryLight,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    color: selected == option.$2
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => onChanged(option.$2),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
