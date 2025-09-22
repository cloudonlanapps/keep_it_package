import '../cl_server.dart';
import 'detected_face.dart';
import 'registered_person.dart';

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
