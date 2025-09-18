import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/f_faces.dart';
import 'face_info_card.dart';

class FacesView extends ConsumerWidget {
  const FacesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facesMapAsync = ref.watch(detectedFacesProvider);
    return facesMapAsync.when(
      data: (facesMap) {
        if (facesMap.isEmpty) {
          return Center(
            child: Text(
              'Import files and scan for faces to collect faces',
              style: ShadTheme.of(context).textTheme.muted,
            ),
          );
        }
        final faces = facesMap.values.toList();
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // number of columns
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3, // wider than tall (for ListTile-like look)
          ),
          itemCount: faces.length,
          itemBuilder: (context, index) {
            final face = faces[index];
            return Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                spacing: 8,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.file(
                        File(face.descriptor.imageCache),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FaceInfoCard(
                        faceId: face.descriptor.identity,
                        hasActions: false,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      error: (e, st) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
