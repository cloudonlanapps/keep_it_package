import 'package:collection/collection.dart';
import 'package:face_it_desktop/modules/face_recg/models/image_face_mapper.dart';
import 'package:flutter/widgets.dart';

@immutable
class ImageFaceMapperList {
  const ImageFaceMapperList(this.mappers);
  final List<ImageFaceMapper> mappers;

  bool hasImage(String image) => mappers.map((e) => e.image).contains(image);

  ImageFaceMapperList copyWith({List<ImageFaceMapper>? mappers}) {
    return ImageFaceMapperList(mappers ?? this.mappers);
  }

  @override
  String toString() =>
      'ImageFaceMapperList(mappers: ${mappers.length}), status: $status';

  Map<ActivityStatus, int> get status => {
    for (final status in ActivityStatus.values)
      status: mappers.where((e) => e.status == status).length,
  };

  int get count => mappers.length;

  int countByStatus(ActivityStatus status) =>
      mappers.where((e) => e.status == status).length;

  @override
  bool operator ==(covariant ImageFaceMapperList other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.mappers, mappers);
  }

  @override
  int get hashCode => mappers.hashCode;

  ImageFaceMapperList insertImage(String image, {String? serverId}) {
    final List<ImageFaceMapper> updated;
    if (hasImage(image)) {
      if (serverId != null) {
        updated = [
          ...mappers.map(
            (e) => e.image == image ? e.setSessionId(serverId) : e,
          ),
        ];
      } else {
        updated = mappers;
      }
    } else {
      updated = [
        ...mappers,
        ImageFaceMapper(image: image, sessionIdentity: serverId),
      ];
    }
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList removeImage(String image) {
    if (!hasImage(image)) return this;
    final updated = [...mappers.where((e) => e.image != image)];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList setSessionId(String image, String serverId) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setSessionId(serverId) : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList clearSessionId(String image) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setSessionId(null) : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList setError(String image, String error) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setError(error) : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList setIsProcessing(String image) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setIsProcessing() : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList setIsPushed(String image) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setIsPushed() : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList setFaces(String image, List<String> faceIds) {
    if (!hasImage(image)) return this;
    final updated = [
      ...mappers.map((e) => e.image == image ? e.setFaces(faceIds) : e),
    ];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList reset(String image) {
    if (!hasImage(image)) return this;
    final updated = [...mappers.map((e) => e.image == image ? e.reset() : e)];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList resetAll() {
    final updated = [...mappers.map((e) => e.reset())];
    return copyWith(mappers: updated);
  }

  ImageFaceMapperList clearAllSessionId() {
    final updated = [...mappers.map((e) => e.setSessionId(null))];
    return copyWith(mappers: updated);
  }

  ImageFaceMapper? getMapper(String image) {
    return mappers.where((e) => e.image == image).firstOrNull;
  }

  List<String>? getFaceIds(String image) {
    return mappers.where((e) => e.image == image).firstOrNull?.faceIds;
  }

  bool hasFaces(String image) {
    return mappers.where((e) => e.image == image).isNotEmpty;
  }

  List<ImageFaceMapper> get ready =>
      mappers.where((e) => e.status == ActivityStatus.ready).toList();
}
