import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../basics/on_swipe.dart';
import '../../models/ext_color.dart';
import '../../utils/key_listener.dart';
import '../../utils/validate_layout.dart';
import 'cl_top_bar.dart';

class CLScaffold extends StatelessWidget {
  const CLScaffold({
    required this.body,
    this.topMenu,
    this.bottomMenu,
    this.banners = const [],
    this.backgroundColor,
    this.hasBackground = false,
    this.backgroundBrightness = 0.25,
    this.hasBorder = false,
    this.borderColor,
    this.useSafeArea = false,
    this.onSwipe,
    super.key,
  });
  final CLTopBar? topMenu;
  final PreferredSizeWidget? bottomMenu;
  final List<Widget> banners;
  final Widget body;
  final Color? backgroundColor;
  final bool hasBackground;
  final double backgroundBrightness;
  final bool hasBorder;
  final Color? borderColor;
  final bool useSafeArea;
  final VoidCallback? onSwipe;

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      appBar: topMenu,
      body: Column(
        children: [
          ...banners,
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar:
          (MediaQuery.of(context).viewInsets.bottom == 0 && bottomMenu != null)
          ? SafeArea(
              child: SizedBox.fromSize(
                size: bottomMenu!.preferredSize,
                child: bottomMenu,
              ),
            )
          : null,
    );

    if (hasBorder) {
      content = CLScaffoldBorder(
        hasBorder: true,
        borderColor: borderColor,
        child: content,
      );
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    if (hasBackground) {
      content = CLBackground(
        hasBackground: true,
        backgroundBrightness: backgroundBrightness,
        child: content,
      );
    }

    if (onSwipe != null) {
      content = OnSwipe(onSwipe: onSwipe!, child: content);
      content = CLKeyListener(
        keyHandler: {
          LogicalKeyboardKey.escape: onSwipe!,
        },
        child: content,
      );
    }

    return ValidateLayout(validLayout: true, child: content);
  }
}

class CLScaffoldBorder extends StatelessWidget {
  const CLScaffoldBorder({
    required this.hasBorder,
    required this.child,
    this.borderColor,
    super.key,
  });
  final bool hasBorder;
  final Widget child;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return child;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).dividerColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}

class CLBackground extends StatelessWidget {
  const CLBackground({
    required this.child,
    this.backgroundBrightness = 0.25,
    this.hasBackground = false,
    super.key,
  });
  final Widget child;
  final double backgroundBrightness;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    if (!hasBackground) return child;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.indigo,
                        Colors.purple,
                      ]
                      .map(
                        (e) => backgroundBrightness < 0
                            ? e.reduceBrightness(-backgroundBrightness)
                            : e.increaseBrightness(backgroundBrightness),
                      )
                      .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
