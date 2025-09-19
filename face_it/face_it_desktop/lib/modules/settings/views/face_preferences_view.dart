import 'package:face_it_desktop/modules/settings/models/face_box_preferences.dart';
import 'package:face_it_desktop/modules/settings/providers/face_box_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FacePreferencesView extends ConsumerWidget {
  const FacePreferencesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faceBoxPreferences = ref.watch(faceBoxPreferenceProvider);
    return ShadCard(
      padding: const EdgeInsets.all(8),

      child: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              const Text('Faces'),

              SizedBox(
                width: 32,
                child: FittedBox(
                  child: ShadSwitch(
                    value: faceBoxPreferences.enabled,
                    onChanged: (value) {
                      ref
                          .read(faceBoxPreferenceProvider.notifier)
                          .toggle(enable: value);
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,

            children: [
              ...FaceBoxPreferences.colors.take(8).indexed.map((indexColor) {
                final index = indexColor.$1;
                final color = indexColor.$2;

                return GestureDetector(
                  onTap: () => ref
                      .read(faceBoxPreferenceProvider.notifier)
                      .updateColor(index),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: color,
                    ),
                    child: index == faceBoxPreferences.colorIndex
                        ? Icon(
                            LucideIcons.check300,
                            color: ShadTheme.of(context).colorScheme.background,
                          )
                        : null,
                  ),
                );
              }),
              if (FaceBoxPreferences.colors.length < 8)
                for (var i = 0; i < (8 - FaceBoxPreferences.colors.length); i++)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: ShadTheme.of(context).colorScheme.muted,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
