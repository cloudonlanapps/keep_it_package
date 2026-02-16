// Specialized entry point for UI packages
//
// This file exports only the abstract protocols and types needed by
// viewer packages like cl_entity_viewers.

export 'src/cl_media_type.dart' show CLMediaType;
export 'src/value_getter.dart' show ValueGetter;
export 'src/viewer_entity_mixin.dart'
    show
        ViewerEntity,
        ViewerEntityGroup,
        GalleryGroupStoreEntityListQuery,
        UpdateStrategy;
export 'src/viewer_entities.dart' show ViewerEntities;
export 'src/gallery_group.dart' show GalleryGroup;
export 'src/not_null_value.dart' show NotNullValue;

// Export relevant extensions for UI usage
export 'src/extensions/on_date_time.dart'
    show UtilExtensionOnDateTime, TimeStampExtension, DateTimeExtensionOnInt;
export 'src/extensions/on_list.dart' show UtilExtensionOnList;
export 'src/extensions/on_string_nullable.dart'
    show UtilExtensionOnStringNullable;
export 'src/extensions/on_duration.dart' show UtilExtensionOnDuration;
export 'src/extensions/on_num.dart' show UtilExtensionOnNum;
export 'src/cl_logger.dart' show CLLogger;
