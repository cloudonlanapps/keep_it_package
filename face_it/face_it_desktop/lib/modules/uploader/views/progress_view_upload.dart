import 'package:face_it_desktop/modules/uploader/models/upload_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../media/providers/candidates.dart';
import '../providers/uploader.dart';

class ProgressViewUpload extends ConsumerStatefulWidget {
  const ProgressViewUpload({super.key});

  @override
  ConsumerState<ProgressViewUpload> createState() => UploadProgressViewState();
}

class UploadProgressViewState extends ConsumerState<ProgressViewUpload> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploader = ref.watch(uploaderProvider);

    final candidates = ref.watch(mediaListProvider.select((e) => e.mediaList));

    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    final files = candidates.map((e) => uploader.getFileState(e.path));

    int uploadCountByStatus(UploadStatus status) {
      return files.where((e) => e.uploadStatus == status).length;
    }

    const radius = 20.0;
    const radius2 = 20.0;

    return ShadPopover(
      controller: popoverController,
      padding: EdgeInsets.zero,
      popover: (context) {
        return ShadCard(
          width: 150,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                for (final e in UploadStatus.values)
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: e.color,
                        ),
                      ),
                      Text(
                        e.name,
                        style: ShadTheme.of(context).textTheme.small,
                      ),
                    ],
                  ),
              ],
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
                      for (final status in UploadStatus.values)
                        PieChartSectionData(
                          value: uploadCountByStatus(status).toDouble(),
                          color: status.color,
                          radius: radius,
                          showTitle: false,
                          title: status.name,
                        ),
                      PieChartSectionData(
                        value: (candidates.length - uploader.uploadCount)
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
}
