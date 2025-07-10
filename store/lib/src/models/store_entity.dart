import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:store/src/models/cl_store.dart';

@immutable
class StoreEntity implements ViewerEntity {
  factory StoreEntity({
    required CLEntity entity,
    required CLStore store,
    //   String? path,
  }) {
    return StoreEntity._(
      data: entity,
      store: store,
      //    path: path,
    );
  }
  const StoreEntity._({
    required this.data,
    required this.store,
    //   this.path,
  });

  final CLEntity data;
  final CLStore store;
//  final String? path;

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
    if (data.isCollection) {
      updated = await store.updateCollection(
        data,
        label: label,
        description: description,
        parentId: parentId,
        isDeleted: isDeleted,
        isHidden: isHidden,
        strategy: strategy ?? UpdateStrategy.mergeAppend,
      );
    } else {
      updated = await store.updateMedia(
        data,
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
        entity: updated.data,
        store: store,
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
      data,
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

    return StoreEntity(
      entity: updated.data.clone(id: () => null),
      store: store,
    ).dbSave(mediaFile.path);
  }

  Future<StoreEntity?> dbSave([String? path]) {
    return store.dbSave(this, path: path);
  }

  Future<void> delete() async {
    if (data.id == null) {
      throw Exception("id can't be null");
    }
    await store.delete(data.id!);
  }

  Future<StoreEntity> accept(StoreEntity entity) async {
    if (!isCollection) {
      throw Exception(
          "A media entity can't accept another media. Use collection");
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
  int? get id => data.id;

  @override
  bool get isCollection => data.isCollection;

  @override
  DateTime? get createDate => data.createDate;
  @override
  DateTime get updatedDate => data.updatedDate;

  @override
  int? get parentId => data.parentId;

  @override
  Uri? get mediaUri => store.store.mediaUri(data);
  @override
  Uri? get previewUri => store.store.previewUri(data);

  @override
  String toString() => 'StoreEntity(entity: $data, store: $store';

  @override
  bool operator ==(covariant StoreEntity other) {
    if (identical(this, other)) return true;

    return other.data == data && other.store == store;
  }

  @override
  int get hashCode => data.hashCode ^ store.hashCode;

  @override
  CLMediaType get mediaType =>
      data.isCollection ? CLMediaType.collection : data.mediaType;

  @override
  String get searchableTexts =>
      [data.label, data.description].join(' ').toLowerCase();

  @override
  String? get label => data.label;

  @override
  String? get mimeType => data.mimeType;

  @override
  String? get pin => data.pin;

  @override
  String? get dateString =>
      DateFormat('dd MMM, yyyy').format(createDate ?? updatedDate);

  @override
  bool get isHidden => data.isHidden;

  String? get description => data.extension;
  String? get md5 => data.md5;
  int? get fileSize => data.fileSize;
  String? get type => data.type;
  String? get extension => data.extension;
  bool get isDeleted => data.isDeleted;

  int? get height => data.height;
  int? get width => data.width;
  double? get duration => data.duration;
}
