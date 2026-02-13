# cl_server Dart SDK Migration Plan

## Executive Summary

This document provides a comprehensive analysis and migration plan for replacing the current `online_store` implementation with the `cl_server_dart_client` SDK.

**Key Findings:**
- ✅ SDK is production-ready with comprehensive features (auth, CRUD, intelligence)
- ⚠️ SDK has gaps in query filtering and media download helpers
- ✅ **Recommendation: Use SDK with adapter pattern**
- 🔄 Rewrite `online_store` module rather than patching
- 🔐 Authentication required: Need login UI and session management
- 📊 Data structure differences require careful mapping (not DB migration)

**Migration Scope:** Focus on `online_store` package only

This analysis documents:
1. Current app requirements vs SDK capabilities
2. Data structure mapping and compatibility
3. Authentication integration requirements
4. Step-by-step migration plan
5. Missing SDK features that need workarounds

## 1. Server Endpoints Used by Flutter App

### 1.1 Server Status Check
- **Endpoint:** `GET /`
- **Purpose:** Verify server is online and validate server identity
- **Expected Response:**
  ```json
  {
    "name": "colan_server",
    "collection": 1707123456789,
    "media": 1707123456789
  }
  ```
- **Used In:**
  - `online_store/lib/src/implementations/rest_api.dart:41` - `getURLStatus()`
  - `online_store/lib/src/implementations/cl_server.dart:140` - `getServerLiveStatus()`
- **Validation:** Response must contain `"name": "colan_server"`

### 1.2 Entity Query (Primary Endpoint)
- **Endpoint:** `GET /entity`
- **Purpose:** Fetch entities (media files or collections) with filtering
- **Query Parameters (all optional):**
  - `id` - Entity ID
  - `isCollection` - Boolean (true/false or 1/0)
  - `label` - Entity label/name
  - `parentId` - Parent collection ID
  - `addedDate` - Timestamp in milliseconds
  - `updatedDate` - Timestamp in milliseconds
  - `isDeleted` - Boolean
  - `CreateDate` - File creation date (timestamp)
  - `FileSize` - File size in bytes
  - `ImageHeight` - Image height in pixels
  - `ImageWidth` - Image width in pixels
  - `Duration` - Video duration in seconds
  - `MIMEType` - MIME type string
  - `md5` - File hash
  - `type` - Media type (image/video)
  - `extension` - File extension
- **Expected Response (Single Item):**
  ```json
  [
    {
      "id": 1,
      "isCollection": false,
      "label": "photo.jpg",
      "description": "My photo",
      "parentId": 0,
      "addedDate": 1707123456789,
      "updatedDate": 1707123456789,
      "isDeleted": false,
      "isHidden": false,
      "md5": "abc123...",
      "fileSize": 1024000,
      "mimeType": "image/jpeg",
      "type": "image",
      "extension": "jpg",
      "createDate": 1707123456789,
      "height": 1920,
      "width": 1080,
      "duration": null,
      "pin": null
    }
  ]
  ```
  **Note:** Returns array even for single item; code uses `.firstOrNull`

- **Expected Response (Multiple Items):**
  ```json
  {
    "items": [
      { "id": 1, "isCollection": false, ... },
      { "id": 2, "isCollection": false, ... }
    ]
  }
  ```
  **Note:** Multiple items wrapped in `{"items": [...]}`

- **Used In:**
  - `online_store/lib/src/models/entity_store.dart:16` - `getSingle()`
  - `online_store/lib/src/models/entity_store.dart:48` - `getAll()`
  - `online_store/lib/src/models/entity_store.dart:65` - `getAll()` (list query)

### 1.3 Media Info Query
- **Endpoint:** `GET /media?type={type}`
- **Purpose:** Fetch all media of specific type(s)
- **Query Parameters:**
  - `type` - Media type: `image` or `video`
- **Expected Response:**
  ```json
  [
    { "id": 1, "isCollection": false, ... },
    { "id": 2, "isCollection": false, ... }
  ]
  ```
  **Note:** Returns array of entities (CLEntity format)
- **Used In:**
  - `online_store/lib/src/implementations/cl_server.dart:183` - `downloadMediaInfo()`
- **Behavior:** Can call multiple times for different types (image, video) and merge results

### 1.4 Collection Info Query
- **Endpoint:** `GET /collection`
- **Purpose:** Fetch all collections (folders)
- **Expected Response:**
  ```json
  [
    { "id": 1, "isCollection": true, "label": "My Photos", ... },
    { "id": 2, "isCollection": true, "label": "Vacation", ... }
  ]
  ```
  **Note:** Returns array of collection entities
- **Used In:**
  - `online_store/lib/src/implementations/cl_server.dart:198` - `downloadCollectionInfo()`

### 1.5 Media File Download
- **Endpoint:** `GET /entity/{id}/download`
- **Purpose:** Download the actual media file (binary)
- **Path Parameters:**
  - `id` - Entity ID
- **Expected Response:** Binary file data
- **Used In:**
  - `online_store/lib/src/models/entity_store.dart:86` - `serverEntityDownload()`

### 1.6 Media Preview/Thumbnail
- **Endpoint:** `GET /entity/{id}/preview`
- **Purpose:** Download preview/thumbnail (binary)
- **Path Parameters:**
  - `id` - Entity ID
- **Expected Response:** Binary image data (thumbnail)
- **Used In:**
  - `online_store/lib/src/models/entity_store.dart:91` - `serverEntityPreview()`

### 1.7 Entity Create/Update
- **Endpoint:** `POST /entity` or `PUT /entity`
- **Purpose:** Create or update entity (with optional file upload)
- **Content-Type:** `multipart/form-data` (when uploading file) or `application/json`
- **Request Body (JSON):**
  ```json
  {
    "id": 1,
    "isCollection": false,
    "label": "photo.jpg",
    ... (full CLEntity fields)
  }
  ```
- **Request Body (Multipart with file):**
  - Form field: `media` - The file
  - Additional JSON fields as form data
- **Expected Response:** Success (200/201)
- **Used In:**
  - `online_store/lib/src/models/entity_store.dart:96` - `upsert()`

