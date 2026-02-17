import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GreyShimmer extends StatelessWidget {
  const GreyShimmer({super.key, this.height, this.width});
  final double? height;
  final double? width;

  static Widget? cachedWidget;

  @override
  Widget build(BuildContext context) {
    return cachedWidget ??= Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? 200,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Shimmering',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static Widget show() => const GreyShimmer();
}
