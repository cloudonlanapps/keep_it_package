# CLServer vs AuthState: Analysis and Merger Investigation

**Date**: 2026-02-14
**Purpose**: Investigate merging AuthState into CLServer to reduce provider count while avoiding frequent UI updates

---

## Current Architecture

### CLServer (`cl_servers` package)

**Location**: `cl_servers/lib/src/models/cl_server.dart`

**Purpose**: Represents a remote server with health monitoring capabilities

**Contains**:
```dart
class CLServer {
  final RemoteServiceLocationConfig locationConfig;  // Server URLs (auth, store, compute, mqtt)
  final ServerHealthStatus healthStatus;             // Health monitoring data
  final http.Client? client;                         // HTTP client for requests

  bool get connected => healthStatus.isHealthy;      // Convenience getter
  String? get broadcastStatus;                       // NSD broadcast status
  List<String>? get broadcastErrors;                 // NSD broadcast errors
  bool get hasBroadcastIssues;                       // Has broadcast problems
}
```

**Health Status Details** (`ServerHealthStatus`):
```dart
class ServerHealthStatus {
  final String? broadcastStatus;           // From NSD (e.g., 'healthy', 'unhealthy')
  final List<String>? broadcastErrors;     // Errors from NSD
  final DateTime lastChecked;              // When we last checked
  final bool ourHealthCheckPassed;         // Did our ping succeed?

  bool get isHealthy => !hasBroadcastIssues && ourHealthCheckPassed;
}
```

**Provider**: `serverProvider` (`AsyncNotifierProviderFamily<ServerNotifier, CLServer, RemoteServiceLocationConfig>`)

**How it works**:
1. Watches `networkScannerProvider` for NSD broadcast health updates
2. Performs own health check via `serverHealthCheckProvider` (pings endpoints)
3. Combines both into `ServerHealthStatus`
4. Creates `CLServer` with combined health status
5. Has `recheckHealth()` method to invalidate and re-check

---

### AuthState (`colan_services` package)

**Location**: `colan_services/lib/services/auth_service/models/auth_state.dart`

**Purpose**: Represents authentication state for a remote server

**Contains**:
```dart
class AuthState {
  final SessionManager? sessionManager;    // DartSDK SessionManager
  final UserResponse? currentUser;         // Current authenticated user
  final DateTime? loginTimestamp;          // When user logged in

  bool get isAuthenticated => sessionManager?.isAuthenticated ?? false;
}
```

**Provider**: `authStateProvider` (`AsyncNotifierProviderFamily<AuthNotifier, AuthState, RemoteServiceLocationConfig>`)

**How it works**:
1. Manages login/logout operations
2. Handles token refresh
3. Auto-login from saved credentials
4. Creates and maintains `SessionManager` instance

---

## Where Are They Used?

### CLServer / serverProvider Usage

1. **`content_store/lib/src/stores/providers/store_provider.dart`**
   - Creates `OnlineEntityStore` with `CLServer`
   - Uses `server.connected` for `isAlive` getter
   - **Frequency**: Once during store creation

2. **`cl_servers/lib/src/providers/available_servers.dart`**
   - Lists available servers discovered via NSD
   - Filters to show only healthy servers
   - **Frequency**: When scanning for servers

3. **`content_store/lib/src/widgets/content_store_selector_icon.dart`** (line 137, 150)
   - UI widget to show if store is alive/reachable
   - Uses `store.entityStore.isAlive` (which comes from `server.connected`)
   - **Frequency**: Widget rebuild (could be frequent)

4. **`colan_services/lib/services/entity_viewer_service/views/keep_it_error_view.dart`** (line 33)
   - Error view that checks if store is alive
   - Uses `store.entityStore.isAlive`
   - **Frequency**: When errors occur

5. **`content_store/lib/src/stores/providers/registerred_urls.dart`** (line 47)
   - URL registration that checks if store is alive
   - Uses `store.entityStore.isAlive`
   - **Frequency**: During URL registration

### AuthState / authStateProvider Usage

1. **`colan_services/lib/services/auth_service/views/logged_in_view.dart`** (line 21)
   - **UI WIDGET** that shows login status
   - Uses: `authState.isAuthenticated`, `authState.currentUser?.username`, `authState.loginTimestamp`
   - **Frequency**: Widget rebuild (EVERY authState change)
   - ⚠️ **CRITICAL**: This widget rebuilds on ANY authState change

2. **`colan_services/lib/services/auth_service/auth_service.dart`** (line 62)
   - Service that manages authentication
   - Watches `authStateProvider`
   - **Frequency**: During auth operations