### 1.8 Entity Delete
- **Endpoint:** `DELETE /entity` (with query params)
- **Purpose:** Delete entity
- **Query Parameters:**
  - Entity fields to identify item (typically `id`)
- **Expected Response:** Success (200/201)
- **Used In:**
  - `online_store/lib/src/models/entity_store.dart:127` - `delete()`

## 2. Data Structure: CLEntity

### 2.1 Core Entity Model

**Location:** `store/lib/src/models/cl_entity.dart`

```dart
class CLEntity {
  final int? id;
  final bool isCollection;
  final String? label;
  final String? description;
  final int? parentId;
  final DateTime addedDate;
  final DateTime updatedDate;
  final bool isDeleted;
  final bool isHidden;

  // Media-specific fields (null for collections)
  final String? md5;           // File hash
  final int? fileSize;         // Bytes
  final String? mimeType;      // e.g., "image/jpeg"
  final String? type;          // e.g., "image", "video"
  final String? extension;     // e.g., "jpg", "mp4"
  final DateTime? createDate;  // File creation date
  final int? height;           // Image/video height
  final int? width;            // Image/video width
  final double? duration;      // Video duration in seconds
  final String? pin;           // Custom note/pin
}
```

### 2.2 JSON Serialization Format

**DateTime Fields:**
- Stored as Unix milliseconds (integer): `1707123456789`
- NOT ISO 8601 strings
- Fields: `addedDate`, `updatedDate`, `createDate`

**Boolean Fields:**
- Can be actual booleans or integers (0/1)
- Fields: `isCollection`, `isDeleted`, `isHidden`

**Example Full JSON:**
```json
{
  "id": 42,
  "isCollection": false,
  "label": "IMG_20240206_143022.jpg",
  "description": "Photo from camera",
  "parentId": 5,
  "addedDate": 1707234622000,
  "updatedDate": 1707234622000,
  "isDeleted": false,
  "isHidden": false,
  "md5": "5d41402abc4b2a76b9719d911017c592",
  "fileSize": 2048576,
  "mimeType": "image/jpeg",
  "type": "image",
  "extension": "jpg",
  "createDate": 1707234622000,
  "height": 4032,
  "width": 3024,
  "duration": null,
  "pin": null
}
```

**Example Collection JSON:**
```json
{
  "id": 5,
  "isCollection": true,
  "label": "Vacation Photos",
  "description": "Summer 2024",
  "parentId": 0,
  "addedDate": 1707234622000,
  "updatedDate": 1707234622000,
  "isDeleted": false,
  "isHidden": false,
  "md5": null,
  "fileSize": null,
  "mimeType": null,
  "type": null,
  "extension": null,
  "createDate": null,
  "height": null,
  "width": null,
  "duration": null,
  "pin": null
}
```

## 3. File Locations: Where Server Communication Happens

### 3.1 HTTP Client Layer

**File:** `online_store/lib/src/implementations/rest_api.dart`
- **Lines:** Entire file (core HTTP wrapper)
- **Purpose:** Low-level HTTP client wrapping `http.Client`
- **Methods:**
  - `getURLStatus(storeURL)` - GET / endpoint
  - `get(endPoint)` - GET requests
  - `post(endPoint, json, form, fileName)` - POST with multipart
  - `put(endPoint, json, form, fileName)` - PUT with multipart
  - `delete(endPoint)` - DELETE requests
  - `download(endPoint, filePath)` - Binary downloads

### 3.2 Server Connection Layer

**File:** `online_store/lib/src/implementations/cl_server.dart`
- **Lines:** Entire file
- **Purpose:** Manages connection to a server, constructs endpoints
- **Key Methods:**
  - `getServerLiveStatus()` - Line 140 - Status check
  - `downloadMediaInfo()` - Line 183 - /media?type= endpoint
  - `downloadCollectionInfo()` - Line 198 - /collection endpoint
  - `getEndpoint()` - Delegates to RestApi
  - `post()`, `put()`, `delete()` - Delegates to RestApi

### 3.3 Server Status Monitoring

**File:** `online_store/lib/src/implementations/cl_server_status.dart`
- **Lines:** Entire file
- **Purpose:** Manages server timestamps for sync
- **Data Structure:**
  ```dart
  class ServerTimeStamps {
    final DateTime? collection;  // Last collection update
    final DateTime? media;       // Last media update
  }
  ```

### 3.4 Entity Store Implementation (Online)

**File:** `online_store/lib/src/models/entity_store.dart`
- **Lines:** Entire file
- **Purpose:** Repository pattern implementation for online backend
- **Key Methods:**
  - `getSingle()` - Line 16 - Single entity query
  - `getAll()` - Lines 48, 65 - List entity queries
  - `serverEntityDownload()` - Line 86 - Download endpoint
  - `serverEntityPreview()` - Line 91 - Preview endpoint
  - `upsert()` - Line 96 - POST/PUT entity
  - `delete()` - Line 127 - DELETE entity

### 3.5 Query Builder

**File:** `online_store/lib/src/models/server_query.dart`
- **Lines:** Entire file
- **Purpose:** Converts StoreQuery to HTTP query string
- **Example:** `StoreQuery({"parentId": 0})` → `/entity?parentId=0`

### 3.6 Base Store Interface

**File:** `store/lib/src/models/entity_store.dart`
- **Lines:** Interface definitions
- **Purpose:** Abstract interface that OnlineEntityStore implements
- **Methods:** `getSingle()`, `getAll()`, `upsert()`, `delete()`

### 3.7 Store Provider (Riverpod)

**File:** `content_store/lib/src/stores/providers/store_provider.dart`
- **Purpose:** Creates store instances based on URL scheme
- **Routing Logic:**
  - `local://` → LocalSQLiteEntityStore
  - `http://` or `https://` → OnlineEntityStore + CLServer

### 3.8 Network Discovery

**File:** `content_store/lib/src/stores/providers/network_scanner.dart`
- **Purpose:** Auto-discovers servers on local network via mDNS
- **Service Type:** `_http._tcp`
- **Identifier:** Looks for services ending with `cloudonlapapps`

