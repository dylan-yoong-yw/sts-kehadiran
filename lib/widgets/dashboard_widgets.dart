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

/// One entry in the Quick Actions section.
class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Quick Actions as large tiles side by side, or as full-width rows when the
/// system font is too large for the tiles to hold their labels.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = actions.length;
      final tileWidth = (constraints.maxWidth - _spacing * (count - 1)) / count;
      // A tile must fit its longest word ("Contact", "Reports") at the
      // current font size, plus padding.
      final fitsTiles = tileWidth >= MediaQuery.textScalerOf(context).scale(88);
      if (fitsTiles) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, action) in actions.indexed) ...[
                if (i > 0) const SizedBox(width: _spacing),
                Expanded(child: QuickActionTile(action: action)),
              ],
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, action) in actions.indexed) ...[
            if (i > 0) const SizedBox(height: _spacing),
            QuickActionTile(action: action, compact: true),
          ],
        ],
      );
    },
  );
}

/// A tappable Quick Action: icon above label, or icon beside label when
/// [compact].
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.action,
    this.compact = false,
  });

  final QuickAction action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final icon = Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: const BoxDecoration(
        color: AppColors.mintTint,
        shape: BoxShape.circle,
      ),
      child: Icon(action.icon, size: 28, color: AppColors.accent),
    );
    final content = compact
        ? Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(child: Text(action.label, style: text.titleSmall)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: text.labelLarge?.copyWith(fontSize: 14, height: 1.25),
              ),
            ],
          );
    return Semantics(
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action.onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 64 : 112),
            child: Padding(
              padding: compact
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
