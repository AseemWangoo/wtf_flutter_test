import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/scheduler_utils.dart';

class TimeSlotChips extends StatelessWidget {
  const TimeSlotChips({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
    this.primary,
  });

  final List<DateTime> slots;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;
  final Color? primary;

  @override
  Widget build(BuildContext context) {
    final color = primary ?? Theme.of(context).colorScheme.primary;
    if (slots.isEmpty) {
      return Text(
        'No slots available for this day.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral700,
            ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = selected != null &&
            slot.year == selected!.year &&
            slot.month == selected!.month &&
            slot.day == selected!.day &&
            slot.hour == selected!.hour &&
            slot.minute == selected!.minute;
        return ChoiceChip(
          label: Text(formatScheduleTime(slot)),
          selected: isSelected,
          onSelected: (_) => onSelected(slot),
          selectedColor: color.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: isSelected ? color : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}
