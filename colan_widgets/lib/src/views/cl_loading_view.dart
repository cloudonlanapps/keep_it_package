import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/validate_layout.dart';
import 'appearance/cl_scaffold.dart';

enum CLLoaderKind { hidden, widget, shimmer }

class CLLoader extends StatelessWidget {
  factory CLLoader.hide({
    required String? debugMessage,
    Key? key,
    String? message,
  }) {
    return CLLoader._(
      key: key,
      kind: CLLoaderKind.hidden,
      debugMessage: debugMessage,
      message: message,
    );
  }
  factory CLLoader.widget({
    required String? debugMessage,
    Key? key,
    String? message,
  }) {
    return CLLoader._(
      key: key,
      kind: CLLoaderKind.widget,
      debugMessage: debugMessage,
      message: message,
    );
  }
  factory CLLoader.shimmer({
    required String? debugMessage,
    Key? key,
    String? message,
  }) {
    return CLLoader._(
      key: key,
      kind: CLLoaderKind.shimmer,
      debugMessage: debugMessage,
      message: message,
    );
  }
  const CLLoader._({
    required this.kind,
    required this.debugMessage,
    required this.message,
    super.key,
  });
  final CLLoaderKind kind;
  final String? message;
  final String? debugMessage;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      CLLoaderKind.hidden =>
        kDebugMode
            ? CLLoaderWidget(
                debugMessage: debugMessage,
                message: null,
              )
            : const SizedBox.shrink(),
      CLLoaderKind.widget => CLLoaderWidget(
        message: message,
        debugMessage: debugMessage,
      ),
      CLLoaderKind.shimmer => CLLoaderShimmer(
        debugMessage: debugMessage,
      ),
    };
  }
}

class CLLoaderWidget extends StatelessWidget {
  const CLLoaderWidget({
    required this.debugMessage,
    required this.message,
    super.key,
  });
  final String? message;
  final String? debugMessage;
  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (kDebugMode && debugMessage != null) {
      child = Center(
        child: Text(debugMessage!, style: ShadTheme.of(context).textTheme.p),
      );
    } else {
      child = Center(child: ScalingText(message ?? 'Loading ...'));
    }
    if (ValidateLayout.isValidLayout(context)) {
      return child;
    }
    return CLScaffold(body: child);
  }
}

class CLLoaderShimmer extends StatelessWidget {
  const CLLoaderShimmer({required this.debugMessage, super.key});
  final String? debugMessage;

  @override
  Widget build(BuildContext context) {
    final Widget content = Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
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

    if (ValidateLayout.isValidLayout(context)) {
      return content;
    }
    return CLScaffold(body: content);
  }
}
