# DartSDK Feature Requests for OnlineEntityStore Migration

**Date**: 2026-02-14
**Purpose**: Document gaps between current DartSDK capabilities and UI requirements for migrating from CLServer to DartSDK StoreManager

## Executive Summary

This document identifies missing capabilities in DartSDK that are required to fully replace CLServer-based OnlineEntityStore implementation. These features must be implemented in:
1. **Store Server** (Python FastAPI)
2. **PySDK** (Python client)
3. **DartSDK** (Dart client)

## Current State Analysis

### What DartSDK Currently Supports ✅

**Entity Management**:
- ✅ `GET /entities` - List entities with pagination
- ✅ `GET /entities/{id}` - Read single entity
- ✅ `POST /entities` - Create entity
- ✅ `PUT /entities/{id}` - Update entity (full replace)
- ✅ `PATCH /entities/{id}` - Partial update entity
- ✅ `DELETE /entities/{id}` - Delete entity (hard delete)
- ✅ `DELETE /faces/{id}` - Delete face
- ✅ `GET /entities/{id}/versions` - Get version history

**Media Access**:
- ✅ `GET /entities/{id}/media` - Download media file
- ✅ `GET /entities/{id}/preview` - Download preview
- ✅ `GET /entities/{id}/stream/adaptive.m3u8` - HLS streaming

**Intelligence Data**:
- ✅ `GET /intelligence/entities/{id}` - Get intelligence data
- ✅ `GET /intelligence/entities/{id}/faces` - Get entity faces
- ✅ `GET /intelligence/entities/{id}/jobs` - Get entity jobs
- ✅ `GET /intelligence/faces/{id}/embedding` - Download face embedding
- ✅ `GET /intelligence/entities/{id}/clip_embedding` - Download CLIP embedding
- ✅ `GET /intelligence/entities/{id}/dino_embedding` - Download DINO embedding

**Known Persons (Face Recognition)**:
- ✅ `GET /intelligence/known-persons` - List all known persons
- ✅ `GET /intelligence/known-persons/{id}` - Get person details
- ✅ `GET /intelligence/known-persons/{id}/faces` - Get person faces
- ✅ `PATCH /intelligence/known-persons/{id}` - Update person name

**Admin**:
- ✅ `GET /admin/pref` - Get preferences
- ✅ `PUT /admin/pref/guest-mode` - Update guest mode
- ✅ `GET /system/audit` - Audit data integrity
- ✅ `POST /system/clear-orphans` - Clear orphaned resources
- ✅ `GET /m_insight/status` - Get MInsight status

### Current Filters in `listEntities()` ✅

The `GET /entities` endpoint supports these filters:
- ✅ `page`, `page_size` - Pagination
- ✅ `version` - Retrieve at specific version
- ✅ `search_query` - Fuzzy text search
- ✅ `exclude_deleted` - Exclude soft-deleted entities
- ✅ `md5` - Filter by MD5 checksum
- ✅ `mime_type` - Filter by MIME type
- ✅ `type` - Filter by media type (image/video/audio)
- ✅ `width` - Filter by exact width
- ✅ `height` - Filter by exact height
- ✅ `file_size_min`, `file_size_max` - Filter by file size range
- ✅ `date_from`, `date_to` - Filter by date range

---

## Critical Missing Features (HIGH PRIORITY)

### 1. Missing Filters in `listEntities()` 🚨

**Problem**: UI requires filtering by `parentId` and `isCollection` for folder navigation and file/folder separation. These are **CRITICAL** for basic app functionality.

**Current Impact**:
- Cannot efficiently browse folder contents (must fetch all entities and filter client-side)
- Cannot separate folders from files without fetching everything
- Severe performance impact on large libraries (thousands of entities)

**Required Changes**:

#### 1.1 Add `parent_id` filter

**Store Server** (`services/store/src/store/store/routes.py`):
```python
@router.get("/entities")
async def get_entities(
    # ... existing parameters ...
    parent_id: int | None = Query(None, description="Filter by parent collection ID"),
    # ... rest of parameters ...
)
```

**Store Server** (`services/store/src/store/store/service.py`):
```python
def get_entities(
    self,
    # ... existing parameters ...
    parent_id: int | None = None,
    # ...
) -> tuple[list[EntitySchema], int]:
    # Add filter condition:
    if parent_id is not None:
        query = query.filter(EntityVersion.parent_id == parent_id)
```

