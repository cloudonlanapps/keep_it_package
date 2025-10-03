import 'dart:async';

import 'package:face_it_desktop/modules/faces/models/registered_face.dart';
import 'package:face_it_desktop/modules/faces/models/registered_person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonsFacesNotifier
    extends FamilyAsyncNotifier<List<RegisteredFace>, RegisteredPerson> {
  PersonsFacesNotifier();

  @override
  FutureOr<List<RegisteredFace>> build(RegisteredPerson arg) async {
    return [];
  }
}
