import 'package:cl_extensions/cl_extensions.dart';

import 'cl_media_file.dart';
import 'cl_media_type.dart';

enum UpdateStrategy { skip, overwrite, mergeAppend }

abstract class ViewerEntity {
  int? get id;
  bool get isCollection;
  DateTime? get createDate;
  DateTime get updatedDate;
  int? get parentId;
  Uri? get mediaUri;
  Uri? get previewUri;
  String get searchableTexts;
  CLMediaType get mediaType;
  String? get mimeType;
  String? get label;
  String? get pin;
  bool get isHidden;
  int? get childrenCount;

  String? get dateString;
  Future<ViewerEntity?> updateWith({
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy? strategy,
    bool autoSave = false,
  });
}

class ViewerEntityGroup<T extends ViewerEntity> {
  const ViewerEntityGroup(
    this.items, {
    required this.chunkIdentifier,
    required this.groupIdentifier,
    required this.label,
  });
  final String chunkIdentifier;
  final String groupIdentifier;
  final String? label;
  final List<T> items;

  Set<int?> get getEntityIds => items.map((e) => e.id).toSet();
}

extension GalleryGroupStoreEntityListQuery<T extends ViewerEntity>
    on List<ViewerEntityGroup<T>> {
  Set<int?> get getEntityIds => expand((item) => item.getEntityIds).toSet();
  Set<T> get getEntities => expand((item) => item.items).toSet();

  Set<int?> getEntityIdsByGroup(String groupIdentifier) => where(
    (e) => e.groupIdentifier == groupIdentifier,
  ).expand((item) => item.getEntityIds).toSet();

  Set<T> getEntitiesByGroup(String groupIdentifier) => where(
    (e) => e.groupIdentifier == groupIdentifier,
  ).expand((item) => item.items).toSet();
}
