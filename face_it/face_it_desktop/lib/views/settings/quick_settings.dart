import 'package:face_it_desktop/views/settings/face_preferences_view.dart';
import 'package:flutter/material.dart';

class QuickSettings extends StatelessWidget {
  const QuickSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(spacing: 8, children: [FacePreferencesView()]);
  }
}
