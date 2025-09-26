import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../media/providers/candidates.dart';
import '../models/image_face_mapper.dart';
import '../providers/face_recg.dart';

class ProgressViewFaceRecg extends ConsumerStatefulWidget {
  const ProgressViewFaceRecg({super.key});

  @override
  ConsumerState<ProgressViewFaceRecg> createState() =>
      UploadProgressViewState();
}

class UploadProgressViewState extends ConsumerState<ProgressViewFaceRecg> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(mediaListProvider.select((e) => e.mediaList));
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    final faceMapper = ref.watch(faceRecgProvider);
    const radius = 20.0;
    const radius2 = 20.0;

    return ShadPopover(
      controller: popoverController,
      popover: (context) {
        return SizedBox(
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: ActivityStatus.values.map((e) {
                return Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: colors(e),
                      ),
                    ),
                    Text(e.name, style: ShadTheme.of(context).textTheme.small),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: popoverController.toggle,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                const Center(child: Icon(LucideIcons.info400)),
                PieChart(
                  PieChartData(
                    sections: [
                      for (final status in ActivityStatus.values)
                        PieChartSectionData(
                          value: faceMapper.countByStatus(status).toDouble(),
                          color: colors(status),
                          radius: radius,
                          showTitle: false,
                          title: status.name,
                        ),
                      PieChartSectionData(
                        value: (candidates.length - faceMapper.count)
                            .toDouble(),
                        color: Colors.grey,
                        radius: radius,
                        showTitle: false,
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: radius2, // This creates the donut shape
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color colors(ActivityStatus status) => switch (status) {
    ActivityStatus.premature => Colors.blueGrey.shade300,
    ActivityStatus.pending => Colors.blueGrey,
    ActivityStatus.ready => Colors.yellow,
    ActivityStatus.processingNow => Colors.blue,
    ActivityStatus.success => Colors.green,
    ActivityStatus.error => Colors.red,
  };
}
