import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_route_descriptor.dart';

typedef CLAppInitializer = Future<bool> Function(Ref ref);
typedef CLTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);
typedef CLRedirector = Future<String?> Function(String location);

abstract class AppDescriptor {
  String get title;

  List<CLRouteDescriptor> get screens;

  CLAppInitializer get appInitializer;
  CLTransitionBuilder get transitionBuilder;
  CLRedirector get redirector;
}
