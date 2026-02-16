import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/server_service/server_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../face_recg/providers/f_faces.dart';
import '../providers/registered_persons.dart';

class PersonViewer extends ConsumerWidget {
  const PersonViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (data) => data);
    if (server == null) {
      return const Center(child: Text('Server not connected'));
    }
    final person = ref
        .watch(registeredPersonsProvider)
        .whenOrNull(data: (data) => data.activePerson);
    if (person == null) {
      return const Center(child: Text('No person is selected'));
    }
    final detectedFaces =
        ref
            .watch(detectedFacesProvider)
            .whenOrNull(data: (data) => data.values) ??
        [];

    final scanned = detectedFaces
        .where((e) {
          final guessed = e.guesses?.firstOrNull?.person;
          final confirmed = e.person;
          return person.id == confirmed?.id || person.id == guessed?.id;
        })
        .map((e) => e.descriptor.imageCache);

    return ShadCard(
      title: Center(
        child: Text(person.name?.capitalizeFirstLetter() ?? 'Unknown'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text('Registerred Faces', style: ShadTheme.of(context).textTheme.h3),
          Wrap(
            spacing: 8,
            children: [
              for (final face in person.faces)
                Stack(
                  children: [
                    Image.network(
                      server.getEndpointURI('/store/face/$face').toString(),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        width: 24,
                        height: 24,
                        padding: EdgeInsets.zero,
                        child: Icon(
                          LucideIcons.trash2400,
                          color: ShadTheme.of(context).colorScheme.destructive,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        width: 24,
                        height: 24,
                        padding: EdgeInsets.zero,
                        child: Icon(MdiIcons.pinOutline),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Text('Detected Faces', style: ShadTheme.of(context).textTheme.h3),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final face in scanned)
                  Stack(
                    children: [
                      Image.file(File(face)),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.zero,
                          child: Icon(
                            LucideIcons.x400,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.destructive,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.zero,
                          child: Icon(MdiIcons.pinOutline),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
