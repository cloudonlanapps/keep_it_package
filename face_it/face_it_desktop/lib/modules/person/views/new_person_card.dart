import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NewPersonCard extends ConsumerStatefulWidget {
  const NewPersonCard({required this.faceId, super.key});
  final String faceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewPersonCardState();
}

class _NewPersonCardState extends ConsumerState<NewPersonCard> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController.addListener(refresh);

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    textEditingController
      ..removeListener(refresh)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FIXME: Search dB Card when server is available
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ShadInput(
                      padding: EdgeInsets.zero,
                      controller: textEditingController,

                      autofocus: true,
                      placeholder: const Text('Who is this?'),
                      trailing: ShadButton.link(
                        onPressed: register,
                        enabled: textEditingController.text.isNotEmpty,
                        child: const Icon(LucideIcons.check400),
                      ),
                      onSubmitted: (val) => register(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void register() {
    throw UnimplementedError();
  }
}
