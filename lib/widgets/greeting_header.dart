import 'package:flutter/material.dart';

import '../core/date_format.dart';
import '../core/theme.dart';

/// The app title row at the top of each home screen.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.school, size: 28, color: AppColors.darkGreen),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'STS Kehadiran',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.darkGreen),
        ),
      ),
    ],
  );
}

/// "Hello, `name`" with today's date and a date chip.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name, required this.now});

  /// How the user is addressed, e.g. "Mr. Adam".
  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $name', style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                DateFormats.long(now),
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.dateChip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.dateChipIcon,
              ),
              Text(
                DateFormats.dayMonth(now),
                style: text.labelMedium?.copyWith(
                  color: AppColors.dateChipText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
