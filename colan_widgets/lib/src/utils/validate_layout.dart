import 'package:flutter/material.dart';

class ValidateLayout extends InheritedWidget {
  const ValidateLayout({
    required super.child,
    required this.validLayout,
    super.key,
  });
  final bool validLayout;

  @override
  bool updateShouldNotify(ValidateLayout oldWidget) {
    return false;
  }

  static bool isValidLayout(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ValidateLayout>()
            ?.validLayout ??
        false;
  }
}
