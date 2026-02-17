import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithProviderContext extends StatelessWidget {
  const WithProviderContext({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: child);
  }
}
