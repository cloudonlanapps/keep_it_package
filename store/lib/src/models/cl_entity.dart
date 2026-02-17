import 'dart:convert';

import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_extensions/cl_extensions.dart'
    show TimeStampExtension, ValueGetter;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class CLEntity {
  const CLEntity({
    required this.isCollection,
    required this.addedDate,
    required this.updatedDate,
    required this.isDeleted,
    required this.id,
    required this.label,
    required this.description,
    required this.parentId,
    required this.md5,
    required this.fileSize,
    required this.mimeType,
    required this.type,
    required this.extension,
    required this.createDate,
    required this.height,
    required this.width,
    required this.duration,
    required this.isHidden,
    required this.pin,
    required this.faces,
  });

  factory CLEntity.fromMap(Map<String, dynamic> map) {
    return CLEntity(
      id: map['id'] != null ? map['id'] as int : null,
      isCollection: (map['isCollection'] ?? 0) != 0,
      addedDate: DateTime.fromMillisecondsSinceEpoch(
        (map['addedDate'] ?? 0) as int,
      ),
      updatedDate: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedDate'] ?? 0) as int,
      ),
      isDeleted: (map['isDeleted'] ?? 0) != 0,
      label: map['label'] != null ? map['label'] as String : null,
      description: map['description'] != null
          ? map['description'] as String
          : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      md5: map['md5'] != null ? map['md5'] as String : null,
      fileSize: map['fileSize'] != null ? map['fileSize'] as int : null,
      mimeType: map['mimeType'] != null ? map['mimeType'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      extension: map['extension'] != null ? map['extension'] as String : null,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createDate'] ?? 0) as int)
          : null,
      height: map['height'] != null ? map['height'] as int : null,
      width: map['width'] != null ? map['width'] as int : null,
      duration: map['duration'] != null ? map['duration'] as double : null,
      isHidden: (map['isHidden'] ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      faces: map['faces'] != null
          ? (map['faces'] as List).cast<String>()
          : null,
    );
  }

  factory CLEntity.fromJson(String source) =>
      CLEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  // Change to factory!
  factory CLEntity.collection({
    required String label,
    int? id,
    String? description,
    int? parentId,
  }) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      isCollection: true,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: false,
      id: id,
      label: label,
      description: description,
      parentId: parentId,
      md5: null,
      fileSize: null,
      mimeType: null,
      type: null,
      extension: null,
      createDate: null,
      height: null,
      width: null,
      duration: null,
      isHidden: false,
      pin: null,
      faces: null,
    );
  }

  factory CLEntity.media({
    required bool isDeleted,
    required String md5,
    required int fileSize,
    required String mimeType,
    required String type,
    required String extension,
    int? id,
    String? label,
    String? description,
    int? parentId,
    DateTime? createDate,
    int? height,
    int? width,
    double? duration,
    bool isHidden = false,
    String? pin,
    List<String>? faces,
  }) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      isCollection: false,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      id: id,
      label: label,
      description: description,
      parentId: parentId,
      md5: md5,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      extension: extension,
      createDate: createDate,
      height: height,
      width: width,
      duration: duration,
      isHidden: isHidden,
      pin: pin,
      faces: faces,
    );
  }

  final int? id;
  final bool isCollection;
  final DateTime addedDate;
  final DateTime updatedDate;
  final bool isDeleted;

  final String? label;
  final String? description;
  final int? parentId;

  final String? md5;
  final int? fileSize;
  final String? mimeType;
  final String? type;
  final String? extension;

  final DateTime? createDate;
  final int? height;
  final int? width;
  final double? duration;

  final bool isHidden;
  final String? pin;
  final List<String>? faces;

  CLEntity copyWith({
    ValueGetter<int?>? id,
    bool? isCollection,
    DateTime? addedDate,
    DateTime? updatedDate,
    bool? isDeleted,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<String?>? md5,
    ValueGetter<int?>? fileSize,
    ValueGetter<String?>? mimeType,
    ValueGetter<String?>? type,
    ValueGetter<String?>? extension,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<int?>? height,
    ValueGetter<int?>? width,
    ValueGetter<double?>? duration,
    bool? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<List<String>?>? faces,
  }) {
    return CLEntity(
      id: id != null ? id.call() : this.id,
      isCollection: isCollection ?? this.isCollection,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      isDeleted: isDeleted ?? this.isDeleted,
      label: label != null ? label.call() : this.label,
      description: description != null ? description.call() : this.description,
      parentId: parentId != null ? parentId.call() : this.parentId,
      md5: md5 != null ? md5.call() : this.md5,
      fileSize: fileSize != null ? fileSize.call() : this.fileSize,
      mimeType: mimeType != null ? mimeType.call() : this.mimeType,
      type: type != null ? type.call() : this.type,
      extension: extension != null ? extension.call() : this.extension,
      createDate: createDate != null ? createDate.call() : this.createDate,
      height: height != null ? height.call() : this.height,
      width: width != null ? width.call() : this.width,
      duration: duration != null ? duration.call() : this.duration,
      isHidden: isHidden ?? this.isHidden,
      pin: pin != null ? pin.call() : this.pin,
      faces: faces != null ? faces() : this.faces,
    );
  }

  @override
  String toString() {
    return 'CLEntity(id: $id, isCollection: $isCollection, addedDate: $addedDate, updatedDate: $updatedDate, isDeleted: $isDeleted, label: $label, description: $description, parentId: $parentId, md5: $md5, fileSize: $fileSize, mimeType: $mimeType, type: $type, extension: $extension, createDate: $createDate, height: $height, width: $width, duration: $duration, isHidden: $isHidden, pin: $pin, faces: $faces)';
  }

  @override
  bool operator ==(covariant CLEntity other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.isCollection == isCollection &&
        other.addedDate == addedDate &&
        other.updatedDate == updatedDate &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.description == description &&
        other.parentId == parentId &&
        other.md5 == md5 &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.type == type &&
        other.extension == extension &&
        other.createDate == createDate &&
        other.height == height &&
        other.width == width &&
        other.duration == duration &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        listEquals(other.faces, faces);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isCollection.hashCode ^
        addedDate.hashCode ^
        updatedDate.hashCode ^
        isDeleted.hashCode ^
        label.hashCode ^
        description.hashCode ^
        parentId.hashCode ^
        md5.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode ^
        type.hashCode ^
        extension.hashCode ^
        createDate.hashCode ^
        height.hashCode ^
        width.hashCode ^
        duration.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        faces.hashCode;
  }

  DateTime get sortDate => createDate ?? updatedDate;

  CLMediaType get mediaType => isCollection
      ? CLMediaType.collection
      : CLMediaType.values.asNameMap()[type]!;

  CLEntity clone({ValueGetter<int?>? id}) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      id: id != null ? id() : this.id,
      isCollection: isCollection,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      label: label,
      description: description,
      parentId: parentId,
      md5: md5,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      extension: extension,
      createDate: createDate,
      height: height,
      width: width,
      duration: duration,
      isHidden: isHidden,
      pin: pin,
      faces: faces,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isCollection': isCollection,
      'addedDate': addedDate.utcTimeStamp,
      'updatedDate': updatedDate.utcTimeStamp,
      'isDeleted': isDeleted,
      'label': label,
      'description': description,
      'parentId': parentId,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type,
      'extension': extension,
      'createDate': createDate?.utcTimeStamp,
      'height': height,
      'width': width,
      'duration': duration,
      'isHidden': isHidden,
      'pin': pin,
      'faces': faces,
    };
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMapForDisplay() {
    return <String, dynamic>{
      'id': id,
      'isCollection': isCollection,
      'addedDate': addedDate.utcTimeStamp,
      'updatedDate': updatedDate.utcTimeStamp,
      'isDeleted': isDeleted,
      'label': label,
      'description': description,
      'parentId': parentId,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type,
      'extension': extension,
      'createDate': createDate?.utcTimeStamp,
      'height': height,
      'width': width,
      'duration': duration,
      'isHidden': isHidden,
      'pin': pin,
      'faces': faces,
    }..removeWhere((key, value) => value == null);
  }

  String get descriptionText => description ?? '';
  /* String get labelText => label ?? '';
  String get pinText => pin ?? '';
  String get fileSizeText =>
      fileSize != null ? '${fileSize! / 1024} KB' : 'Unknown Size';
  String get mimeTypeText => mimeType ?? '';
  String get typeText => type ?? '';
  String get extensionText => extension ?? '';
  String get createDateText => createDate != null
      ? '${createDate!.day}/${createDate!.month}/${createDate!.year}'
      : '';
  String get heightText => height != null ? '$height px' : '';
  String get widthText => width != null ? '$width px' : '';
  String get durationText => duration != null ? '$duration sec' : '';
  String get addedDateText =>
      '${addedDate.day}/${addedDate.month}/${addedDate.year}';
  String get updatedDateText =>
      '${updatedDate.day}/${updatedDate.month}/${updatedDate.year}';
  String get isDeletedText => isDeleted ? 'Deleted' : 'Not Deleted';
  String get isHiddenText => isHidden ? 'Hidden' : 'Not Hidden';
  String get isCollectionText => isCollection ? 'Collection' : 'Not Collection'; */

  bool isSame(covariant CLEntity other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.isCollection == isCollection &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.description == description &&
        other.parentId == parentId &&
        other.md5 == md5 &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.type == type &&
        other.extension == extension &&
        other.createDate == createDate &&
        other.height == height &&
        other.width == width &&
        other.duration == duration &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        listEquals(other.faces, faces);
  }

  bool isContentSame(covariant CLEntity other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
    return other.id == id &&
        other.isCollection == isCollection &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.description == description &&
        other.parentId == parentId &&
        other.md5 == md5 &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.type == type &&
        other.extension == extension &&
        other.createDate == createDate &&
        other.height == height &&
        other.width == width &&
        other.duration == duration &&
        listEquals(other.faces, faces);
  }

  String? get path => isCollection ? null : '$mimeType/$md5$extension';
  String? get previewPath => isCollection ? null : '$path.tn.jpg';

  CLEntity updateFaces(ValueGetter<List<String>?> faces) {
    return copyWith(faces: faces);
  }
}
