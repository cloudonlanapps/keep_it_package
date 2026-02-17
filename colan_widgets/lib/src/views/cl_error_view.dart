import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum CLErrorKind { hidden, standard, wizard }

abstract class CLErrorView extends StatelessWidget {
  const CLErrorView({super.key});

  const factory CLErrorView.hidden({
    required String? debugMessage,
    Key? key,
  }) = _CLErrorViewHidden;

  const factory CLErrorView.local({
    required String message,
    String? details,
    IconData? icon,
    List<Widget>? actions,
    Key? key,
  }) = _CLErrorViewStandard;

  const factory CLErrorView.page({
    required String message,
    String? details,
    IconData? icon,
    List<Widget>? actions,
    CLTopBar? topBar,
    VoidCallback? onSwipe,
    Key? key,
  }) = _CLErrorViewPage;

  const factory CLErrorView.wizard({
    required String message,
    String? details,
    VoidCallback? onClose,
    Key? key,
  }) = _CLErrorViewWizard;

  const factory CLErrorView.custom({
    required Widget child,
    Key? key,
  }) = _CLErrorViewCustom;

  const factory CLErrorView.image({
    Key? key,
  }) = _CLErrorViewImage;
}

class _CLErrorViewHidden extends CLErrorView {
  const _CLErrorViewHidden({
    required this.debugMessage,
    super.key,
  });

  final String? debugMessage;

  @override
  Widget build(BuildContext context) {
    return kDebugMode && debugMessage != null
        ? Center(
            child: Text(
              debugMessage!,
              style: ShadTheme.of(context).textTheme.p,
            ),
          )
        : const SizedBox.shrink();
  }
}

class _CLErrorViewStandard extends CLErrorView {
  const _CLErrorViewStandard({
    required this.message,
    this.details,
    this.icon,
    this.actions,
    super.key,
  });

  final String message;
  final String? details;
  final IconData? icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return _CLErrorContent(
      message: message,
      details: details,
      icon: icon,
      actions: actions,
    );
  }
}

class _CLErrorViewPage extends CLErrorView {
  const _CLErrorViewPage({
    required this.message,
    this.details,
    this.icon,
    this.actions,
    this.topBar,
    this.onSwipe,
    super.key,
  });

  final String message;
  final String? details;
  final IconData? icon;
  final List<Widget>? actions;
  final CLTopBar? topBar;
  final VoidCallback? onSwipe;

  @override
  Widget build(BuildContext context) {
    final Widget content = _CLErrorContent(
      message: message,
      details: details,
      icon: icon,
      actions: actions,
    );

    final shouldWrap = !ValidateLayout.isValidLayout(context);

    if (shouldWrap || topBar != null) {
      return CLScaffold(
        topMenu: topBar,
        body: content,
      );
    }
    return content;
  }
}

class _CLErrorViewWizard extends CLErrorView {
  const _CLErrorViewWizard({
    required this.message,
    this.details,
    this.onClose,
    super.key,
  });

  final String message;
  final String? details;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return WizardLayout(
      title: message,
      onCancel: onClose,
      child: _CLErrorContent(
        message: message,
        details: details,
      ),
    );
  }
}

class _CLErrorViewCustom extends CLErrorView {
  const _CLErrorViewCustom({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _CLErrorViewImage extends CLErrorView {
  const _CLErrorViewImage({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 64,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Icon(
                  clIcons.brokenImage,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CLErrorContent extends StatelessWidget {
  const _CLErrorContent({
    this.message,
    this.details,
    this.icon,
    this.actions,
  });

  final String? message;
  final String? details;
  final IconData? icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? clIcons.error,
              size: 48,
              color: ShadTheme.of(context).colorScheme.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'An error occurred',
              style: ShadTheme.of(context).textTheme.h3,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: ShadTheme.of(context).textTheme.muted,
                textAlign: TextAlign.center,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
