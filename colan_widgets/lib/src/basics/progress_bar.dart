import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({required this.progress, super.key});
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final percentage = min(max(progress ?? 0, 0), 1.0) * 100;
    return SizedBox(
      height: kMinInteractiveDimension * 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: LinearPercentIndicator(
              width: constraints.maxWidth - 40,
              animation: true,
              lineHeight: 20,
              animationDuration: 2000,
              percent: percentage / 100,
              animateFromLastPercent: true,
              center: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              barRadius: const Radius.elliptical(5, 15),
              progressColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
