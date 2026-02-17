import 'dart:math';

import 'package:flutter/material.dart';

class CLGrid extends StatelessWidget {
  const CLGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.columns,
    this.additionalItems,
    this.rows,
    this.physics = const NeverScrollableScrollPhysics(),
    this.header,
    this.footer,
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    super.key,
  });
  final int itemCount;
  final List<Widget>? additionalItems;
  final int columns;
  final int? rows;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final int limitCount;
    final additionaItemsCount = additionalItems?.length ?? 0;
    final totalItems = itemCount + additionaItemsCount;
    if (rows == null) {
      limitCount = itemCount;
    } else {
      limitCount = min(totalItems, rows! * columns) - additionaItemsCount;
    }
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?header,
        GridView.builder(
          shrinkWrap: true,

          physics: physics,
          itemBuilder: (context, index) {
            if (index >= limitCount) {
              if (index - limitCount < additionalItems!.length) {
                return additionalItems![index - limitCount];
              }
              /* return  */
            }
            if (index >= itemCount) {
              return Container();
            }

            return itemBuilder(context, index);
          },
          itemCount: limitCount + additionaItemsCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
        ),
        ?footer,
      ],
    );
  }
}
