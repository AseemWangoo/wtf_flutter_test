import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/scheduler_utils.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelected,
    this.primary,
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final Color? primary;

  @override
  Widget build(BuildContext context) {
    final color = primary ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return ChoiceChip(
            label: Text(formatDayLabel(day)),
            selected: isSelected,
            onSelected: (_) => onSelected(day),
            selectedColor: color.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: isSelected ? color : AppColors.neutral700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }
}
