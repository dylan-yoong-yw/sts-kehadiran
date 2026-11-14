import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/theme.dart';

/// A vertical scroll view whose [children] fill at least the screen height,
/// with any spare height given to the child at [expandIndex].
///
/// On a tall phone the expanding child (e.g. a card) grows so the last child
/// sits just above the navigation bar, with no empty band; on a short phone
/// or with large system text, the content simply scrolls. Like
/// [FillScrollView], this never measures intrinsic sizes, so children may
/// contain `LayoutBuilder`s.
class ExpandingScrollView extends StatelessWidget {
  const ExpandingScrollView({
    super.key,
    this.scrollKey,
    required this.expandIndex,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  /// Key for the scroll view itself (used by tests to scroll).
  final Key? scrollKey;
  final int expandIndex;
  final List<Widget> children;
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
        child: _ExpandingColumn(expandIndex: expandIndex, children: children),
      ),
    ),
  );
}

class _ExpandingColumn extends MultiChildRenderObjectWidget {
  const _ExpandingColumn({required this.expandIndex, required super.children});

  final int expandIndex;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderExpandingColumn(expandIndex);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderExpandingColumn renderObject,
  ) => renderObject.expandIndex = expandIndex;
}

class _ColumnParentData extends ContainerBoxParentData<RenderBox> {}

/// Stacks full-width children vertically at their natural heights, then
/// lays the child at [expandIndex] out again, taller, if the column is
/// shorter than its minimum height, so it fills the gap.
class _RenderExpandingColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ColumnParentData> {
  _RenderExpandingColumn(this._expandIndex);

  int _expandIndex;
  set expandIndex(int value) {
    if (value == _expandIndex) return;
    _expandIndex = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ColumnParentData) {
      child.parentData = _ColumnParentData();
    }
  }

  Iterable<RenderBox> get _children sync* {
    var child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final natural = BoxConstraints.tightFor(width: width);
    var height = 0.0;
    RenderBox? expanding;
    for (final (i, child) in _children.indexed) {
      child.layout(natural, parentUsesSize: true);
      height += child.size.height;
      if (i == _expandIndex) expanding = child;
    }
    final spare = constraints.minHeight - height;
    if (expanding != null && spare > 0) {
      // A minimum, not an exact height: tight constraints would make the
      // child a relayout boundary, so it could later grow (e.g. once its
      // data loads) without this column being laid out again.
      expanding.layout(
        BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: expanding.size.height + spare,
        ),
        parentUsesSize: true,
      );
      height = 0;
      for (final child in _children) {
        height += child.size.height;
      }
    }
    var y = 0.0;
    for (final child in _children) {
      (child.parentData! as _ColumnParentData).offset = Offset(0, y);
      y += child.size.height;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  double computeMinIntrinsicWidth(double height) => _children.fold(
    0,
    (widest, child) => math.max(widest, child.getMinIntrinsicWidth(height)),
  );

  @override
  double computeMaxIntrinsicWidth(double height) => _children.fold(
    0,
    (widest, child) => math.max(widest, child.getMaxIntrinsicWidth(height)),
  );

  @override
  double computeMinIntrinsicHeight(double width) => _children.fold(
    0,
    (total, child) => total + child.getMinIntrinsicHeight(width),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => _children.fold(
    0,
    (total, child) => total + child.getMaxIntrinsicHeight(width),
  );

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
