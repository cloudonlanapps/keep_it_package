import '../overlays.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'folder_clip.dart';

class FolderItem extends StatelessWidget {
  const FolderItem({
    required this.name,
    required this.child,
    super.key,
    this.borderColor = const Color(0xFFE6B65C),
    this.avatarAsset,
    this.counter,
  });
  final String? name;
  final Widget child;
  final Color borderColor;
  final String? avatarAsset;
  final Widget? counter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LayoutBuilder(
          builder: (context, constrain) {
            return FolderWidget(
              width: constrain.maxWidth,
              height: constrain.maxHeight,
              borderColor: borderColor,
              child: child,
            );
          },
        ),
        if (counter != null)
          Positioned(bottom: 8, left: 0, right: 0, child: counter!),
        if (name != null)
          OverlayWidgets(
            heightFactor: 0.2,
            widthFactor: 0.9,
            alignment: Alignment.bottomCenter,
            fit: BoxFit.none,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ShadTheme.of(
                  context,
                ).colorScheme.foreground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                name!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ShadTheme.of(context).textTheme.small.copyWith(
                  color: ShadTheme.of(context).colorScheme.background,
                ),
              ),
            ),
          ),
        if (avatarAsset != null)
          Positioned.fill(
            bottom: 6,
            right: 6,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FractionallySizedBox(
                widthFactor: 0.15,
                heightFactor: 0.15,
                child: ShadAvatar(
                  avatarAsset,
                  // size: const Size.fromRadius(20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
