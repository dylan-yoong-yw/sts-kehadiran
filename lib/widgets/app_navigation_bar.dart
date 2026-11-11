import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A Material 3 [NavigationBar] whose labels always stay on one line.
///
/// Labels grow with the system font size only as far as the longest one
/// still fits its tab (Android's bottom bars behave the same way). Beyond
/// that, the icons and long-press tooltips identify each tab.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  /// Horizontal room a tab keeps around its label.
  static const _labelPadding = 12.0;

  double _widestLabel(BuildContext context) {
    final resolved = NavigationBarTheme.of(context).labelTextStyle
        ?.resolve({WidgetState.selected});
    // The selected style is the boldest, so the widest.
    final style = DefaultTextStyle.of(context).style
        .merge(Theme.of(context).textTheme.labelSmall)
        .merge(resolved);
    var widest = 0.0;
    for (final destination in destinations) {
      final painter = TextPainter(
        text: TextSpan(text: destination.label, style: style),
        textDirection: Directionality.of(context),
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    return widest;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tabWidth = constraints.maxWidth / destinations.length;
      final widest = _widestLabel(context);
      final maxScale = widest == 0 ? 1.0 : (tabWidth - _labelPadding) / widest;
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: math.max(maxScale, 0.5),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations,
        ),
      );
    },
  );
}
