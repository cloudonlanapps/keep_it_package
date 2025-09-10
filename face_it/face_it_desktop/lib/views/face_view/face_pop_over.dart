import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/face.dart';
import '../image/draw_bbox.dart';

class PopoverPage extends StatefulWidget {
  const PopoverPage({required this.face, super.key});
  final Face face;

  @override
  State<PopoverPage> createState() => _PopoverPageState();
}

class _PopoverPageState extends State<PopoverPage> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadPopover(
      decoration: const ShadDecoration(
        color: Colors.transparent,
        border: ShadBorder.none,
      ),
      padding: EdgeInsets.zero,
      controller: popoverController,
      popover: (context) => ShadCard(
        width: 288,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Row(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(),
                    color: Colors.grey.shade400,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: popoverController.toggle,
        child: DrawBBox(bbox: widget.face.bbox),
      ),
    );
  }
}
