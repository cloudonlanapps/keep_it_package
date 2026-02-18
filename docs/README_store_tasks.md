# Store Tasks Service Documentation


This document outlines the workflows and logic for Store Tasks, specifically focusing on how media entities are moved, copied, and processed between stores. It serves as a basis for creating UI tests and mocking required providers.

## Review & Feedback (Please Add Your Comments Here)
> [!NOTE]
> Please add your feedback, corrections, or missing workflows below.
> - [ ] verify "Same Store" logic
> - [ ] verify "Different Store" logic
> - [ ] add any missing workflows?

---


## Core Logic: The "Move" Operation

The core logic for moving or accepting entities into a collection resides in `CLStore.move` (in `cl_store.dart`). The behavior differs depending on whether the source and target collections are in the same store or different stores.

### 1. Same Store
**Condition:** `targetCollection.store.entityStore == entity.store.entityStore`

**Behavior:**
-   It simply updates the `parentId` of the entity to point to the new collection.
-   **Code Reference:** `cl_store.dart` lines 173-177.

### 2. Different Store
**Condition:** The stores are different (e.g., moving from Local Store to Cloud Store, or Temp Store to Persistent Store).

**Workflow (Copy-Verify-Delete):**
1.  **Download:** The source content is downloaded to a temporary file.
    -   **Code Reference:** `cl_store.dart` line 189.
2.  **Upload:** A new media entity is created in the target store using the temporary file. This effectively uploads the content.
    -   **Code Reference:** `cl_store.dart` line 201.
3.  **Verify:** The system checks if the target entity was created successfully. If the creation returns null, it attempts recovery by checking if the entity exists in the target store (matching by MD5 and file size).
    -   **Code Reference:** `cl_store.dart` lines 227-251.
4.  **Delete:** If verification is successful (entity exists in target), the original source entity is deleted to complete the move.
    -   **Code Reference:** `cl_store.dart` line 258.

---

## UI Workflows

The `StoreTaskWizard` handles the UI flow for these operations. It uses a step-based approach (`confirmation` -> `targetSelection` -> `progress`).

### 1. Camera Capture
*When a user captures photos or videos using the in-app camera.*

1.  **Capture & Staging:**
    -   Media is captured and immediately saved to a temporary collection ("*** Recently Captured") in the Default Store (usually Local).
    -   A `StoreTask` is created with `ContentOrigin.camera`.
2.  **Wizard Step 1: Confirmation ("Review Captured Items")**
    -   User sees a preview of captured items.
    -   **Actions:**
        -   **Save (Keep):** Proceeds to Target Selection.
        -   **Discard:** Deletes the temporary items and cancels the task.
3.  **Wizard Step 2: Target Selection ("Save to...")**
    -   User selects a destination collection.
4.  **Wizard Step 3: Progress**
    -   Executes the **Different Store** logic (since it moves from Temp/Default Store to the user-selected collection).
    -   Displays a progress bar.

### 2. Move Items
*When a user selects existing items and chooses "Move".*

1.  **Selection:**
    -   User enters selection mode and selects items.
    -   A `StoreTask` is created with `ContentOrigin.move`.
2.  **Wizard Step 1: Confirmation**
    -   **Skipped/Auto-confirmed.** The UI automatically proceeds because the user explicitly initiated a move action.
3.  **Wizard Step 2: Target Selection ("Move to...")**
    -   User selects a destination collection.
4.  **Wizard Step 3: Progress**
    -   Executes either **Same Store** or **Different Store** logic depending on the source and destination stores.

### 3. Import (File Pick)
*When a user imports files from the device.*

1.  **Staging:**
    -   Files are picked and processed into valid `StoreEntity` objects (often staged in a temp location).
    -   A `StoreTask` is created with `ContentOrigin.filePick`.
2.  **Wizard Step 1: Confirmation ("Review Valid Files")**
    -   User reviews the files to be imported.
    -   **Actions:**
        -   **Import:** Proceeds to Target Selection.
        -   **Discard:** Cancels.
3.  **Wizard Step 2: Target Selection ("Import to...")**
    -   User selects a destination collection.
4.  **Wizard Step 3: Progress**
    -   Executes the move/copy logic to ingest files into the store.

### 4. Restore (From Trash)
*When a user restores deleted items.*

1.  **Selection:** User selects items in the Trash.
2.  **Wizard Step 1: Confirmation ("Restore Items?")**
    -   **Actions:**
        -   **Restore:** Proceeds to Target Selection.
        -   **Delete Forever:** Permanently removes items.
3.  **Wizard Step 2: Target Selection ("Restore to...")**
    -   User selects where to restore the items.
4.  **Wizard Step 3: Progress**
    -   Moves items from Trash to the selected collection.
