import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:colan_widgets/src/utils/double_extension.dart';
import 'package:flutter/material.dart';

@immutable
class CLDimension {
  const CLDimension({required this.itemsInRow, required this.itemsInColumn});
  final int itemsInRow;
  final int itemsInColumn;

  @override
  bool operator ==(covariant CLDimension other) {
    if (identical(this, other)) return true;

    return other.itemsInRow == itemsInRow &&
        other.itemsInColumn == itemsInColumn;
  }

  @override
  int get hashCode => itemsInRow.hashCode ^ itemsInColumn.hashCode;

  @override
  String toString() => 'Dimension(width: $itemsInRow, height: $itemsInColumn)';

  int get totalCount => itemsInRow * itemsInColumn;
}

class CLMediaCollage extends StatelessWidget {
  const CLMediaCollage._({
    required this.itemCount,
    required this.canScroll,
    required this.keepAspectRatio,
    required this.maxPageDimension,
    required this.itemBuilder,
    this.hCount,
    this.vCount,
    this.childSize,
    super.key,
  });
  factory CLMediaCollage.byMatrixSize(
    int itemCount, {
    required int hCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    int? vCount,
    Key? key,
    bool? keepAspectRatio,
    CLDimension? maxPageDimension,
  }) {
    return CLMediaCollage._(
      itemCount: itemCount,
      key: key,
      hCount: hCount,
      vCount: vCount,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: vCount == null,
      maxPageDimension:
          maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
      itemBuilder: itemBuilder,
    );
  }
  factory CLMediaCollage.byChildSize(
    int itemCount, {
    required Size childSize,
    required Widget Function(BuildContext context, int index) itemBuilder,
    Key? key,
    bool? keepAspectRatio,
    bool canScroll = false,
    CLDimension? maxPageDimension,
  }) {
    return CLMediaCollage._(
      itemCount: itemCount,
      childSize: childSize,
      key: key,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: canScroll,
      maxPageDimension:
          maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
      itemBuilder: itemBuilder,
    );
  }

  final int itemCount;
  final int? hCount;
  final int? vCount;
  final bool keepAspectRatio;
  final Size? childSize;
  final bool canScroll;
  final CLDimension maxPageDimension;

  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int x;
        final int? y;

        if (childSize == null) {
          if (vCount != null) {
            final totalCount = hCount! * vCount!;
            if (itemCount < totalCount) {
              /// Here is an assumption that hCount and vCount are same !!
              /// Fix later

              x = y = sqrt(itemCount).ceil();
            } else {
              x = hCount!;
              y = vCount;
            }
          } else {
            x = hCount!;
            y = vCount;
          }
        } else {
          final pageMatrix = computePageMatrix(
            pageSize: Size(constraints.maxWidth, constraints.maxHeight),
            itemSize: childSize!,
          );
          x = pageMatrix.itemsInRow;
          y = canScroll ? null : pageMatrix.itemsInColumn;
        }
        return switch (y) {
          null => Matrix2D.scrollable(
            itemCount: itemCount,
            hCount: x,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            itemBuilder: (context, index) {
              return onBuildItem(context, itemBuilder(context, index));
            },
          ),
          _ => Matrix2D(
            itemCount: itemCount,
            hCount: x,
            vCount: y,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            itemBuilder: (context, index) {
              return onBuildItem(context, itemBuilder(context, index));
            },
          ),
        };
      },
    );
  }

  CLDimension computePageMatrix({
    required Size pageSize,
    required Size itemSize,
  }) {
    if (pageSize.width == double.infinity) {
      throw Exception("Width is unbounded, can't handle");
    }
    if (pageSize.height == double.infinity) {
      throw Exception("Width is unbounded, can't handle");
    }
    final itemsInRow = min(
      maxPageDimension.itemsInRow,
      max(
        1,
        ((pageSize.width.nearest(itemSize.width)) / itemSize.width).floor(),
      ),
    );
    final itemsInColumn = min(
      maxPageDimension.itemsInColumn,
      max(
        1,
        ((pageSize.height.nearest(itemSize.height)) / itemSize.height).floor(),
      ),
    );

    return CLDimension(itemsInRow: itemsInRow, itemsInColumn: itemsInColumn);
  }

  Widget onBuildItem(BuildContext context, Widget? child) {
    if (childSize != null) {
      return SizedBox.fromSize(
        size: childSize,
        child: Center(child: child),
      );
    }
    return CLAspectRationDecorated(
      borderRadius: BorderRadius.circular(4),
      // padding: const EdgeInsets.all(1),
      child: child,
    );
  }
}
