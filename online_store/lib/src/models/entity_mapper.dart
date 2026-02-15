import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart' as sdk;

/// Maps between CLEntity and DartSDK Entity models.
///
/// Key differences:
/// - Date fields: CLEntity uses DateTime, DartSDK uses int milliseconds
/// - Client-side fields: isHidden, pin, faces (not stored on server)
/// - Server-only fields: addedBy, updatedBy, filePath, isIndirectlyDeleted, intelligenceData
class EntityMapper {
  /// Convert DartSDK Entity to CLEntity.
  static CLEntity fromSdkEntity(sdk.Entity entity) {
    return CLEntity(
      // Core fields
      id: entity.id,
      isCollection: entity.isCollection ?? false,
      label: entity.label,
      description: entity.description,
      parentId: entity.parentId,

      // Audit fields - convert milliseconds to DateTime
      addedDate: entity.addedDate != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.addedDate!)
          : DateTime.now(),
      updatedDate: entity.updatedDate != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.updatedDate!)
          : DateTime.now(),
      isDeleted: entity.isDeleted ?? false,

      // Media fields
      md5: entity.md5,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      type: entity.type,
      extension: entity.extension,
      createDate: entity.createDate != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.createDate!)
          : null,
      height: entity.height,
      width: entity.width,
      duration: entity.duration,

      // Client-side only fields (not in DartSDK)
      isHidden: false, // Default - not stored on server
      pin: null, // Not stored on server
      faces: null, // Removed - now in intelligenceData
    );
  }

  /// Convert list of DartSDK Entities to list of CLEntities.
  static List<CLEntity> fromSdkEntities(List<sdk.Entity> entities) {
    return entities.map(fromSdkEntity).toList();
  }

  /// Convert CLEntity to DartSDK Entity (for reference - not typically used).
  ///
  /// Note: This loses client-side fields (isHidden, pin, faces) as they
  /// aren't stored on the server.
  static sdk.Entity toSdkEntity(CLEntity entity) {
    return sdk.Entity(
      id: entity.id!,
      isCollection: entity.isCollection,
      label: entity.label,
      description: entity.description,
      parentId: entity.parentId,
      addedDate: entity.addedDate.millisecondsSinceEpoch,
      updatedDate: entity.updatedDate.millisecondsSinceEpoch,
      isDeleted: entity.isDeleted,
      md5: entity.md5,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      type: entity.type,
      extension: entity.extension,
      createDate: entity.createDate?.millisecondsSinceEpoch,
      height: entity.height,
      width: entity.width,
      duration: entity.duration,
      // Server-only fields not included:
      // - addedBy, updatedBy, filePath, isIndirectlyDeleted, intelligenceData
    );
  }
}
