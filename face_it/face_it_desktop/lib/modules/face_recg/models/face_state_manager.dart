import 'package:colan_services/server_service/server_service.dart';

import '../../faces/models/registered_person.dart';
import 'detected_face.dart';

abstract interface class FaceStateManager {
  DetectedFace markNotAFace();
  DetectedFace markAsUnknown();

  DetectedFace confirmTaggedFace(RegisteredPerson person);
  DetectedFace rejectTaggedPerson(RegisteredPerson person);
  DetectedFace removeConfirmation();
  DetectedFace isAFace();

  Future<DetectedFace> register(CLServer server, String name);
  Future<DetectedFace> searchDB(CLServer server);
}
