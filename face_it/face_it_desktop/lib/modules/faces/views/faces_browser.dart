import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/modules/faces/models/registered_person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/models/main_content_type.dart';
import '../../../app/providers/main_content_type.dart';
import '../providers/registered_persons.dart';

class FacesBrowser extends ConsumerWidget {
  const FacesBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(registeredPersonsProvider);
    final persons = personsAsync.whenOrNull(data: (data) => data.persons) ?? [];

    if (persons.isEmpty) {
      return Center(
        child: Text(
          'Nothing to show',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      );
    }
    persons.sort((a, b) => a.name.compareTo(b.name));
    return ListView.builder(
      // The number of items to build in the list
      itemCount: persons.length + 1,
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      // The builder function that creates each item
      itemBuilder: (BuildContext context, int index) {
        if (index == persons.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(title: Text('Unknown Faces')),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: PersonTile(person: persons[index]),
        );
      },
    );
  }
}

class PersonTile extends ConsumerWidget {
  const PersonTile({required this.person, super.key});

  final RegisteredPerson person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref
        .watch(activeAIServerProvider)
        .whenOrNull(data: (data) => data);
    final keyFace = person.keyFaceId ?? person.faces[0];
    final faceUri = server?.getEndpointURI('/store/face/$keyFace');
    print(faceUri);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: faceUri == null
          ? null
          : Image.network(faceUri.toString(), width: 64, height: 64),
      subtitle: Text(
        ' ${person.faces.length} faces registerred',
        style: ShadTheme.of(context).textTheme.muted.copyWith(
          fontSize: ShadTheme.of(context).textTheme.small.fontSize,
        ),
      ),

      /* leading: Media(filePath: file.path, width: 64, height: 64),
      
      subtitle: ,
      trailing: MediaPopoverMenu(file: file),
      onTap: onTap, */
      title: Text(person.name.capitalizeFirstLetter()),
      onTap: () {
        ref.read(activeMainContentTypeProvider.notifier).state =
            MainContentType.person;
        ref.read(registeredPersonsProvider.notifier).setActive(person);
      },
    );
  }
}
