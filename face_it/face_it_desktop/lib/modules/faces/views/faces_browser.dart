import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:face_it_desktop/modules/faces/models/registered_person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app/models/main_content_type.dart';
import '../../../app/providers/main_content_type.dart';
import '../../../services/ai_server_service/ai_server_service.dart';
import '../providers/registered_persons.dart';

final knownRegisteredPersonsProvider = StateProvider<List<RegisteredPerson>>((
  ref,
) {
  final personsAsync = ref.watch(registeredPersonsProvider);
  return personsAsync.whenOrNull(
        data: (data) =>
            data.persons.where((e) => e.isNamed).toList()
              ..sort((a, b) => a.compareTo(b)),
      ) ??
      [];
});
final unknownRegisteredPersonsProvider = StateProvider<List<RegisteredPerson>>((
  ref,
) {
  final personsAsync = ref.watch(registeredPersonsProvider);
  return personsAsync.whenOrNull(
        data: (data) =>
            data.persons.where((e) => !e.isNamed).toList()
              ..sort((a, b) => a.compareTo(b)),
      ) ??
      [];
});

class FacesBrowser extends ConsumerWidget {
  const FacesBrowser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knownPersons = ref.watch(knownRegisteredPersonsProvider);

    /* if (knownPersons.isEmpty) {
      return Center(
        child: Text(
          'Nothing to show',
          style: ShadTheme.of(context).textTheme.muted,
        ),
      );
    } */

    return ListView.builder(
      // The number of items to build in the list
      itemCount: knownPersons.length + 1,
      shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      // The builder function that creates each item
      itemBuilder: (context, index) {
        if (index == knownPersons.length) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: UnknownPersonTile(),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: PersonTile(person: knownPersons[index]),
        );
      },
    );
  }
}

class UnknownPersonTile extends StatelessWidget {
  const UnknownPersonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Unknown Faces'),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: SizedBox.square(
        dimension: 64,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Icon(LucideIcons.squareUser400),
            //child: Icon(LucideIcons.shieldQuestionMark100),
          ),
        ),
      ),
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
      title: Text(person.name?.capitalizeFirstLetter() ?? 'Unknown'),
      onTap: () {
        ref.read(activeMainContentTypeProvider.notifier).state =
            MainContentType.person;
        ref.read(registeredPersonsProvider.notifier).setActive(person);
      },
    );
  }
}
