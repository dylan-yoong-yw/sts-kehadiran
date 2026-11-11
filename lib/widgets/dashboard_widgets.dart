import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Shared rounded surface used by the dashboard and login cards.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
  });

  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Card(
      color: color,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// A quick action adapts from an icon row to a column on narrow screens.
class DashboardAction extends StatelessWidget {
  const DashboardAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconCircle = Container(
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: Color(0xFFD9F6EC),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF29A884), size: 20),
    );
    final text = Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 3,
        shadowColor: const Color(0x300D483A),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 95 ||
                    MediaQuery.textScalerOf(context).scale(13) > 18) {
                  return Column(
                    children: [iconCircle, const SizedBox(height: 8), text],
                  );
                }
                return Row(
                  children: [
                    iconCircle,
                    const SizedBox(width: 8),
                    Expanded(child: text),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
