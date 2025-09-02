import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:meta/meta.dart';

@immutable
class Server {
  const Server({
    required this.identity,
    this.previousIdentity,
    this.workingOffline = true,
  });
  final CLServer identity;
  final bool workingOffline;

  final CLServer? previousIdentity;

  bool get isAccessible => identity.connected;

  bool get canSync => !workingOffline && !isAccessible;
  bool get isOffline => isAccessible;

  Server copyWith({
    CLServer? identity,
    bool? workingOffline,
    ValueGetter<CLServer?>? previousIdentity,
  }) {
    return Server(
      identity: identity ?? this.identity,
      workingOffline: workingOffline ?? this.workingOffline,
      previousIdentity: previousIdentity != null
          ? previousIdentity.call()
          : this.previousIdentity,
    );
  }

  @override
  String toString() =>
      'Server(identity: $identity, workingOffline: $workingOffline, previousIdentity: $previousIdentity)';

  @override
  bool operator ==(covariant Server other) {
    if (identical(this, other)) return true;

    return other.identity == identity &&
        other.workingOffline == workingOffline &&
        other.previousIdentity == previousIdentity;
  }

  @override
  int get hashCode =>
      identity.hashCode ^ workingOffline.hashCode ^ previousIdentity.hashCode;
}
