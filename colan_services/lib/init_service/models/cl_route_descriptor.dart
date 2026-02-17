import 'package:flutter/material.dart';

typedef CLWidgetBuilder = Widget Function(
  BuildContext context,
  Map<String, String> parameters,
);

@immutable
class CLRouteDescriptor {
  const CLRouteDescriptor({
    required this.name,
    required this.builder,
  });
  final String name;
  final CLWidgetBuilder builder;
}
