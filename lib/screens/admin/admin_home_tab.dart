import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/dashboard_widgets.dart';
import '../../widgets/expanding_scroll_view.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/placeholder_page.dart';
import 'agenda_card.dart';

/// The admin's home dashboard (the first tab of [AdminShell]).
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({
    super.key,
    required this.adminName,
    required this.now,
    required this.onOpenSubmissions,
  });

  final String adminName;
  final DateTime now;

  /// Switches to the Attendance Submission tab.
  final VoidCallback onOpenSubmissions;

  static const quickActions = [
    (Icons.fact_check_rounded, 'View Attendance Submission'),
    // Parent/guardian contact for absences (FR-02).
    (Icons.contact_phone_rounded, 'Contact Parents'),
    (Icons.groups, 'Manage Classes'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const gap = SizedBox(height: AppSpacing.section);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        // The agenda card takes any spare height, so Quick Actions sit just
        // above the navigation bar on tall phones; shorter phones scroll.
        child: ExpandingScrollView(
          scrollKey: const Key('admin-home-scroll'),
          expandIndex: 1,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gap,
                const AppHeader(),
                gap,
                GreetingHeader(name: adminName, now: now),
                const SizedBox(height: 20),
              ],
            ),
            AgendaCard(onOpenSubmissions: onOpenSubmissions),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gap,
                Semantics(
                  header: true,
                  child: Text('Quick Actions', style: text.titleMedium),
                ),
                const SizedBox(height: 12),
                QuickActionsGrid(
                  actions: [
                    for (final (icon, label) in quickActions)
                      QuickAction(
                        icon: icon,
                        label: label,
                        onTap: () => PlaceholderPage.open(context, label),
                      ),
                  ],
                ),
                gap,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
