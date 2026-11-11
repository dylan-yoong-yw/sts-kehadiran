import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A vertical scroll view whose content is at least as tall as the screen.
///
/// The [sections] are spread out with [MainAxisAlignment.spaceBetween]: on a
/// tall screen the first section sits at the top and the last at the bottom,
/// with no empty band; on a short screen, or with large system text, the
/// content simply scrolls. Unlike `SliverFillRemaining`, this never measures
/// intrinsic sizes, so sections may contain `LayoutBuilder`s.
class FillScrollView extends StatelessWidget {
  const FillScrollView({
    super.key,
    this.scrollKey,
    required this.sections,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  /// Key for the scroll view itself (used by tests to scroll).
  final Key? scrollKey;
  final List<Widget> sections;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, viewport) => SingleChildScrollView(
      key: scrollKey,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, viewport.maxHeight - padding.vertical),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sections,
        ),
      ),
    ),
  );
}