**PySDK** (pysdk client method):
```python
def list_entities(
    self,
    # ... existing parameters ...
    parent_id: Optional[int] = None,
    # ...
) -> EntityListResponse:
    params = {
        # ... existing params ...
        'parent_id': parent_id,
    }
```

**DartSDK** (`lib/src/clients/store_client.dart`):
```dart
Future<EntityListResponse> listEntities({
  // ... existing parameters ...
  int? parentId,
  // ...
}) async {
  final queryParams = <String, dynamic>{
    // ... existing params ...
    if (parentId != null) 'parent_id': parentId.toString(),
  };
}
```

**DartSDK** (`lib/src/managers/store_manager.dart`):
```dart
Future<StoreOperationResult<EntityListResponse>> listEntities({
  // ... existing parameters ...
  int? parentId,
  // ...
}) async {
  final result = await storeClient.listEntities(
    // ... existing params ...
    parentId: parentId,
  );
}
```

#### 1.2 Add `is_collection` filter

**Store Server** (`services/store/src/store/store/routes.py`):
```python
@router.get("/entities")
async def get_entities(
    # ... existing parameters ...
    is_collection: bool | None = Query(None, description="Filter by collection vs media"),
    # ... rest of parameters ...
)
```

**Store Server** (`services/store/src/store/store/service.py`):
```python
def get_entities(
    self,
    # ... existing parameters ...
    is_collection: bool | None = None,
    # ...
) -> tuple[list[EntitySchema], int]:
    # Add filter condition:
    if is_collection is not None:
        query = query.filter(EntityVersion.is_collection == is_collection)
```

**PySDK** (pysdk client method):
```python
def list_entities(
    self,
    # ... existing parameters ...
    is_collection: Optional[bool] = None,
    # ...
) -> EntityListResponse:
    params = {
        # ... existing params ...
        'is_collection': is_collection,
    }
```

**DartSDK** (`lib/src/clients/store_client.dart`):
```dart
Future<EntityListResponse> listEntities({
  // ... existing parameters ...
  bool? isCollection,
  // ...
}) async {
  final queryParams = <String, dynamic>{
    // ... existing params ...
    if (isCollection != null) 'is_collection': isCollection.toString(),
  };
}
```

**DartSDK** (`lib/src/managers/store_manager.dart`):
```dart
Future<StoreOperationResult<EntityListResponse>> listEntities({
  // ... existing parameters ...
  bool? isCollection,
  // ...
}) async {
  final result = await storeClient.listEntities(
    // ... existing params ...
    isCollection: isCollection,
  );
}
```

**Priority**: **CRITICAL** - Cannot proceed with migration without these filters

---

### 2. Direct Entity Lookup Endpoint 📌

**Problem**: Current UI uses direct lookup by `md5` OR `label` to find specific entities. Using `listEntities(md5='...', pageSize=1)` works but is inefficient.

**Requested Endpoint**: `GET /entities/lookup?md5={md5}&label={label}`

**Store Server** (`services/store/src/store/store/routes.py`):
```python
@router.get(
    "/entities/lookup",
    tags=["entity"],
    summary="Lookup Entity",
    description="Find entity by MD5 or label (returns first match).",
    operation_id="lookup_entity",
)
async def lookup_entity(
    md5: str | None = Query(None, description="MD5 to lookup"),
    label: str | None = Query(None, description="Label to lookup"),
    user: UserPayload | None = Depends(require_permission("media_store_read")),
    service: EntityService = Depends(get_entity_service),
) -> EntitySchema | None:
    """Lookup entity by MD5 or label."""
    _ = user

    if not md5 and not label:
        raise HTTPException(
            status_code=400,
            detail="Must provide either md5 or label parameter"
        )

    # Get first matching entity
    items, _ = service.get_entities(
        page=1,
        page_size=1,
        md5=md5,
        search_query=label if label else None,
        exclude_deleted=True,
    )

    return items[0] if items else None
```

**PySDK**:
```python
def lookup_entity(
    self,
    md5: Optional[str] = None,
    label: Optional[str] = None,
) -> Optional[Entity]:
    response = self._session.get(
        f"{self.base_url}/entities/lookup",
        params={'md5': md5, 'label': label}
    )
    return Entity.from_dict(response.json()) if response.ok else None
```

