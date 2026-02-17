# ShadTheme Consistency Review

## Overview

The app has three overlapping theme systems in use, which creates inconsistency — especially for dark mode support:

| System | Package | Purpose |
|--------|---------|---------|
| `ShadTheme` | `shadcn_flutter` | Primary design system (intended) |
| `CLTheme` | custom | App-specific brand colors |
| `Theme` | Flutter Material | Leaking through in several widgets |

**Target state:** All UI widgets should use `ShadTheme.of(context)` for colors and typography. `CLTheme` may remain for brand-specific tokens not covered by ShadTheme. `Theme` (Material) usage should be eliminated.

---

## Theme Configuration

Defined in `keep_it/lib/views/app_start_views/app_start_view.dart`:

```dart
ShadApp(
  theme: ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadZincColorScheme.light(),
  ),
  darkTheme: ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadZincColorScheme.dark(),
  ),
  themeMode: themeMode,
)
```

### Available ShadTheme Tokens

**Colors** — `ShadTheme.of(context).colorScheme`
- `foreground`, `background`
- `destructive`, `destructiveForeground`
- `muted`, `mutedForeground`
- `accent`, `accentForeground`
- `secondary`, `secondaryForeground`

**Typography** — `ShadTheme.of(context).textTheme`
- `p` — body paragraph
- `h1`, `h2`, `h3`, `h4` — headings
- `large`, `small`, `muted`, `lead`

---

## Widgets Needing Attention

### 1. Critical — No ShadTheme usage at all

#### `keep_it/lib/views/auth_views/auth_view.dart` + `logged_in_view.dart`

- All text styles use `Theme.of(context).textTheme` (Material)
- Uses `Theme.of(context).dividerColor` for dividers
- Hardcoded `Colors.green` for the success/connected icon
- No ShadTheme usage anywhere in these files

**Fix:** Migrate text styles to `ShadTheme.of(context).textTheme`, replace `dividerColor` with a `ShadTheme` color (e.g., `colorScheme.muted`), replace `Colors.green` with an appropriate semantic color.

---

### 2. High — Hardcoded colors break dark mode

#### `colan_widgets/lib/src/views/cl_loading_view.dart`

Shimmer loading effect uses hardcoded light-mode colors:
- `Colors.grey[300]` — shimmer base
- `Colors.grey[100]` — shimmer highlight
- `Colors.white` — container background
- `Colors.grey.withValues(alpha: 0.5)` — box shadow

These are invisible or incorrect in dark mode.

**Fix:** Derive shimmer colors from `ShadTheme.of(context).colorScheme` (e.g., `muted`, `mutedForeground`).

#### `cl_entity_viewers/lib/src/page_view/cl_media_viewer.dart`

- `backgroundColor: Colors.black` — hardcoded, ignores light theme

**Fix:** Use `ShadTheme.of(context).colorScheme.background` or keep black only when the media viewer is in fullscreen/overlay mode (conditionally).

---

### 3. Medium — Mixed Material + ShadTheme

#### `colan_widgets/lib/src/views/cl_error_view.dart`

Mostly correct ShadTheme usage, but one Material leak:
- Line with `Theme.of(context).colorScheme.error` — should be `ShadTheme.of(context).colorScheme.destructive`

**Fix:** One-line replacement.

#### `colan_widgets/lib/src/views/appearance/cl_scaffold.dart`

- Hardcoded rainbow gradient (`Colors.red`, `Colors.orange`, `Colors.yellow`, etc.) for a decorative element — ignores theme
- `Theme.of(context).dividerColor` — Material leak

**Fix:** Replace `dividerColor` with a ShadTheme equivalent. Decide whether the gradient is intentionally brand-fixed or should be theme-aware.

#### `colan_widgets/lib/src/views/wizards/wizard_dialog.dart`

Uses all three theme systems simultaneously:
- `CLTheme.of(context)` for button backgrounds
- `ShadTheme.of(context)` for text styles
- Hardcoded `Colors.grey` for disabled states (multiple occurrences)

**Fix:** Replace `Colors.grey` disabled states with `ShadTheme.of(context).colorScheme.mutedForeground`. Establish a consistent rule for when to use CLTheme vs ShadTheme.

---

### 4. Low — New file, no theme integration

#### `colan_widgets/lib/src/views/appearance/cl_top_bar.dart`

- New file using raw Material `AppBar`
- No ShadTheme styling applied
- Inconsistent with surrounding UI

**Fix:** Apply ShadTheme typography and colors to match the rest of the UI. Consider whether to keep Material `AppBar` or wrap it with custom ShadTheme-styled container.

---

## Summary Table

| Widget | Issue | Severity |
|--------|-------|----------|
| `keep_it/lib/views/auth_views/auth_view.dart` | 100% Material Theme, hardcoded `Colors.green` | High |
| `keep_it/lib/views/auth_views/logged_in_view.dart` | 100% Material Theme, no ShadTheme | High |
| `colan_widgets/lib/src/views/cl_loading_view.dart` | Hardcoded grey/white shimmer — dark mode broken | High |
| `cl_entity_viewers/lib/src/page_view/cl_media_viewer.dart` | `Colors.black` background | Medium |
| `colan_widgets/lib/src/views/cl_error_view.dart` | One `Theme.of(...).colorScheme.error` instead of ShadTheme | Medium |
| `colan_widgets/lib/src/views/appearance/cl_scaffold.dart` | Hardcoded gradient + Material `dividerColor` | Medium |
| `colan_widgets/lib/src/views/wizards/wizard_dialog.dart` | 3-way theme mix + hardcoded `Colors.grey` for disabled states | Medium |
| `colan_widgets/lib/src/views/appearance/cl_top_bar.dart` | New file, raw Material `AppBar`, no ShadTheme | Low |

---

## Widgets in Good Shape

These widgets already use ShadTheme correctly:

- `keep_it/lib/views/preference_views/settings_view.dart` — uses `ShadTheme.of(context).textTheme`
- `keep_it/lib/views/common_widgets/action_buttons.dart` — uses `ShadButton.ghost` properly
- `keep_it/lib/views/entity_viewer_views/entity_viewer_view.dart` — delegates to CLLoadingView / CLErrorView
- `keep_it/lib/views/entity_viewer_views/top_bar.dart` — delegates to CLTopBar
