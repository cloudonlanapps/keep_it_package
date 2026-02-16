import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import '../../models/ext_color.dart';
import '../../theme/models/cl_icons.dart';

class CLFullscreenBox extends StatefulWidget {
  const CLFullscreenBox({
    required this.child,
    super.key,
    this.useSafeArea = false,
    this.backgroundColor,
    this.hasBorder = false,
    this.backgroundBrightness = 0.25,
    this.hasBackground = false,
    this.bottomNavigationBar,
    this.appBar,
  });

  final Widget child;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final double backgroundBrightness;
  final bool hasBackground;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  @override
  State<StatefulWidget> createState() => _CLFullscreenBoxState();
}

class _CLFullscreenBoxState extends State<CLFullscreenBox> {
  // Create an overlay entry

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: CLBackground(
        hasBackground: widget.hasBackground,
        backgroundBrightness: widget.backgroundBrightness,
        child: SafeArea(
          top: widget.useSafeArea,
          left: widget.useSafeArea,
          right: widget.useSafeArea,
          bottom: widget.useSafeArea,
          child: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: _ScaffoldBorder(
              hasBorder: widget.hasBorder,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.zero,
                    child: Scaffold(
                      backgroundColor:
                          widget.backgroundColor ?? Colors.transparent,
                      appBar: widget.appBar,
                      body: widget.child,
                      bottomNavigationBar: widget.bottomNavigationBar,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CLDialogWrapper extends StatelessWidget {
  const CLDialogWrapper({
    required this.child,
    super.key,
    this.isDialog = true,
    this.backgroundColor,
    this.padding,
    this.onCancel,
  });
  final bool isDialog;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final void Function()? onCancel;
  @override
  Widget build(BuildContext context) {
    if (!isDialog) {
      return WrapCloseButton(
        onCancel: onCancel,
        child: child,
      );
    }
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      //scrollable: true,

      //shape: const ContinuousRectangleBorder(),
      backgroundColor: backgroundColor,
      insetPadding: padding ?? EdgeInsets.zero,
      child: WrapCloseButton(onCancel: onCancel, child: child),
    );
  }
}

class WrapCloseButton extends StatelessWidget {
  const WrapCloseButton({
    required this.child,
    this.onCancel,
    super.key,
  });

  final void Function()? onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCancel != null)
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 32 + 20,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: ShadButton.ghost(
                    onPressed: onCancel,
                    child: Icon(clIcons.closeFullscreen, size: 20),
                  ),
                ),
              ),
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _ScaffoldBorder extends StatelessWidget {
  const _ScaffoldBorder({
    required this.hasBorder,
    required this.child,
  });
  final bool hasBorder;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return Scaffold(body: child);
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
    );
  }
}

class CLBackground extends StatelessWidget {
  const CLBackground({
    required this.child,
    super.key,
    this.backgroundBrightness = 0.25,
    this.hasBackground = false,
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