**DartSDK** (`lib/src/clients/store_client.dart`):
```dart
Future<Entity?> lookupEntity({
  String? md5,
  String? label,
}) async {
  final queryParams = <String, String>{};
  if (md5 != null) queryParams['md5'] = md5;
  if (label != null) queryParams['label'] = label;

  final response = await _client.get(
    Uri.parse('$baseUrl/entities/lookup').replace(queryParameters: queryParams),
    headers: await _getHeaders(),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data != null ? Entity.fromMap(data) : null;
  }

  return null;
}
```

**DartSDK** (`lib/src/managers/store_manager.dart`):
```dart
Future<StoreOperationResult<Entity?>> lookupEntity({
  String? md5,
  String? label,
}) async {
  try {
    final result = await storeClient.lookupEntity(
      md5: md5,
      label: label,
    );

    return StoreOperationResult(
      success: 'Entity lookup successful',
      data: result,
    );
  } catch (e) {
    return StoreOperationResult(error: e.toString());
  }
}
```

**Priority**: **MEDIUM** - Workaround exists (use listEntities with pageSize=1), but direct endpoint is cleaner

---

## Additional Nice-to-Have Features (LOW PRIORITY)

### 3. Filter by `is_deleted=true` to Show Trash

**Current**: `exclude_deleted` parameter only excludes deleted items
**Requested**: Ability to explicitly show ONLY deleted items (for trash view)

**Store Server**:
```python
@router.get("/entities")
async def get_entities(
    # Replace exclude_deleted with is_deleted filter:
    is_deleted: bool | None = Query(None, description="Filter by deleted status (null=all, true=only deleted, false=only active)"),
)
```

**Priority**: **LOW** - Can use `exclude_deleted=false` to show all, then filter client-side

### 4. Batch Entity Fetch by IDs

**Use Case**: Fetching multiple specific entities efficiently

**Requested**: `POST /entities/batch` with body `{"ids": [1, 2, 3]}`

**Priority**: **LOW** - Can use multiple `readEntity()` calls

---

## Summary Table

| Feature | Priority | Status | Workaround Available? | Blocks Migration? |
|---------|----------|--------|----------------------|-------------------|
| `parentId` filter | 🚨 CRITICAL | ❌ Missing | ⚠️ Client-side filter (performance issue) | ✅ YES |
| `isCollection` filter | 🚨 CRITICAL | ❌ Missing | ⚠️ Client-side filter (performance issue) | ✅ YES |
| Direct lookup endpoint | 📌 MEDIUM | ❌ Missing | ✅ Use listEntities(pageSize=1) | ❌ NO |
| Show deleted filter | 🔹 LOW | ❌ Missing | ✅ Use exclude_deleted=false + client filter | ❌ NO |
| Batch entity fetch | 🔹 LOW | ❌ Missing | ✅ Multiple readEntity() calls | ❌ NO |

---

## Implementation Phases

### Phase 1: Critical Features (Required for OnlineEntityStore migration)
1. Add `parent_id` filter to `GET /entities` in store server
2. Add `is_collection` filter to `GET /entities` in store server
3. Update PySDK to support new filters
4. Update DartSDK to support new filters
5. Test with UI to verify filters work correctly <-- ignore this line

**Timeline**: Must complete before OnlineEntityStore migration can proceed

### Phase 2: Nice-to-Have Features (Optional, can implement later)
1. Add `GET /entities/lookup` endpoint for direct entity lookup
2. Add `is_deleted` filter (to show trash/deleted items only)
3. Add batch entity fetch endpoint
4. Update PySDK and DartSDK accordingly

**Timeline**: Can be done in parallel with or after OnlineEntityStore migration



## Questions for Discussion

1. **Filter behavior**: Should `parent_id=null` filter show root-level items, or should we use a special value like `parent_id=0`?
Answer: use parent_id=0 as a special value to filter level items. parent_id=null means parent_id is not specified, and it should get all.

2. **Direct lookup**: Should it return first match or throw error if multiple matches found?

Being unique in DB for label and md5, I believe this will get either one or none. Hence, throwing error is a better choice if multiple matches, which is a db bug.
---