### 3.9 Server Health Monitor

**File:** `content_store/lib/src/stores/providers/server_provider.dart`
- **Purpose:** Periodic health checks every 5 seconds
- **Uses:** `CLServer.getServerLiveStatus()`

## 4. Requirements for cl_server Compatibility

### 4.1 Must-Have Endpoints

1. ✅ `GET /` - Status with `{"name": "colan_server", "collection": ms, "media": ms}`
2. ✅ `GET /entity` - Query with all supported parameters
3. ✅ `GET /media?type={type}` - Media list by type
4. ✅ `GET /collection` - Collection list
5. ✅ `GET /entity/{id}/download` - Binary file download
6. ✅ `GET /entity/{id}/preview` - Thumbnail download
7. ✅ `POST /entity` - Create/update with multipart support
8. ✅ `PUT /entity` - Update with multipart support
9. ✅ `DELETE /entity` - Delete with query params

### 4.2 Response Format Requirements

**Critical:**
- Single entity queries return `[{...}]` (array, not object)
- Multi-entity queries return `{"items": [{...}]}` (wrapped in items key)
- Media/collection info returns `[{...}]` (array)
- Timestamps as Unix milliseconds (integer), NOT ISO strings
- Boolean fields work as true/false or 1/0

### 4.3 Data Model Compatibility

**Required Fields in Entity Response:**
- `id` (integer, nullable)
- `isCollection` (boolean)
- `label` (string, nullable)
- `description` (string, nullable)
- `parentId` (integer, nullable)
- `addedDate` (Unix ms timestamp)
- `updatedDate` (Unix ms timestamp)
- `isDeleted` (boolean)
- `isHidden` (boolean)

**Media-Specific Fields (if isCollection=false):**
- `md5` (string)
- `fileSize` (integer bytes)
- `mimeType` (string)
- `type` (string: "image" or "video")
- `extension` (string)
- `createDate` (Unix ms timestamp)
- `height`, `width` (integers)
- `duration` (double, for videos)

### 4.4 HTTP Requirements

**Headers:**
- Accept `Authorization: Bearer {token}` header
- Support `Content-Type: application/json`
- Support `Content-Type: multipart/form-data`
- File upload field name: `media`

**Status Codes:**
- Success: 200 or 201
- Errors: Non-200/201 with error details in body

### 4.5 Query Parameter Support

All query parameters are optional, and the server should support filtering by:
- Exact match (e.g., `id=5`)
- Boolean values (e.g., `isCollection=true` or `isCollection=1`)
- Combined filters (e.g., `parentId=0&isDeleted=false`)

## 5. Migration Strategy Recommendations

### 5.1 Files That Need Modification

**If cl_server has different endpoint structure:**
1. `online_store/lib/src/implementations/cl_server.dart` - Update endpoint paths
2. `online_store/lib/src/models/entity_store.dart` - Adjust response parsing if needed

**If cl_server has different data structure:**
1. `store/lib/src/models/cl_entity.dart` - Add mapping/adapter methods
2. `online_store/lib/src/models/entity_store.dart` - Transform responses

**If cl_server has different authentication:**
1. `online_store/lib/src/implementations/rest_api.dart` - Update auth headers
2. Add token management if needed

### 5.2 Recommended Approach: Adapter Pattern

Create an adapter layer that maps cl_server responses to expected CLEntity format:

```dart
class CLServerAdapter {
  static CLEntity fromCLServerResponse(Map<String, dynamic> response) {
    // Transform cl_server format → CLEntity format
  }

  static Map<String, dynamic> toCLServerRequest(CLEntity entity) {
    // Transform CLEntity → cl_server format
  }
}
```

**Modify only:** `online_store/lib/src/models/entity_store.dart`
- Add adapter calls in `getSingle()`, `getAll()`, `upsert()`

### 5.3 Testing Requirements

**After integration, verify:**
1. Server discovery works (mDNS broadcasts `_http._tcp` with `cloudonlapapps`)
2. Status check returns correct format
3. Entity queries return proper format (single vs. multiple)
4. File upload/download works
5. Preview generation works
6. DateTime fields parse correctly (Unix ms)
7. Boolean fields work with both 0/1 and true/false

## 6. Potential Compatibility Issues

### 6.1 Response Format Differences
- **Issue:** cl_server might return different wrapper format
- **Impact:** HIGH - Parsing will fail
- **Files Affected:** `online_store/lib/src/models/entity_store.dart`

### 6.2 Timestamp Format
- **Issue:** cl_server might use ISO 8601 strings instead of Unix ms
- **Impact:** MEDIUM - Date parsing will break
- **Files Affected:** `store/lib/src/models/cl_entity.dart`

### 6.3 Endpoint Path Structure
- **Issue:** cl_server might use different paths (e.g., `/api/entity` instead of `/entity`)
- **Impact:** LOW - Easy to change
- **Files Affected:** `online_store/lib/src/implementations/cl_server.dart`

### 6.4 File Upload Field Name
- **Issue:** cl_server might expect different field name (not `media`)
- **Impact:** LOW - Easy to change
- **Files Affected:** `online_store/lib/src/implementations/rest_api.dart` line 96

### 6.5 Server Identity Check
- **Issue:** Status endpoint must return `"name": "colan_server"`
- **Impact:** MEDIUM - Hardcoded validation
- **Files Affected:** `online_store/lib/src/implementations/cl_server.dart` line 152

### 6.6 Query Parameter Naming
- **Issue:** cl_server might use different parameter names (e.g., `parent_id` vs `parentId`)
- **Impact:** MEDIUM - Query builder needs adjustment
- **Files Affected:** `online_store/lib/src/models/server_query.dart`

## 7. Next Steps

### Phase 2 Preparation:
1. Analyze cl_server's actual API documentation
2. Map differences between expected format (this doc) and cl_server format
3. Decide: Adapter layer vs. Direct modification
4. Create migration checklist with specific code changes
5. Plan testing strategy

### Critical Questions to Answer:
- What does cl_server's `/` endpoint return?
- What format does cl_server use for entity queries?
- How does cl_server handle timestamps?
- What's the file upload structure?
- What authentication does cl_server require?

