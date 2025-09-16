import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face/detected_face.dart';

import '../../providers/f_face.dart';

class FaceNotChecked extends ConsumerStatefulWidget {
  const FaceNotChecked({required this.face, super.key});
  final DetectedFace face;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FaceNotCheckedState();
}

class FaceNotCheckedState extends ConsumerState<FaceNotChecked> {
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
    final notifier = ref.watch(
      detectedFaceProvider(widget.face.descriptor.identity).notifier,
    );
    return ShadCard(
      width: 288,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Center(
            child: ShadInput(
              controller: textEditingController,
              placeholder: const Text('Who is this?'),
              onSubmitted: (val) =>
                  notifier.register(textEditingController.text),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ShadButton.ghost(
                onPressed: notifier.searchDB,
                child: const Icon(
                  Icons.person_search,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: ShadButton.outline(
                  expands: true,
                  onPressed: () =>
                      notifier.register(textEditingController.text),
                  enabled: textEditingController.text.isNotEmpty,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
