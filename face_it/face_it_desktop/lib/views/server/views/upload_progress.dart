import 'package:face_it_desktop/views/server/models/upload_status.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content_manager.dart/providers/candidates.dart';
import '../providers/uploader.dart';

class UploadProgressChart extends ConsumerWidget {
  const UploadProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploader = ref
        .watch(uploaderProvider)
        .whenOrNull(data: (data) => data);

    if (uploader == null) return const SizedBox.shrink();
    final candidates = ref.watch(candidatesProvider.select((e) => e.items));
    const radius = 20.0;
    const radius2 = 20.0;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            sections: [
              for (final status in UploadStatus.values)
                PieChartSectionData(
                  value: uploader.countByStatus(status).toDouble(),
                  color: colors(status),
                  radius: radius,
                  showTitle: false,
                  title: status.name,
                ),
              PieChartSectionData(
                value: (candidates.length - uploader.count).toDouble(),
                color: Colors.grey,
                radius: radius,
                showTitle: false,
              ),
            ],
            sectionsSpace: 0,
            centerSpaceRadius: radius2, // This creates the donut shape
          ),
        ),
      ),
    );
  }

  Color colors(UploadStatus status) => switch (status) {
    UploadStatus.pending => Colors.blueGrey,
    UploadStatus.uploading => Colors.blue,
    UploadStatus.success => Colors.green,
    UploadStatus.error => Colors.red,
  };
}