## 8. Verification Checklist

After migration, test these workflows:
- [ ] App discovers server on network
- [ ] App connects to server successfully
- [ ] Browse root collection (parentId=0)
- [ ] Open a collection (view children)
- [ ] View media file
- [ ] Download media file works
- [ ] Preview/thumbnail loads
- [ ] Upload new media file
- [ ] Create new collection
- [ ] Update entity metadata
- [ ] Delete entity
- [ ] Search/filter entities
- [ ] Server status monitoring works

---

# PART 2: Dart SDK Analysis & Migration Strategy

## 9. Dart SDK Overview

**Location:** `/Users/anandasarangaram/Work/cl_server/sdks/dartsdk`
**Package:** `cl_server_dart_client` v0.1.0

### 9.1 SDK Architecture

The SDK provides three service clients:

1. **AuthClient** - User authentication and management
   - Login with username/password
   - Token refresh (JWT with auto-refresh)
   - User CRUD operations (admin)
   - Public key retrieval for token verification

2. **StoreClient** - Media entity storage (**Primary focus for online_store**)
   - Entity CRUD operations with pagination
   - Version history tracking
   - Intelligence data (faces, embeddings)
   - Known persons management
   - System audit and cleanup

3. **ComputeClient** - Async job processing (9 plugins)
   - Face detection, embeddings, thumbnails
   - MQTT real-time updates
   - Worker management

### 9.2 High-Level Managers

- **SessionManager** - Centralized auth lifecycle with auto token refresh
- **StoreManager** - High-level wrapper around StoreClient with error handling

### 9.3 SDK Data Model: `Entity`

```dart
class Entity {
  int id;                              // Non-null (vs CLEntity's int?)
  bool? isCollection;
  String? label;
  String? description;
  int? parentId;
  int? addedDate;                      // Unix ms (vs CLEntity's DateTime)
  int? updatedDate;                    // Unix ms
  int? createDate;                     // Unix ms
  String? addedBy;                     // ❌ Not in CLEntity
  String? updatedBy;                   // ❌ Not in CLEntity
  bool? isDeleted;
  int? fileSize;
  int? height;                         // (vs CLEntity's height)
  int? width;                          // (vs CLEntity's width)
  double? duration;
  String? mimeType;
  String? type;
  String? extension;
  String? md5;
  String? filePath;                    // ❌ Not in CLEntity
  bool? isIndirectlyDeleted;           // ❌ Not in CLEntity
  EntityIntelligenceData? intelligenceData; // ❌ Not in CLEntity
}
```

**Missing from SDK Entity:**
- ❌ `isHidden` (local-only field)
- ❌ `pin` (local-only field)

**Extra in SDK Entity:**
- ➕ `addedBy`, `updatedBy` (audit fields)
- ➕ `filePath` (server file path)
- ➕ `isIndirectlyDeleted` (cascading delete)
- ➕ `intelligenceData` (AI features)

## 10. Capability Comparison Matrix

| Feature | Current online_store | Dart SDK | Match | Notes |
|---------|---------------------|----------|-------|-------|
| **Read Single Entity** | ✅ `getSingle()` | ✅ `readEntity()` | ✅ | SDK supports version param |
| **List Entities** | ✅ `getAll()` with field filters | ⚠️ `listEntities()` pagination only | ❌ | **GAP: No parentId/type filtering** |
| **Create Entity** | ⚠️ Not implemented | ✅ `createEntity()` | ✅ | SDK ready |
| **Update Entity** | ⚠️ Not implemented | ✅ `updateEntity()` + `patchEntity()` | ✅ | SDK has full/partial update |
| **Delete Entity** | ⚠️ Not implemented | ✅ `deleteEntity()` | ✅ | SDK ready |
| **File Upload** | ✅ Via 'media' field | ✅ Via 'image' field | ⚠️ | **Field name mismatch** |
| **File Download** | ✅ `download()` helper | ❌ No helper method | ❌ | **GAP: Must construct URL manually** |
| **Media URI** | ✅ `mediaUri()` | ❌ No helper | ❌ | **GAP: Need adapter** |
| **Preview URI** | ✅ `previewUri()` | ❌ No helper | ❌ | **GAP: Need adapter** |
| **Query Filtering** | ✅ Field-level (parentId, type, etc.) | ❌ Search string only | ❌ | **CRITICAL GAP** |
| **Authentication** | ⚠️ Basic Bearer | ✅ JWT with auto-refresh | ➕ | SDK more advanced |
| **Session Management** | ❌ None | ✅ SessionManager | ➕ | SDK has full lifecycle |
| **Error Handling** | ⚠️ Generic Exception | ✅ Typed exceptions | ➕ | SDK better structured |
| **Intelligence/AI** | ❌ Not used | ✅ Full support | ➕ | Future feature ready |

**Legend:**
- ✅ Fully supported
- ⚠️ Partial/basic support
- ❌ Not supported
- ➕ Extra capability

## 11. Critical Gaps in SDK

### 11.1 Query Filtering (HIGH Priority)

**Problem:** `StoreClient.listEntities()` only supports:
```dart
listEntities({
  int page = 1,
  int pageSize = 20,
  String? searchQuery,    // Text search
  int? version,
  bool excludeDeleted,
})
```

