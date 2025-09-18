import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoPersonCard extends ConsumerWidget {
  const NoPersonCard({required this.faceId, super.key});
  final String faceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text("marked as 'Not Face'"),
      ),
    );
  }
}
