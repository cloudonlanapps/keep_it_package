import 'package:colan_widgets/src/basics/on_swipe.dart';
import 'package:colan_widgets/src/views/appearance/cl_top_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/validate_layout.dart';
import 'appearance/cl_scaffold.dart';
import 'wizards/wizard_layout.dart';

enum CLLoadingViewKind { hidden, widget, shimmer, wizard }

abstract class CLLoadingView extends StatelessWidget {
  const CLLoadingView({super.key});

  const factory CLLoadingView.hidden({
    required String? debugMessage,
    Key? key,
  }) = _CLLoadingViewHidden;

  const factory CLLoadingView.local({
    String? message,
    String? debugMessage,
    Key? key,
  }) = _CLLoadingViewStandard;

  const factory CLLoadingView.page({
    String? message,
    String? debugMessage,
    CLTopBar? topBar,
    VoidCallback? onSwipe,
    List<Widget>? actions,
    Key? key,
  }) = _CLLoadingViewPage;

  const factory CLLoadingView.shimmer({
    required String? debugMessage,
    Widget? child,
    Key? key,
  }) = _CLLoadingViewShimmer;

  const factory CLLoadingView.wizard({
    required String message,
    String? debugMessage,
    VoidCallback? onCancel,
    Key? key,
  }) = _CLLoadingViewWizard;

  const factory CLLoadingView.custom({
    required Widget child,
    Key? key,
  }) = _CLLoadingViewCustom;

  // Backwards compatibility or internal use
  factory CLLoadingView.widget({
    required String? debugMessage,
    Key? key,
    String? message,
  }) {
    return _CLLoadingViewStandard(
      key: key,
      debugMessage: debugMessage,
      message: message,
    );
  }
}

class _CLLoadingViewHidden extends CLLoadingView {
  const _CLLoadingViewHidden({
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

class _CLLoadingViewStandard extends CLLoadingView {
  const _CLLoadingViewStandard({
    this.message,
    this.debugMessage,
    //this.useScaffold = false,
    super.key,
  });

  final String? message;
  final String? debugMessage;
  //final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    return _CLLoadingViewWidget(
      message: message,
      debugMessage: debugMessage,
    );
  }
}

class _CLLoadingViewPage extends CLLoadingView {
  const _CLLoadingViewPage({
    this.message,
    this.debugMessage,
    this.topBar,
    this.onSwipe,
    this.actions,
    super.key,
  });

  final String? message;
  final String? debugMessage;
  final CLTopBar? topBar;
  final VoidCallback? onSwipe;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final Widget child = _CLLoadingViewWidget(
      message: message,
      debugMessage: debugMessage,
      actions: actions,
    );

    final shouldWrap = !ValidateLayout.isValidLayout(context);

    var content = child;
    if (onSwipe != null) {
      content = OnSwipe(
        onSwipe: onSwipe!,
        child: content,
      );
    }
    if (shouldWrap || topBar != null) {
      return CLScaffold(
        topMenu: topBar,
        body: content,
      );
    }
    return content;
  }
}

class _CLLoadingViewShimmer extends CLLoadingView {
  const _CLLoadingViewShimmer({
    required this.debugMessage,
    this.child,
    super.key,
  });

  final String? debugMessage;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _CLShimmerContent(
      debugMessage: debugMessage,
      shimmer: child,
    );
  }
}

class _CLLoadingViewWizard extends CLLoadingView {
  const _CLLoadingViewWizard({
    required this.message,
    this.debugMessage,
    this.onCancel,
    super.key,
  });

  final String? message;
  final String? debugMessage;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return WizardLayout(
      title: message,
      onCancel: onCancel,
      child: _CLLoadingViewWidget(
        message: message,
        debugMessage: debugMessage,
      ),
    );
  }
}

class _CLLoadingViewCustom extends CLLoadingView {
  const _CLLoadingViewCustom({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _CLLoadingViewWidget extends StatelessWidget {
  const _CLLoadingViewWidget({
    this.debugMessage,
    this.message,
    this.actions,
  });
  final String? message;
  final String? debugMessage;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && debugMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(debugMessage!, style: ShadTheme.of(context).textTheme.p),
            if (actions != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScalingText(message ?? 'Loading ...'),
            if (actions != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      );
    }
  }
}

class _CLShimmerContent extends StatelessWidget {
  const _CLShimmerContent({required this.debugMessage, this.shimmer});
  final String? debugMessage;
  final Widget? shimmer;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    if (shimmer != null) {
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: shimmer!,
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: kDebugMode && debugMessage != null
            ? Center(
                child: Text(
                  debugMessage!,
                  style: ShadTheme.of(context).textTheme.p,
                ),
              )
            : null,
      ),
    );
  }
}
