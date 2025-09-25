import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../settings/views/quick_settings.dart';
import '../providers/candidates.dart';
import 'media.dart';

class MediaViewer extends ConsumerStatefulWidget {
  const MediaViewer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentViewerState();
}

class _ContentViewerState extends ConsumerState<MediaViewer> {
  @override
  Widget build(BuildContext context) {
    final activeCandidate = ref.watch(
      mediaListProvider.select((candidates) => candidates.activeCandidate),
    );

    return Column(
      children: [
        if (activeCandidate == null)
          Center(
            child: Text(
              'Select a Media',
              style: ShadTheme.of(context).textTheme.muted,
            ),
          )
        else ...[
          Expanded(
            child: LayoutBuilder(
              builder: (context, constrainedBox) {
                return Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    SizedBox(
                      width: constrainedBox.maxWidth,
                      height: constrainedBox.maxHeight,
                      child: FittedBox(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Media(filePath: activeCandidate.path),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const QuickSettings(),
        ],
      ],
    );
  }
}
