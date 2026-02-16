import 'dart:math';

import 'package:colan_widgets/src/basics/cl_text.dart';
import 'package:flutter/material.dart';

import 'package:percent_indicator/percent_indicator.dart';

class StreamProgressView<T> extends StatelessWidget {
  const StreamProgressView({
    required this.stream,
    required this.onCancel,
    required this.progressExtractor,
    required this.labelExtractor,
    super.key,
  });

  final Stream<T> Function() stream;
  final void Function() onCancel;
  final double Function(T) progressExtractor;
  final String Function(T) labelExtractor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: StreamBuilder<T>(
                  stream: stream(),
                  builder:
                      (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.hasData) {
                          final double percent = min(
                            1,
                            progressExtractor(snapshot.data as T),
                          );
                          return CircularPercentIndicator(
                            radius: 100,
                            lineWidth: 13,
                            animation: true,
                            percent: percent,
                            center: CLText.veryLarge(
                              '${(percent * 100).toInt()} %',
                            ),
                            footer: CLText.large(
                              labelExtractor(snapshot.data as T),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.purple,
                          );
                        } else {
                          return CircularPercentIndicator(
                            radius: 100,
                            lineWidth: 13,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.purple,
                          );
                        }
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