3. **`content_store/lib/src/stores/providers/store_provider.dart`** (future)
   - Will use `authStateProvider` to get `SessionManager`
   - For creating `StoreManager` via `sessionManager.createStoreManager()`
   - **Frequency**: Once during store creation

---

## Update Frequency Analysis

### How Often Does serverProvider Update?

**Triggers**:
1. **networkScannerProvider changes** - When NSD discovers/loses servers or broadcast health changes
2. **Manual recheckHealth()** - When explicitly requested
3. **Initial build** - Once per RemoteServiceLocationConfig

**Estimate**:
- During active scanning: Could update every few seconds as servers appear/disappear
- After stabilization: Updates only when broadcast health changes
- If server goes down/up: Immediate update
- **Conclusion**: Could be frequent during network changes

### How Often Does authStateProvider Update?

**Triggers**:
1. **Login** - Once when user logs in
2. **Logout** - Once when user logs out
3. **Token refresh** - Periodically (based on token expiry, typically every hour or more)
4. **Auto-login** - Once on app start if credentials saved

**Estimate**:
- Normal usage: Very rare (only on login/logout/token refresh)
- **Conclusion**: Very infrequent updates

---

## Problem with Merging

### If We Merge AuthState INTO CLServer

**New Structure**:
```dart
class CLServer {
  final RemoteServiceLocationConfig locationConfig;
  final ServerHealthStatus healthStatus;
  final SessionManager? sessionManager;      // FROM AuthState
  final UserResponse? currentUser;           // FROM AuthState
  final DateTime? loginTimestamp;            // FROM AuthState
  final http.Client? client;
}
```

**Single Provider**: `serverProvider` would manage both health AND auth

### UI Update Frequency Issue ⚠️

**Current Behavior**:
- `logged_in_view.dart` watches `authStateProvider`
- Rebuilds only on: login, logout, token refresh (rare)
- ✅ **Good**: Minimal UI rebuilds

**After Merge**:
- `logged_in_view.dart` would watch `serverProvider`
- Would rebuild on: login, logout, token refresh, **PLUS** every health check update
- ❌ **Bad**: Frequent UI rebuilds during network scanning/health monitoring

**Impact**:
- UI flickers/stutters during network scanning
- Unnecessary widget rebuilds
- Poor user experience
- Battery drain from constant rebuilds

---

## Alternative Solutions

### Option 1: Keep Them Separate (Current - RECOMMENDED)

**Pros**:
- ✅ Clean separation of concerns
- ✅ No UI update issues
- ✅ Each provider updates at appropriate frequency
- ✅ Easy to understand and maintain

**Cons**:
- ⚠️ Two providers to manage per RemoteServiceLocationConfig
- ⚠️ Slightly more complex architecture

**Recommendation**: **Keep as-is**

---

### Option 2: Merge with Selective Watching

**Approach**: Merge into one provider but use `select()` to watch only specific fields

**Example**:
```dart
// Watch only auth fields (won't rebuild on health changes)
final authState = ref.watch(
  serverProvider(config).select((server) => (
    sessionManager: server.sessionManager,
    currentUser: server.currentUser,
    loginTimestamp: server.loginTimestamp,
  ))
);

// Watch only health fields (won't rebuild on auth changes)
final isHealthy = ref.watch(
  serverProvider(config).select((server) => server.healthStatus.isHealthy)
);
```

**Pros**:
- ✅ Single provider to manage
- ✅ Can avoid unnecessary rebuilds with proper selectors
- ✅ Reduces provider count

**Cons**:
- ⚠️ Requires developers to remember to use `.select()` everywhere
- ⚠️ Easy to forget and cause performance issues
- ⚠️ More complex code at usage sites
- ⚠️ Harder to maintain

**Recommendation**: **Not recommended** - too easy to misuse

---

### Option 3: Keep Separate but Share SessionManager Reference

**Approach**:
- Keep `authStateProvider` for auth state
- Keep `serverProvider` for health status
- Both reference the same `SessionManager` instance

**Structure**:
```dart
// AuthState stays the same
class AuthState {
  final SessionManager? sessionManager;
  final UserResponse? currentUser;
  final DateTime? loginTimestamp;
}

// CLServer adds sessionManager reference
class CLServer {
  final RemoteServiceLocationConfig locationConfig;
  final ServerHealthStatus healthStatus;
  final SessionManager? sessionManager;  // Reference to same instance
  final http.Client? client;
}
```

**How it works**:
1. `authStateProvider` creates and owns `SessionManager`
2. `serverProvider` reads `authStateProvider` to get `SessionManager` reference
3. Both can access authentication capabilities
4. Updates are still separate