**What's Missing:**
- No `parentId` filtering (can't browse collections)
- No `type` filtering (can't filter image/video)
- No `mimeType`, `extension` filtering
- No custom field filters

**Impact:** Cannot implement core app functionality (browse folders, filter media types)

**Workaround Options:**
1. **Client-side filtering** - Fetch all, filter locally (inefficient)
2. **Extend SDK** - Add query parameters to `listEntities()`
3. **Bypass SDK** - Direct HTTP calls for queries (defeats purpose)

**Recommendation:** Extend SDK or create adapter with direct HTTP calls for queries

### 11.2 Media Download Helpers (MEDIUM Priority)

**Problem:** SDK has no methods for:
```dart
downloadEntity(int id) → List<int>     // Media file download
downloadPreview(int id) → List<int>    // Thumbnail download
```

**Current SDK only provides:**
```dart
downloadEntityClipEmbedding()   // AI embeddings
downloadEntityDinoEmbedding()   // AI embeddings
downloadFaceEmbedding()         // AI embeddings
```

**Impact:** Must manually construct URLs for media/preview

**Workaround:**
```dart
// Adapter methods needed
Uri mediaUri(int id) => Uri.parse('${storeClient.baseUrl}/entities/$id/download');
Uri previewUri(int id) => Uri.parse('${storeClient.baseUrl}/entities/$id/preview');
```

### 11.3 Local-Only Fields (LOW Priority)

**Problem:** SDK Entity doesn't support:
- `isHidden` (app-specific visibility flag)
- `pin` (app-specific notes)

**Impact:** Need separate local storage for these fields

**Workaround:**
```dart
class LocalEntityExtensions {
  Map<int, bool> _hiddenMap = {};     // entityId → isHidden
  Map<int, String> _pinMap = {};      // entityId → pin
}
```

### 11.4 Response Format Differences

**Current Expectations:**
```json
// Single entity
[{"id": 1, ...}]

// Multiple entities
{"items": [{"id": 1, ...}, {"id": 2, ...}]}
```

**SDK Returns:**
```dart
Entity                    // Single entity (not in array)
EntityListResponse {      // Multiple entities
  items: List<Entity>,
  pagination: EntityPagination
}
```

**Impact:** MEDIUM - Different parsing logic needed

## 12. Data Structure Migration Analysis

### 12.1 Field Mapping: SDK Entity ↔ CLEntity

| SDK Field | CLEntity Field | Transformation | Direction |
|-----------|----------------|----------------|-----------|
| `id` | `id` | Direct (int to int?) | Both |
| `isCollection` | `isCollection` | Direct | Both |
| `label` | `label` | Direct | Both |
| `description` | `description` | Direct | Both |
| `parentId` | `parentId` | Direct | Both |
| `addedDate` (int ms) | `addedDate` (DateTime) | DateTime.fromMillis / .millisSinceEpoch | Both |
| `updatedDate` (int ms) | `updatedDate` (DateTime) | DateTime.fromMillis / .millisSinceEpoch | Both |
| `createDate` (int ms) | `createDate` (DateTime) | DateTime.fromMillis / .millisSinceEpoch | Both |
| `isDeleted` | `isDeleted` | Direct | Both |
| `fileSize` | `fileSize` | Direct | Both |
| `height` | `height` | Direct | Both |
| `width` | `width` | Direct | Both |
| `duration` | `duration` | Direct | Both |
| `mimeType` | `mimeType` | Direct | Both |
| `type` | `type` | Direct | Both |
| `extension` | `extension` | Direct | Both |
| `md5` | `md5` | Direct | Both |
| `addedBy` | ❌ | Ignore | SDK → App |
| `updatedBy` | ❌ | Ignore | SDK → App |
| `filePath` | ❌ | Ignore | SDK → App |
| `isIndirectlyDeleted` | ❌ | Ignore | SDK → App |
| `intelligenceData` | ❌ | Ignore (for now) | SDK → App |
| ❌ | `isHidden` | Local storage | App only |
| ❌ | `pin` | Local storage | App only |

### 12.2 Database Migration Requirements

**Question:** Do we need to migrate local database?

**Answer:** **NO DATABASE MIGRATION NEEDED**

**Reasoning:**
1. `online_store` talks to remote server, not local DB
2. Local DB (`local_store` package) uses `CLEntity` and won't change
3. SDK is only used for remote communication
4. Adapter converts SDK Entity ↔ CLEntity at boundary

**Architecture:**
```
App (CLEntity)
  ↕ [Adapter]
SDK (Entity)
  ↕ [HTTP]
Remote Server
```

Local SQLite DB continues using `CLEntity` unchanged.

### 12.3 Adapter Implementation Strategy

Create `EntityAdapter` class:

```dart
class EntityAdapter {
  // SDK → App
  static CLEntity fromSdkEntity(Entity sdkEntity) {
    return CLEntity(
      id: sdkEntity.id,
      isCollection: sdkEntity.isCollection ?? false,
      label: sdkEntity.label,
      description: sdkEntity.description,
      parentId: sdkEntity.parentId,
      addedDate: sdkEntity.addedDate != null
        ? DateTime.fromMillisecondsSinceEpoch(sdkEntity.addedDate!)
        : DateTime.now(),
      updatedDate: sdkEntity.updatedDate != null
        ? DateTime.fromMillisecondsSinceEpoch(sdkEntity.updatedDate!)
        : DateTime.now(),
      isDeleted: sdkEntity.isDeleted ?? false,
      md5: sdkEntity.md5,
      fileSize: sdkEntity.fileSize,
      mimeType: sdkEntity.mimeType,
      type: sdkEntity.type,
      extension: sdkEntity.extension,
      createDate: sdkEntity.createDate != null
        ? DateTime.fromMillisecondsSinceEpoch(sdkEntity.createDate!)
        : null,
      height: sdkEntity.height,
      width: sdkEntity.width,
      duration: sdkEntity.duration,
      // Local-only fields handled separately
      isHidden: false,  // Default, override from local storage
      pin: null,        // Default, override from local storage
    );
  }

  // App → SDK (for create/update)
  static Map<String, dynamic> toSdkEntityMap(CLEntity entity) {
    return {
      if (entity.id != null) 'id': entity.id,
      'isCollection': entity.isCollection,
      if (entity.label != null) 'label': entity.label,
      if (entity.description != null) 'description': entity.description,
      if (entity.parentId != null) 'parentId': entity.parentId,
      'addedDate': entity.addedDate.millisecondsSinceEpoch,
      'updatedDate': entity.updatedDate.millisecondsSinceEpoch,
      'isDeleted': entity.isDeleted,
      if (entity.md5 != null) 'md5': entity.md5,
      if (entity.fileSize != null) 'fileSize': entity.fileSize,
      if (entity.mimeType != null) 'mimeType': entity.mimeType,
      if (entity.type != null) 'type': entity.type,
      if (entity.extension != null) 'extension': entity.extension,
      if (entity.createDate != null)
        'createDate': entity.createDate!.millisecondsSinceEpoch,
      if (entity.height != null) 'height': entity.height,
      if (entity.width != null) 'width': entity.width,
      if (entity.duration != null) 'duration': entity.duration,
      // Note: isHidden and pin are local-only, not sent to server
    };
  }
}
```

## 13. Authentication Integration

### 13.1 Current State (No Auth)

**Current Implementation:**
- Optional Bearer token passed manually
- No login UI
- No session management
- No token storage

### 13.2 New Requirement (JWT Auth)

**SDK Provides:**
- `SessionManager` with login/logout
- `JWTAuthProvider` with auto token refresh
- Token expiry detection
- User management APIs

**What We Need to Build:**

1. **Login Screen**
   ```dart
   // New widget: login_page.dart
   LoginPage({
     required String serverUrl,
     required Function(SessionManager) onLoginSuccess,
   })
   ```

2. **Session State Management**
   ```dart
   // Riverpod provider
   final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
     return SessionNotifier();
   });

   class SessionState {
     SessionManager? session;
     UserResponse? currentUser;
     bool isLoggedIn;
   }
   ```

3. **Token Storage**
   ```dart
   // Use SharedPreferences or FlutterSecureStorage
   class TokenStorage {
     Future<void> saveToken(String accessToken);
     Future<String?> loadToken();
     Future<void> clearToken();
   }
   ```

4. **UI Flow Changes**
   ```
   App Start
     ↓
   Load saved token?
     ├─ Yes → Try auto-login
     │         ├─ Success → Main app
     │         └─ Fail → Login screen
     └─ No → Login screen
            ↓
          Enter credentials
            ↓
          SessionManager.login()
            ↓
          Save token
            ↓
          Main app
   ```

### 13.3 Guest Mode Consideration

**SDK supports `NoAuthProvider`** for guest mode.

**Question:** Should we support guest mode?

**Options:**
1. **Auth-only mode** - Always require login (simplest)
2. **Guest + Auth mode** - Allow anonymous browsing, login for uploads
3. **Server-configured** - Let server decide via `StorePref.guestMode`

**Recommendation:** Start with **auth-only**, add guest mode later if needed.

### 13.4 Authentication Implementation Files

**New Files to Create:**
- `online_store/lib/src/auth/session_manager_wrapper.dart` - Wrapper around SDK SessionManager
- `online_store/lib/src/auth/token_storage.dart` - Token persistence
- `keep_it/lib/pages/login_page.dart` - Login UI
- `content_store/lib/src/stores/providers/session_provider.dart` - Riverpod provider

**Files to Modify:**
- `content_store/lib/src/stores/providers/store_provider.dart` - Inject auth
- `online_store/lib/src/models/entity_store.dart` - Use authenticated StoreManager

## 14. Migration Decision: Update vs Rewrite

### 14.1 Patching Current Implementation

**Pros:**
- Less code churn
- Incremental migration
- Lower risk

**Cons:**
- Mixing old patterns with new SDK
- Technical debt accumulates
- Harder to maintain
- Won't benefit from SDK architecture

### 14.2 Rewriting with SDK (RECOMMENDED)

**Pros:**
- ✅ Clean architecture
- ✅ Proper error handling
- ✅ Type safety
- ✅ Future-proof (intelligence features ready)
- ✅ Well-tested code
- ✅ Maintains interface compatibility

**Cons:**
- More upfront work
- Requires careful testing

**Decision:** **REWRITE** the `online_store` package using SDK

**Rationale:**
- Keep `EntityStore` interface unchanged
- Replace implementation internals with SDK
- Better long-term maintainability
- SDK is production-ready
- Clean separation of concerns

## 15. Migration Plan

### Phase 1: Preparation (Foundation)

**Goal:** Set up SDK integration without breaking existing functionality

**Tasks:**
1. **Add SDK dependency** to `online_store/pubspec.yaml`
   ```yaml
   dependencies:
     cl_server_dart_client:
       path: ../../../../sdks/dartsdk
   ```

2. **Create adapter layer**
   - New file: `online_store/lib/src/adapters/entity_adapter.dart`
   - Implement `EntityAdapter.fromSdkEntity()`
   - Implement `EntityAdapter.toSdkEntityMap()`

3. **Create local extensions storage**
   - New file: `online_store/lib/src/adapters/local_entity_extensions.dart`
   - Store `isHidden` and `pin` fields locally
   - Use SharedPreferences or in-memory Map

4. **Create SDK wrapper**
   - New file: `online_store/lib/src/implementations/sdk_store_client.dart`
   - Wrap `StoreManager` with helper methods
   - Add `downloadEntity()`, `downloadPreview()` methods
   - Add `mediaUri()`, `previewUri()` helper methods

### Phase 2: Authentication (New Feature)

**Goal:** Add login capability

**Tasks:**
1. **Token storage**
   - New file: `online_store/lib/src/auth/token_storage.dart`
   - Use `flutter_secure_storage` for tokens

2. **Session management**
   - New file: `online_store/lib/src/auth/session_wrapper.dart`
   - Wrap SDK's `SessionManager`
   - Handle login/logout/refresh

3. **Riverpod provider**
   - New file: `content_store/lib/src/stores/providers/session_provider.dart`
   - Manage session state across app

4. **Login UI**
   - New file: `keep_it/lib/pages/login_page.dart`
   - Username/password form
   - Server URL configuration
   - Remember credentials option

5. **App flow integration**
   - Modify: `keep_it/lib/main.dart`
   - Check for saved token on startup
   - Show login screen if no valid session

### Phase 3: Core Implementation (Rewrite)

**Goal:** Replace current implementation with SDK-based version

**Tasks:**
1. **Backup current implementation**
   - Rename: `entity_store.dart` → `entity_store_legacy.dart`

2. **Create new SDK-based EntityStore**
   - New file: `online_store/lib/src/models/entity_store_sdk.dart`
   - Implement `EntityStore` interface
   - Use `StoreManager` internally
   - Apply `EntityAdapter` for conversions

3. **Implement core methods**
   ```dart
   class SdkEntityStore implements EntityStore {
     final StoreManager _storeManager;
     final LocalEntityExtensions _localExtensions;

     @override
     Future<CLEntity?> getSingle(StoreQuery<CLEntity>? query) async {
       // Extract ID from query
       // Call storeManager.readEntity(id)
       // Convert via EntityAdapter
       // Merge local extensions
     }

     @override
     Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
       // Parse query for filters
       // Workaround: If has parentId/type filters
       //   → Use direct HTTP call with query params
       // Otherwise: Use storeManager.listEntities()
       // Convert via EntityAdapter
       // Apply local filtering (isHidden)
       // Merge local extensions
     }

     @override
     Future<CLEntity?> upsert(CLEntity entity) async {
       // Convert via EntityAdapter.toSdkEntityMap()
       // Determine create vs update (has ID?)
       // Call storeManager.createEntity() or updateEntity()
       // Store local extensions separately
       // Return updated entity
     }

     @override
     Future<void> delete(StoreQuery<CLEntity> query) async {
       // Extract ID from query
       // Call storeManager.deleteEntity(id)
       // Clean up local extensions
     }
   }
   ```

4. **Implement media helpers**
   ```dart
   @override
   Uri? mediaUri(CLEntity entity) {
     return Uri.parse('${_storeManager.storeClient.baseUrl}/entities/${entity.id}/download');
   }

   @override
   Uri? previewUri(CLEntity entity) {
     return Uri.parse('${_storeManager.storeClient.baseUrl}/entities/${entity.id}/preview');
   }
   ```

5. **Handle query filtering workaround**
   ```dart
   // For queries with parentId, type, etc.
   Future<List<CLEntity>> _queryWithFilters(StoreQuery query) async {
     // Option A: Client-side filtering
     final all = await _storeManager.listEntities(pageSize: 1000);
     return all.items
       .where((e) => matchesQuery(e, query))
       .map((e) => EntityAdapter.fromSdkEntity(e))
       .toList();

     // Option B: Direct HTTP call (bypass SDK)
     final serverQuery = ServerQuery.fromStoreQuery('/entities', query);
     final response = await _storeManager.storeClient.get(serverQuery.requestTarget);
     // Parse and convert
   }
   ```

### Phase 4: Server Integration

**Goal:** Update server connection logic

**Tasks:**
1. **Modify CLServer**
   - File: `online_store/lib/src/implementations/cl_server.dart`
   - Replace RestApi usage with StoreManager
   - Update `getServerLiveStatus()` to use SDK health check
   - Remove `downloadMediaInfo()` and `downloadCollectionInfo()` (use StoreManager instead)

2. **Update store provider**
   - File: `content_store/lib/src/stores/providers/store_provider.dart`
   - Create `SessionManager` from stored token
   - Create `StoreManager` from SessionManager
   - Pass to `SdkEntityStore`

3. **Handle server discovery**
   - Keep existing mDNS discovery unchanged
   - When server found, prompt for login if not authenticated

### Phase 5: Testing & Migration

**Goal:** Verify everything works

**Tasks:**
1. **Unit tests**
   - Test `EntityAdapter` conversions
   - Test `LocalEntityExtensions` storage
   - Test `SdkEntityStore` methods

2. **Integration testing**
   - Test login flow
   - Test entity CRUD operations
   - Test file upload/download
   - Test querying and filtering
   - Test local field persistence

3. **Manual testing** (per checklist in Section 8)

4. **Cleanup**
   - Remove legacy files (`rest_api.dart`, `entity_store_legacy.dart`)
   - Remove `ServerQuery` if not used
   - Update exports in `online_store/lib/online_store.dart`

### Phase 6: Enhancement (Future)

**Goal:** Leverage SDK features

**Tasks:**
1. **Intelligence features**
   - Face detection UI
   - Semantic search via embeddings
   - Person tagging

2. **MQTT real-time updates**
   - Live entity status updates
   - Progress indicators for uploads

3. **Version history**
   - Show entity version timeline
   - Restore previous versions

## 16. File Structure After Migration

```
online_store/
├── lib/
│   ├── src/
│   │   ├── adapters/
│   │   │   ├── entity_adapter.dart            [NEW]
│   │   │   └── local_entity_extensions.dart   [NEW]
│   │   ├── auth/
│   │   │   ├── session_wrapper.dart           [NEW]
│   │   │   └── token_storage.dart             [NEW]
│   │   ├── implementations/
│   │   │   ├── cl_server.dart                 [MODIFIED - Use SDK]
│   │   │   ├── rest_api.dart                  [DELETE - Replaced by SDK]
│   │   │   └── sdk_store_client.dart          [NEW - SDK wrapper]
│   │   └── models/
│   │       ├── entity_store.dart              [KEEP - Interface unchanged]
│   │       ├── entity_store_sdk.dart          [NEW - SDK implementation]
│   │       └── server_query.dart              [MAYBE DELETE - If not needed]
│   └── online_store.dart                      [MODIFIED - Update exports]
└── pubspec.yaml                               [MODIFIED - Add SDK dependency]

content_store/
└── lib/src/stores/providers/
    ├── session_provider.dart                  [NEW]
    └── store_provider.dart                    [MODIFIED - Use SessionManager]

keep_it/
├── lib/
│   ├── main.dart                              [MODIFIED - Auth flow]
│   └── pages/
│       └── login_page.dart                    [NEW]
└── pubspec.yaml                               [MODIFIED - Add flutter_secure_storage]
```

## 17. What's Missing in SDK (Gaps Document)

### 17.1 Critical Missing Features

**1. Field-Level Query Filtering**

**Status:** ❌ Not Implemented

**Description:** SDK's `listEntities()` only supports text search and pagination. Cannot filter by:
- `parentId` (browse folders)
- `type` (filter by image/video)
- `mimeType` (filter by format)
- `isCollection` (separate files/folders)
- Custom field filters

**Current SDK API:**
```dart
listEntities({
  int page = 1,
  int pageSize = 20,
  String? searchQuery,
  int? version,
  bool excludeDeleted,
})
```

**Needed API:**
```dart
listEntities({
  int page = 1,
  int pageSize = 20,
  String? searchQuery,
  int? version,
  bool excludeDeleted,

  // NEW: Field filters
  int? parentId,
  String? type,
  String? mimeType,
  bool? isCollection,
  Map<String, dynamic>? customFilters,  // Generic key-value filters
})
```

**Impact:** **HIGH** - Core app functionality requires this

**Workaround:**
- Option A: Fetch all entities and filter client-side (inefficient)
- Option B: Direct HTTP calls bypassing SDK (defeats purpose)
- Option C: Extend SDK locally (requires maintaining fork)

**Recommendation:** **Contribute enhancement to SDK** or **extend SDK wrapper**

---

**2. Media File Download Helpers**

**Status:** ❌ Not Implemented

**Description:** SDK has no convenience methods for downloading media files or thumbnails.

**Current SDK:** Only provides AI embedding downloads
```dart
downloadEntityClipEmbedding(entityId) → List<int>
downloadEntityDinoEmbedding(entityId) → List<int>
downloadFaceEmbedding(faceId) → List<int>
```

**Needed Methods:**
```dart
class StoreClient {
  Future<List<int>> downloadEntityMedia(int entityId);
  Future<List<int>> downloadEntityPreview(int entityId);

  // Or convenience URLs
  Uri getMediaUrl(int entityId);
  Uri getPreviewUrl(int entityId);
}
```

**Impact:** **MEDIUM** - Must manually construct URLs

**Workaround:**
```dart
// Adapter must implement
Uri mediaUri(int id) => Uri.parse('$baseUrl/entities/$id/download');
Uri previewUri(int id) => Uri.parse('$baseUrl/entities/$id/preview');
```

**Recommendation:** **Add to SDK wrapper** in migration

---

### 17.2 Minor Missing Features

**3. Legacy Endpoint Compatibility**

**Status:** ⚠️ Partial

**Description:** SDK uses `/entities` REST API. Legacy app expects:
- `GET /media?type=image` - List all images
- `GET /collection` - List all collections

**Impact:** **LOW** - Can use `listEntities()` with filters (if filter feature added)

**Workaround:** Use `listEntities()` and filter by `isCollection` and `type`

---

**4. Response Format Normalization**

**Status:** ⚠️ Different Format

**Description:** SDK returns `EntityListResponse` with pagination metadata. Legacy expects:
```json
{"items": [...]   // Plain wrapper
```

**Impact:** **LOW** - Adapter handles conversion

**Workaround:** `EntityAdapter` extracts `items` from `EntityListResponse`

---

**5. File Upload Field Name**

**Status:** ⚠️ Mismatch

**Description:**
- SDK uses field name: `image`
- Legacy expects: `media`

**Impact:** **LOW** - Backend must accept both or SDK must change

**Workaround:**
- Check backend API spec
- If backend only accepts `media`, modify SDK wrapper

---

### 17.3 Summary Table

| Feature | Status | Priority | Workaround Complexity | Recommendation |
|---------|--------|----------|----------------------|----------------|
| Field-level query filtering | ❌ Missing | **HIGH** | High | Extend SDK |
| Media download helpers | ❌ Missing | **MEDIUM** | Low | Add to wrapper |
| Legacy endpoints | ⚠️ Partial | **LOW** | None | Use SDK methods |
| Response format | ⚠️ Different | **LOW** | Low | Adapter handles |
| Upload field name | ⚠️ Mismatch | **LOW** | Low | Check backend |
| Local fields support | ❌ Missing | **LOW** | Medium | Separate storage |

---

## 18. Migration Effort Estimate

| Phase | Complexity | Files Changed/Added | Risk | Notes |
|-------|------------|---------------------|------|-------|
| **Phase 1: Preparation** | Medium | 4 new files | Low | Foundation work |
| **Phase 2: Authentication** | High | 5 new, 2 modified | Medium | New feature |
| **Phase 3: Core Implementation** | High | 1 new, 1 modified | High | Core rewrite |
| **Phase 4: Server Integration** | Medium | 2 modified | Medium | SDK integration |
| **Phase 5: Testing** | Medium | Test files | Low | Validation |
| **Phase 6: Enhancement** | Low | Optional | Low | Future work |

**Total Files:** ~12 new files, ~5 modified files

---

## 19. Final Recommendations

### ✅ DO:
1. **Use the Dart SDK** - It's production-ready and well-architected
2. **Rewrite online_store** - Don't patch, start clean with SDK
3. **Keep interface unchanged** - `EntityStore` interface stays the same
4. **Build adapter layer** - Bridge SDK ↔ CLEntity cleanly
5. **Add authentication UI** - Required for new server
6. **Extend SDK wrapper** - Add missing download/query helpers
7. **Store local fields separately** - `isHidden`, `pin` in local storage
8. **Contribute back to SDK** - If you extend it, submit PRs

### ❌ DON'T:
1. **Don't migrate local DB** - Not needed, different layer
2. **Don't patch current code** - Rewrite is cleaner long-term
3. **Don't bypass SDK** - Use it properly or extend it
4. **Don't mix authentication** - Use SDK's SessionManager fully
5. **Don't skip testing** - Critical for CRUD operations

### 🎯 Success Criteria:
- [ ] All current functionality works (per Section 8 checklist)
- [ ] Authentication flow complete with login UI
- [ ] Entity CRUD operations work via SDK
- [ ] File upload/download works
- [ ] Query filtering works (browse folders, filter types)
- [ ] Local fields (isHidden, pin) persist
- [ ] No regressions in local_store or other packages
- [ ] Code is cleaner and more maintainable than before

---

## 20. Next Steps for Implementation

1. **Review this plan** with stakeholders
2. **Set up development branch** for migration work
3. **Start with Phase 1** (preparation, adapters)
4. **Build authentication** (Phase 2) in parallel
5. **Core rewrite** (Phase 3) - main effort
6. **Integration testing** (Phase 5) - thorough validation
7. **Deploy and monitor** - Gradual rollout

**Estimated Timeline:** 2-4 weeks depending on team size and testing requirements
