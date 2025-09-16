import 'package:face_it_desktop/models/face/detected_face.dart';
import 'package:face_it_desktop/providers/f_face.dart';
import 'package:face_it_desktop/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WhenFaceisNotKnown extends ConsumerStatefulWidget {
  const WhenFaceisNotKnown({required this.face, super.key});
  final DetectedFace face;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WhenFaceisNotKnownState();
}

class _WhenFaceisNotKnownState extends ConsumerState<WhenFaceisNotKnown> {
  late final ShadPopoverController popoverFlagController;
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;

  @override
  void initState() {
    popoverFlagController = ShadPopoverController();
    textEditingController = TextEditingController();
    textEditingController.addListener(refresh);
    focusNode = FocusNode();

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
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
    final color = ref.watch(faceBoxPreferenceProvider.select((e) => e.color));
    return Card(
      elevation: 8,
      shadowColor: color,
      margin: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 288,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadButton.link(
                      onPressed: () => ref
                          .read(
                            detectedFaceProvider(
                              widget.face.descriptor.identity,
                            ).notifier,
                          )
                          .searchDB(),
                      child: const Icon(
                        Icons.person_search,
                        size: 24,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ShadInput(
                          padding: EdgeInsets.zero,
                          controller: textEditingController,
                          focusNode: focusNode,
                          placeholder: const Text('Who is this?'),

                          trailing: ShadButton.link(
                            onPressed: () => ref
                                .read(
                                  detectedFaceProvider(
                                    widget.face.descriptor.identity,
                                  ).notifier,
                                )
                                .register(textEditingController.text),
                            enabled: textEditingController.text.isNotEmpty,
                            child: const Icon(LucideIcons.check400),
                          ),
                          onSubmitted: (val) =>
                              () => ref
                                  .read(
                                    detectedFaceProvider(
                                      widget.face.descriptor.identity,
                                    ).notifier,
                                  )
                                  .register(textEditingController.text),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 30,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ShadButton.link(
                      onPressed: () => ref
                          .read(
                            detectedFaceProvider(
                              widget.face.descriptor.identity,
                            ).notifier,
                          )
                          .markNotAFace(),
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        'Not a face?',
                        style: ShadTheme.of(context).textTheme.small,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
