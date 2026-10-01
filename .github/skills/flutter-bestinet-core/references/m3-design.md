# Material 3 — full design contract

`SKILL.md` §8–§9 is the summary. Open this when designing a screen, building or reviewing a widget,
or theming a component. Everything here is expressed through the theme (`lib/core/theme/`) and read
from `context` — never hardcoded in `lib/modules/`.

## 1. Principles and decision order
Personal, adaptive, expressive, accessible. For every visual decision: **semantic intent → M3 token
(colour role / type role / shape / elevation / motion) → M3 component → Flutter widget**. If no M3
component fits, compose one from M3 tokens — don't invent a parallel style.

## 2. Colour
**Roles** (all on `Theme.of(context).colorScheme`):
- Accent: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer` — and the same quartet for
  `secondary`, `tertiary`, `error`.
- Fixed accents (same in light and dark): `primaryFixed`, `primaryFixedDim`, `onPrimaryFixed`,
  `onPrimaryFixedVariant` (and secondary/tertiary equivalents).
- Surfaces: `surface`, `onSurface`, `onSurfaceVariant`, `surfaceDim`, `surfaceBright`,
  `surfaceContainerLowest` / `Low` / `` / `High` / `Highest`.
- Utility: `outline`, `outlineVariant`, `inverseSurface`, `onInverseSurface`, `inversePrimary`,
  `shadow`, `scrim`, `surfaceTint`.

**Rules**
- Always pair a colour with its `on*` role. Never place `onPrimary` text on `surface`, etc.
- Hierarchy by role, not by picking lighter/darker hexes: primary for the key action, secondary for
  less prominent controls, tertiary for contrasting accents, containers for fills that need less
  emphasis than the base role.
- Surfaces are layered with the `surfaceContainer*` steps (background → cards → sheets → dialogs),
  not with shadows or custom greys.
- Deprecated: `background`/`onBackground` → `surface`/`onSurface`; `surfaceVariant` →
  `surfaceContainerHighest`.
- **Brand apps don't use dynamic (wallpaper) colour.** The scheme is seeded from the brand constant
  (`AppColors.primary`) with the used roles pinned (see `architecture-rules.md` §8). Adopting
  `dynamic_color` is a recorded decision, not a default.
- Never convey meaning by colour alone — pair it with an icon, label or shape.
- **Contrast (WCAG 2.1 AA), verified in light and dark:** body text 4.5:1, large text (≥ 24 sp, or
  ≥ 18.5 sp bold) 3:1, icons and control boundaries 3:1.
- **Dark theme** is its own scheme from the same seed, not an inverted light theme. Pinned brand roles
  get a dark counterpart that passes contrast; don't reuse the light hex.

## 3. Typography
Font family set once in the `TextTheme` builder (the project's brand font, e.g. Inter). Widgets use
`Theme.of(context).textTheme.<role>` and at most `copyWith(color: …)` from a colour role — never a
raw `fontSize`, `fontWeight` or `height`.

| Role | Size / line height (sp) | Weight | Tracking |
|---|---|---|---|
| displayLarge / Medium / Small | 57/64 · 45/52 · 36/44 | 400 | −0.25 · 0 · 0 |
| headlineLarge / Medium / Small | 32/40 · 28/36 · 24/32 | 400 | 0 |
| titleLarge / Medium / Small | 22/28 · 16/24 · 14/20 | 400 · 500 · 500 | 0 · 0.15 · 0.1 |
| bodyLarge / Medium / Small | 16/24 · 14/20 · 12/16 | 400 | 0.5 · 0.25 · 0.4 |
| labelLarge / Medium / Small | 14/20 · 12/16 · 11/16 | 500 | 0.1 · 0.5 · 0.5 |

Set line height in the builder as `height: lineHeight / fontSize`. Usage: display for hero numbers,
headline for screen-level headings, title for app bars/cards/list headers, body for content, label
for buttons, chips, tabs and captions.

## 4. Shape
| Token | Radius | Typical components |
|---|---|---|
| none | 0 | full-screen dialogs, full-bleed images |
| extraSmall | 4 | text fields (top corners), menus, snackbars, tooltips |
| small | 8 | chips |
| medium | 12 | cards |
| large | 16 | FABs, navigation drawer, side sheets |
| extraLarge | 28 | dialogs, bottom sheets (top corners), large FAB |
| full | pill | buttons, search bar, badges, sliders, switches |

Radii live as named constants in `core/theme/` and are applied through component themes. Don't round
an individual widget ad hoc.

## 5. Elevation
Levels 0–5 = 0, 1, 3, 6, 8, 12 dp. M3 expresses elevation mainly by **tone**: a raised surface uses a
higher `surfaceContainer*` step. Shadows are reserved for elements that must separate from busy
content (FAB, menus, dragged items). Typical levels: app bar 0 (level 2 when scrolled under), card
0–1, FAB 3, menu 2, navigation bar 2, dialog 3, modal bottom sheet 1.

## 6. Interaction states
- **State layers** are an overlay of the content colour at: hover 8%, focus 10%, pressed 10%,
  dragged 16%. Built-in M3 components do this already.
- **Disabled:** content at 38% opacity of `onSurface`; container at 12% of `onSurface`.
- Custom tappable widgets must get the same behaviour: wrap in `Material` + `InkWell` (the ripple uses
  the theme's splash) or style with `WidgetStateProperty` / `WidgetState` using these opacities.
  `MaterialStateProperty` is deprecated → `WidgetStateProperty`.
- Every interactive element shows a visible focus state for keyboard and switch access.

## 7. Motion
- **Durations** (Flutter `Durations`): short1–4 = 50/100/150/200 ms, medium1–4 = 250/300/350/400,
  long1–4 = 450/500/550/600, extraLong1–4 = 700/800/900/1000. Small utility changes use short; most
  component transitions use medium; full-screen transitions use long.
- **Easing** (Flutter `Easing`): `emphasizedDecelerate` for elements entering, `emphasizedAccelerate`
  for elements exiting, `standard` / `standardDecelerate` / `standardAccelerate` for small utility
  motion. No `Curves.linear` for UI movement.
- **Transition patterns** (the `animations` package when present): container transform (card →
  detail), shared axis (steps in a flow, tabs), fade through (switching unrelated destinations), fade
  (dialogs, menus appearing).
- Respect reduced motion: if `MediaQuery.disableAnimationsOf(context)` is true, drop to a fade or no
  animation.
- No magic durations or curves in widgets — reference `Durations.*` / `Easing.*`.

## 8. Layout, spacing and adaptive design
- 4 dp grid; spacing tokens 4/8/12/16/24/32/48 from `core/theme` constants.
- **Window size classes:** compact < 600, medium 600–839, expanded 840–1199, large 1200–1599,
  extra-large ≥ 1600 (dp width).
- **Margins:** compact 16, medium and above 24. Keep reading width comfortable — cap text columns
  (about 600–840 dp) instead of stretching them edge to edge.
- **Navigation by size class:** compact → `NavigationBar` (3–5 destinations); medium → `NavigationRail`;
  expanded and up → `NavigationRail` or `NavigationDrawer`. The destinations stay the same; only the
  container changes.
- **Canonical layouts:** list-detail (one pane on compact, two panes on expanded), supporting pane
  (main content plus a secondary panel), feed (a grid of cards that reflows by width).
- Minimum touch target **48 × 48 dp**, at least 8 dp apart, even when the visual element is smaller
  (icons stay 24 dp; the tap area is 48).
- Respect system text scaling up to 200%: no fixed-height text containers, and no global
  `TextScaler` clamp. Test key screens at large text sizes.
- Handle safe areas and the on-screen keyboard (`SafeArea`, scrollable forms).

## 9. Components — pick the M3 widget
| Need | Use | Not |
|---|---|---|
| Highest-emphasis action (≤ 1 per screen) | `FilledButton` | `ElevatedButton` as primary |
| Important secondary action | `FilledButton.tonal` | |
| Secondary action | `OutlinedButton` | |
| Low-emphasis action, dialog actions | `TextButton` | |
| Icon action | `IconButton` / `.filled` / `.filledTonal` / `.outlined`, with a `tooltip` | bare `GestureDetector` on an icon |
| Primary screen action (≤ 1 per screen) | `FloatingActionButton` (`.small` / `.large` / `.extended`) | |
| 2–5 mutually exclusive options | `SegmentedButton` | `ToggleButtons` |
| Filters, suggestions, entered tokens | `FilterChip`, `ActionChip`, `InputChip`, `AssistChip` | styled containers |
| Grouped content | `Card` (elevated) / `Card.filled` / `Card.outlined` | custom `Container` + shadow |
| Rows in a list | `ListTile` (one, two or three lines) | hand-built rows |
| Screen header | `AppBar` (small or center-aligned), `SliverAppBar.medium` / `.large` for collapsing | |
| Top-level destinations | `NavigationBar` / `NavigationRail` / `NavigationDrawer` | `BottomNavigationBar` (M2) |
| Sub-sections within a screen | `TabBar` (primary) / `TabBar.secondary` | |
| Confirmation or critical info | `AlertDialog` (title, supporting text, `TextButton` actions); `Dialog.fullscreen` for compact-size tasks | |
| Contextual choices | `showModalBottomSheet(showDragHandle: true, …)` | custom overlays |
| Brief feedback | `SnackBar` (one action max) | toast-style custom widgets where a SnackBar fits |
| Menus and pickers | `MenuAnchor`, `DropdownMenu` | `PopupMenuButton`, `DropdownButton` in new code |
| Search | `SearchAnchor` + `SearchBar` | |
| Text input | `TextField` / `TextFormField` — filled or outlined, one style per app via `inputDecorationTheme`; label + supporting/error text | placeholder-only fields |
| Selection controls | `Switch`, `Checkbox`, `Radio`, `Slider` | |
| Progress | `LinearProgressIndicator`, `CircularProgressIndicator` | custom spinners |
| Counts and status | `Badge` | |
| Browsing a set of media | `CarouselView` | |
| Dates and times | `showDatePicker`, `showDateRangePicker`, `showTimePicker` | |

Also deprecated or replaced: `ButtonBar` → `OverflowBar`; the M2 `BottomNavigationBar` → `NavigationBar`
(migrate as a deliberate task).

## 10. Component theming
- Component styles are defined **once** in `ThemeData` component themes in `core/theme/app_theme.dart`
  (`filledButtonTheme`, `outlinedButtonTheme`, `textButtonTheme`, `cardTheme`, `inputDecorationTheme`,
  `dialogTheme`, `bottomSheetTheme`, `snackBarTheme`, `chipTheme`, `navigationBarTheme`,
  `navigationRailTheme`, `appBarTheme`, `listTileTheme`, …), built from colour roles, the type scale
  and shape tokens.
- Feature widgets pick a **variant** (`FilledButton.tonal`, `Card.outlined`), never a one-off `style:`
  that re-specifies colour, radius or text. A recurring variant the theme lacks goes into the theme or
  a `core/widgets` component — not copy-pasted.
- Both `light` and `dark` `ThemeData` share one builder, so every component theme exists in both.

## 11. Accessibility and content
- Every icon-only control has a `tooltip` or `Semantics` label. Decorative images are excluded from
  semantics.
- Logical focus and reading order; don't rely on position or colour alone.
- **Content:** sentence case for buttons, labels, titles and menu items; buttons start with a verb
  ("Save changes", not "OK" where a specific action is meant); error text says what happened and how to
  fix it; empty states explain and offer the next action.

## 12. Review checklist
Colours from roles, paired with `on*` · type from roles, no raw sizes · radii from the shape scale ·
elevation by tone · states handled (hover/focus/pressed/disabled) · motion from `Durations`/`Easing`,
reduced motion respected · 48 dp targets · layout checked on compact and expanded · M3 component used
where one exists · no deprecated widget in new code · contrast checked in light and dark · text scaling
checked · labels and tooltips present.

> M3 Expressive (2025) components and tokens are adopted only once they ship in stable Flutter, and
> then as a recorded decision.
