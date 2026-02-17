import 'package:flutter/material.dart';

import '../../basics/cl_circled_icon.dart';
import '../../theme/models/cl_icons.dart';
import '../../theme/state/cl_theme.dart';
import '../appearance/cl_scaffold.dart';

class WizardLayout extends StatelessWidget {
  const WizardLayout({
    required this.child,
    this.onCancel,
    this.title,
    this.wizard,
    this.actions,
    super.key,
  });
  final Widget child;
  final PreferredSizeWidget? wizard;
  final String? title;
  final List<Widget>? actions;

  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      hasBackground: true,
      hasBorder: true,
      borderColor: CLTheme.of(context).colors.wizardButtonBackgroundColor,
      topMenu: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title ?? '',
        ),
        actions: [
          if (actions != null) ...actions!.map((e) => e),
          if (onCancel != null)
            CircledIcon(
              clIcons.closeFullscreen,
              onTap: onCancel,
            ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: child),
          if (wizard != null) ...[
            const SizedBox(
              height: 16,
            ),
            wizard!,
          ],
        ],
      ),
    );
  }
}

class WizardLayout2 extends StatelessWidget {
  const WizardLayout2({
    required this.child,
    this.onCancel,
    this.title,
    this.wizard,
    this.actions,
    super.key,
  });
  final Widget child;
  final PreferredSizeWidget? wizard;
  final String? title;
  final List<Widget>? actions;

  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      hasBorder: true,
      topMenu: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(title ?? ''),
        actions: [
          if (actions != null) ...actions!.map((e) => e),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: onCancel,
              child: Icon(clIcons.closeFullscreen),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
      bottomMenu: wizard,
    );
  }
}