**Pros**:
- ✅ Clean separation of update frequencies
- ✅ Both can access `SessionManager` when needed
- ✅ No UI update issues
- ✅ Minimal code changes

**Cons**:
- ⚠️ Dependency between providers (serverProvider depends on authStateProvider)
- ⚠️ Still two providers

**Recommendation**: **Viable alternative** if single provider access is desired

---

### Option 4: Create Combined View Model for UI

**Approach**: Create a separate provider that combines both for UI consumption

**Structure**:
```dart
class ServerAndAuthViewModel {
  final CLServer server;
  final AuthState authState;

  bool get isHealthy => server.connected;
  bool get isAuthenticated => authState.isAuthenticated;
  // ... other combined getters
}

final serverAndAuthViewModelProvider = Provider.family<ServerAndAuthViewModel, RemoteServiceLocationConfig>(
  (ref, config) {
    final server = ref.watch(serverProvider(config)).value;
    final authState = ref.watch(authStateProvider(config)).value;

    return ServerAndAuthViewModel(server: server, authState: authState);
  }
);
```

**Pros**:
- ✅ Single access point for UI
- ✅ Underlying providers stay separate (good update frequency)
- ✅ UI can watch combined view with proper equality checks
- ✅ Can implement smart equality to prevent unnecessary rebuilds

**Cons**:
- ⚠️ Three providers total (server, auth, combined view)
- ⚠️ More complex architecture

**Recommendation**: **Only if UI needs both frequently**

---

## Investigation Results: Can We Remove CLServer After Migration?

### Short Answer: **NO - We CANNOT remove CLServer**

### Why CLServer Must Be Kept

**1. Health Status is Critical for OnlineEntityStore**

The `OnlineEntityStore.isAlive` getter depends on `server.connected`:
```dart
// online_store/lib/src/models/entity_store.dart
bool get isAlive => server.connected;
```

This is used by:
- UI widgets to show if server is reachable
- Error views to determine connection issues
- URL registration to check server availability

**2. DartSDK StoreManager Does NOT Provide Health Monitoring**

Looking at DartSDK `StoreManager`:
- ✅ Has `storeClient.isConnected` (checks if client is configured)
- ❌ Does NOT monitor server health actively
- ❌ Does NOT integrate with NSD broadcast health
- ❌ Does NOT perform periodic health checks
- ❌ Does NOT combine broadcast health + ping checks

**3. Network Scanner Integration is Unique to CLServer**

`serverProvider` watches `networkScannerProvider`:
- Discovers servers via NSD (Network Service Discovery)
- Receives broadcast health status from servers
- Filters available servers by health
- This functionality doesn't exist in DartSDK

---

## Recommended Architecture for Phase 2 Implementation

### Keep Both Providers with Clear Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│  Per RemoteServiceLocationConfig                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────┐      ┌──────────────────────┐    │
│  │  serverProvider      │      │  authStateProvider   │    │
│  ├──────────────────────┤      ├──────────────────────┤    │
│  │ - locationConfig     │      │ - sessionManager     │    │
│  │ - healthStatus       │      │ - currentUser        │    │
│  │ - client             │      │ - loginTimestamp     │    │
│  │                      │      │                      │    │
│  │ Updates:             │      │ Updates:             │    │
│  │ - NSD changes        │      │ - Login/logout       │    │
│  │ - Health checks      │      │ - Token refresh      │    │
│  │ - Network events     │      │                      │    │
│  └──────────────────────┘      └──────────────────────┘    │
│           │                              │                  │
│           │                              │                  │
│           ▼                              ▼                  │
│  ┌────────────────────────────────────────────────┐        │
│  │         OnlineEntityStore                      │        │
│  ├────────────────────────────────────────────────┤        │
│  │ Uses serverProvider for:                       │        │
│  │  - healthStatus → isAlive getter               │        │
│  │  - locationConfig → base URLs                  │        │
│  │                                                 │        │
│  │ Uses authStateProvider for:                    │        │
│  │  - sessionManager → createStoreManager()       │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### OnlineEntityStore Implementation

```dart
class OnlineEntityStore extends EntityStore {
  const OnlineEntityStore({
    required super.identity,
    required RemoteServiceLocationConfig super.locationConfig,
    required this.storeManager,
    required this.healthStatus,     // NEW: from serverProvider
  });

  final sdk.StoreManager storeManager;
  final ServerHealthStatus healthStatus;  // NEW: for isAlive

  @override
  bool get isAlive => healthStatus.isHealthy;  // Use health status

  // ... rest of implementation uses storeManager
}
```

### StoreProvider Changes

