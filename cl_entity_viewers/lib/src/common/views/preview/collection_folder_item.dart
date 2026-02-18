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
        // Gradient Scrim for Label
        if (name != null)
          Positioned.fill(
            top: null, // Align to bottom
            child: Container(
              height: 40, // Adjust height as needed
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12), // Match folder radius
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
        // Label
        if (name != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Text(
              name!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ShadTheme.of(context).textTheme.small.copyWith(
                color: Colors.white, // Ensure readable on dark scrim
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Counter Badge (Top Right)
        if (counter != null) Positioned(top: 4, right: 4, child: counter!),
        // Avatar (Keep existing logic or adjust if needed, mostly for 'not on server' icon)
        if (avatarAsset != null)
          Positioned(
            top: 4,
            left: 4,
            width: 24,
            height: 24,
            child: ShadAvatar(avatarAsset),
          ),
      ],
    );
  }
}
