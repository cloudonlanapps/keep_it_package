import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart' show ValueGetter;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:store/src/models/cl_store.dart';

import 'cl_entity.dart';

@immutable
class StoreEntity implements ViewerEntity {
  factory StoreEntity({
    required CLEntity clEntity,
    required CLStore clStore,
  }) {
    return StoreEntity._(
      clEntity: clEntity,
      store: clStore,
    );
  }
  const StoreEntity._({
    required this.clEntity,
    required this.store,
  });

  final CLEntity clEntity;
  final CLStore store;

  @override
  Future<StoreEntity?> updateWith({
    CLMediaFile? mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy? strategy,
    bool autoSave = false,
  }) async {
    StoreEntity? updated;
    if (isCollection) {
      updated = await store.updateCollection(
        clEntity,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    } else {
      updated = await store.updateMedia(
        clEntity,
        mediaFile: mediaFile,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        pin: pin,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    }
    if (updated != null && autoSave) {
      return StoreEntity(
        clEntity: updated.clEntity,
        clStore: store,
      ).dbSave(mediaFile?.path);
    }
    return updated;
  }

  Future<StoreEntity?> cloneWith({
    required CLMediaFile mediaFile,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    UpdateStrategy? strategy,
    bool autoSave = false,
  }) async {
    final updated = await store.updateMedia(
      clEntity,
      mediaFile: mediaFile,
      label: label,
      description: description,
      parentId: parentId,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: pin,
      strategy: strategy ?? UpdateStrategy.mergeAppend,
    );
    if (updated == null) {
      return null;
    }

    return clone(id: () => null).dbSave(mediaFile.path);
  }

  Future<StoreEntity?> dbSave([String? path]) {
    return store.dbSave(this, path: path);
  }

  Future<void> delete() async {
    if (clEntity.id == null) {
      throw Exception("id can't be null");
    }
    await store.delete(clEntity.id!);
  }

  Future<StoreEntity> accept(StoreEntity entity) async {
    if (!isCollection) {
      throw Exception(
        "A media entity can't accept another media. Use collection",
      );
    }
    if (id == null) {
      throw Exception('the collection must saved before accepting media');
    }
    return entity.store.move(entity, this);
  }

  Future<StoreEntity?> onPin() async {
    // Pin here, if not pinned
    return updateWith(pin: () => 'PIN TEST');
  }

  Future<StoreEntity?> onUnpin() async {
    // remove Pin here, if not pinned
    return updateWith(pin: () => null);
  }

  @override
  int? get id => clEntity.id;

  @override
  bool get isCollection => clEntity.isCollection;

  @override
  DateTime? get createDate => clEntity.createDate;
  @override
  DateTime get updatedDate => clEntity.updatedDate;

  @override
  int? get parentId => clEntity.parentId;

  @override
  Uri? get mediaUri => store.entityStore.mediaUri(clEntity);
  @override
  Uri? get previewUri => store.entityStore.previewUri(clEntity);

  @override
  String toString() => 'StoreEntity(entity: $clEntity, store: $store';

  @override
  bool operator ==(covariant StoreEntity other) {
    if (identical(this, other)) return true;

    return other.clEntity == clEntity && other.store == store;
  }

  @override
  int get hashCode => clEntity.hashCode ^ store.hashCode;

  @override
  CLMediaType get mediaType =>
      clEntity.isCollection ? CLMediaType.collection : clEntity.mediaType;

  @override
  String get searchableTexts =>
      [clEntity.label, clEntity.description].join(' ').toLowerCase();

  @override
  String? get label => clEntity.label;

  @override
  String? get mimeType => clEntity.mimeType;

  @override
  String? get pin => clEntity.pin;

  @override
  String? get dateString =>
      DateFormat('dd MMM, yyyy').format(createDate ?? updatedDate);

  @override
  bool get isHidden => clEntity.isHidden;

  String? get description => clEntity.extension;
  String? get md5 => clEntity.md5;
  int? get fileSize => clEntity.fileSize;
  String? get type => clEntity.type;
  String? get extension => clEntity.extension;
  bool get isDeleted => clEntity.isDeleted;

  int? get height => clEntity.height;
  int? get width => clEntity.width;
  double? get duration => clEntity.duration;

  Map<String, dynamic> toMapForDisplay() => clEntity.toMapForDisplay();
  StoreEntity clone({ValueGetter<int?>? id}) => StoreEntity(
    clEntity: clEntity.clone(id: id),
    clStore: store,
  );
}
