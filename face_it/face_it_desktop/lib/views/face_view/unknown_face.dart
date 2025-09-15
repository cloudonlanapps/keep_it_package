import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/f_face_file_cache.dart';

import '../../providers/face_file_cache_provider.dart';
import 'face_preview.dart';

class UnknownFace extends ConsumerStatefulWidget {
  const UnknownFace({required this.faceFileCache, super.key});
  final FaceFileCache faceFileCache;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UnknownnFaceState();
}

class _UnknownnFaceState extends ConsumerState<UnknownFace> {
  late final ShadPopoverController popoverFlagController;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    popoverFlagController = ShadPopoverController();
    textEditingController = TextEditingController();
    textEditingController.addListener(refresh);

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    popoverFlagController.dispose();
    textEditingController
      ..removeListener(refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: 360,
      height: 112 + 20,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          FacePreview(faceFileCache: widget.faceFileCache),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: ShadInput(
                      controller: textEditingController,
                      placeholder: const Text('Who is this?'),
                      leading: const Icon(LucideIcons.userPen300),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        expands: true,
                        onPressed: () => ref
                            .read(
                              faceFileCacheProvider(
                                widget.faceFileCache.face.identity,
                              ).notifier,
                            )
                            .registerSelf(textEditingController.text),
                        enabled: textEditingController.text.isNotEmpty,
                        child: const Text('Save'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ShadPopover(
                        popover: (context) {
                          return const SizedBox(
                            width: 180,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShadButton.ghost(
                                  child: Text('Ignore this person'),
                                ),
                                ShadButton.ghost(
                                  child: Text('This is not a face'),
                                ),
                              ],
                            ),
                          );
                        },
                        controller: popoverFlagController,
                        child: ShadButton.ghost(
                          onPressed: popoverFlagController.toggle,
                          child: Icon(
                            LucideIcons.flag300,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.destructive,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