```dart
class StoreNotifier extends FamilyAsyncNotifier<CLStore, ServiceLocationConfig> {
  @override
  FutureOr<CLStore> build(ServiceLocationConfig arg) async {
    final config = arg;
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final storePath = p.join(directories.stores.pathString, config.displayName);

    final EntityStore entityStore;

    if (config is LocalServiceLocationConfig) {
      entityStore = await createEntityStore(config, ...);
    } else if (config is RemoteServiceLocationConfig) {
      // Get BOTH providers
      final server = await ref.watch(serverProvider(config).future);
      final authState = await ref.watch(authStateProvider(config).future);

      if (!authState.isAuthenticated || authState.sessionManager == null) {
        throw StateError('Not authenticated');
      }

      // Create StoreManager from SessionManager
      final storeManager = authState.sessionManager!.createStoreManager();

      // Create OnlineEntityStore with BOTH storeManager AND healthStatus
      entityStore = OnlineEntityStore(
        identity: config.storeUrl,
        locationConfig: config,
        storeManager: storeManager,
        healthStatus: server.healthStatus,  // For isAlive
      );
    } else {
      throw Exception('Unknown service location config type');
    }

    return CLStore(
      entityStore: entityStore,
      tempFilePath: directories.temp.pathString,
    );
  }
}
```

---

## Conclusion and Recommendations

### 1. Do NOT Merge AuthState into CLServer

**Reasons**:
- ❌ Would cause frequent UI rebuilds in `logged_in_view.dart`
- ❌ Updates happen at very different frequencies (health checks vs auth events)
- ❌ Mixing concerns violates separation of responsibilities
- ❌ Would require developers to use `.select()` everywhere (error-prone)

### 2. Do NOT Remove CLServer or serverProvider

**Reasons**:
- ✅ Health monitoring is CRITICAL for `isAlive` functionality
- ✅ NSD integration and broadcast health monitoring is unique to CLServer
- ✅ DartSDK StoreManager does NOT provide this functionality
- ✅ UI depends on health status for user experience

### 3. Keep Both Providers (RECOMMENDED APPROACH)

**For Phase 2 Implementation**:
1. ✅ Keep `serverProvider` for health monitoring
2. ✅ Keep `authStateProvider` for authentication
3. ✅ `OnlineEntityStore` uses BOTH:
   - `authState.sessionManager.createStoreManager()` for store operations
   - `server.healthStatus` for `isAlive` getter
4. ✅ Each provider updates at appropriate frequency
5. ✅ No UI performance issues

### 4. What Gets Removed

**Can Remove**:
- ✅ `EntityServer` extension (replaced by DartSDK StoreManager methods)
- ✅ CLServer dependency from `online_store` package (but NOT from codebase)

**Must Keep**:
- ✅ `serverProvider` (for health monitoring)
- ✅ `authStateProvider` (for authentication)
- ✅ CLServer class and package (for health status infrastructure)

---

## Updated Phase 2 Implementation Plan

### Step 1: Create Entity Mapper
Convert between CLEntity (DateTime) and DartSDK Entity (int milliseconds)

### Step 2: Create StoreManager Provider
**SKIP THIS** - Use `authStateProvider` directly to get SessionManager

### Step 3: Rewrite OnlineEntityStore
- Accept BOTH `storeManager` AND `healthStatus` in constructor
- Use `storeManager` for all store operations
- Use `healthStatus.isHealthy` for `isAlive` getter

### Step 4: Update StoreProvider
- Watch BOTH `serverProvider` and `authStateProvider`
- Get `SessionManager` from `authState.sessionManager`
- Get `healthStatus` from `server.healthStatus`
- Create `StoreManager` via `sessionManager.createStoreManager()`
- Pass both to OnlineEntityStore

### Step 5: Remove EntityServer Extension
- Delete `online_store/lib/src/models/entity_server.dart`
- Remove CLServer dependency from `online_store/pubspec.yaml`

### Step 6: Update Dependencies
- Add DartSDK to `online_store/pubspec.yaml`

---

## Files That Will Be Modified

1. **`online_store/lib/src/models/entity_store.dart`**
   - Add `healthStatus` parameter
   - Change implementation to use DartSDK StoreManager

2. **`content_store/lib/src/stores/providers/store_provider.dart`**
   - Watch both `serverProvider` and `authStateProvider`
   - Create StoreManager from SessionManager
   - Pass healthStatus to OnlineEntityStore

3. **`online_store/lib/src/models/entity_server.dart`**
   - DELETE this file (EntityServer extension no longer needed)

4. **`online_store/pubspec.yaml`**
   - Add DartSDK dependency
   - Can remove `cl_servers` dependency

---

**Status**: Analysis Complete - Ready for User Review
**Recommendation**: Keep both providers, use both in OnlineEntityStore
