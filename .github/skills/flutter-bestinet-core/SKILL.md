---
name: flutter-bestinet-core
description: >-
  BESTINET Flutter core rules: Material 3 theming/typography/components plus layered MVVM,
  Riverpod + Freezed, GenericApiService/ApiException, UiEffect and AppRoute/PageRouter navigation.
  Use for any screen, widget, route, API call, repository, provider, theme, dark mode, localization
  or "where does this file go" question in this codebase.
---

# BESTINET Flutter Core — M3 Design × Riverpod Architecture

**Precedence.** This skill, together with the other skills in this pack, is the complete and
portable source of truth — it does not depend on any project-local docs folder. Where it and the
shipping code disagree on a wiring detail, mirror the code and record the divergence; never run two
design systems or two routers in parallel. Don't guess:
- a **portable** rule change (applies to every BESTINET app) is made in `flutter-template/skills/`,
  recorded in `flutter-template/DECISIONS.md`, then regenerated with `flutter-template/bin/apply-template.sh`;
- a **project-only** deviation is recorded in the project's `READMEFIRST/` notes (`readmefirst` skill).

**Scope note.** This skill supersedes `flutter-bestinet-skill`, `flutter-bestinet-super-designer`,
and `flutter-reference-app`. Narrow concerns live in separate skills that trigger on their own:
testing (`flutter-add-widget-test`, `flutter-add-integration-test`, `flutter-add-widget-preview`),
layout debugging (`flutter-fix-layout-issues`, `flutter-build-responsive-layout`), and Dart style
(`dart-use-pattern-matching`, `dart-use-primary-constructors`, `dart-write-documentation`).
**Where those upstream Flutter skills conflict with this one — they use `ChangeNotifier`,
`provider`/`get_it`, the raw `http` package, and manual `fromJson` — this skill wins.** Use them
only for the gaps they fill.

---

## 0. Read first — response rules
- Be concise. No lengthy explanations unless asked. No boilerplate comments in code.
- Code first, brief explanation after. Skip tutorials — assume Flutter/Riverpod/layered-MVVM fluency.
- Minimal, targeted diffs: show the touched function/file, not a full-file dump, unless asked.
- One file or function at a time unless asked to do more.
- Override brevity only when asked for a full/detailed explanation.

## 1. Role & model routing

You are simultaneously a **Flutter UI/UX designer** who applies M3 correctly and a **senior Flutter
engineer** who enforces the Playbook. Every output must be visually correct (M3 tokens, typography,
shape, elevation, color roles), architecturally correct (Riverpod + Freezed, layered MVVM,
`ApiException`, `UiEffect`), and production-ready — **all hex lives only in the theme definition
layer**.

M3 principles: Personal, Adaptive, Expressive, Accessible (WCAG 2.1 AA minimum, verified in **both**
light and dark). Decision hierarchy: semantic intent → M3 token (ColorScheme role / TextTheme role /
shape) → M3 component → Flutter widget → BESTINET-correct code.

| Task | Model |
|---|---|
| New feature, new screen, new module, greenfield code | **Claude Opus 4.8** |
| Editing, fixing, refactoring existing code | **Claude Sonnet 4.6** |
| Ambiguous (new behavior in existing files) | Default **Sonnet 4.6**; escalate to Opus only if the change spans multiple layers/files |

A skill file can't force a model switch — this documents the rule; whoever drives the session still
picks the model. State which model a task calls for if it isn't obvious.

## 2. Three pillars + four layers

```
lib/
├── core/       # generic engine — project-agnostic, copy-pastable. MUST NOT import modules/ or app/.
├── modules/    # functional verticals — self-contained, own data/+presentation/
│               #   (+optional domain/, application/). MUST NOT import each other's internals.
└── app/        # composition root — router, provider wiring, AppStorage/SecureAppStorage,
                #   localization/. main.dart bootstraps into this (main_dev/main_prod).
```

Feature modules live under `lib/modules/features/` or `lib/modules/common/` (§3) — the canonical
location for business code. Mirror surrounding code.

| Layer | Owns | MUST NOT |
|---|---|---|
| **Presentation** | Widgets, ViewModels (`@riverpod` Notifiers), Freezed state | hold `BuildContext`/`Navigator`; HTTP/JSON; touch Dio/secure storage |
| **Application** *(optional)* | Services/managers spanning >1 repo (e.g. `SessionManager`) | UI logic/widget refs; depend on Presentation |
| **Domain** *(optional)* | Pure entities | depend on any other layer; know JSON |
| **Data** | DTOs (`data/models/`), Repositories | return `dynamic`/raw JSON to VM; reference UI |

`domain/` holds the repository interface, so any module with a repository has one (§3). Add
`application/` only for logic that spans >1 repository, a workflow reused across screens, session/auth
steps, or bootstrap/sync policy — never for pass-through wrappers around one repository call. Dependency law: **`Presentation → Application → Data → Core`** (Domain optional
inward target). Promotion path for shared code: feature-local → `app/` → `core/` (only if
project-agnostic).

### Forbidden (PR-rejection) patterns
1. Fat Widget — I/O, validation, state transitions in `build()`/`onTap`.
2. Leaky network — raw `DioException`/`dynamic`/`Map` crossing to VM/UI; `developerMessage` shown to users.
3. ViewModel-driven navigation — VM calling `Navigator`/`PageRouter`/`showDialog`.
4. Insecure persistence — tokens in SharedPreferences/`LocalStorage`.
5. Manual DI — hand-written providers/direct instantiation (all DI via `@riverpod` codegen).
6. Cross-feature imports; feature/business logic inside `core/`.
7. Silent error swallowing — `catch (e) {}` without updating state.
8. Hand-edited `*.g.dart`/`*.freezed.dart`.
9. Hardcoded color/typography in `lib/modules/` — see §8.

## 3. Folder structure & naming

```
project root/
├── assets/icons/       # monochrome SVGs (declared under flutter: assets: in pubspec.yaml)
└── lib/
    ├── app/{localization,navigation,providers,storage,ui/ui_effect}/
    ├── core/{generators,localization,logging,network{,/interfaces,/implementations,
    │         /interceptors},providers,session,storage,services,theme{,/extensions},
    │         utils{,/side_effects/ui_effect},widgets{buttons,common,dialogs,layouts}}/
    ├── modules/
    │   ├── features/<module>/   # user-facing verticals — own screens and flows
    │   │     {data{models/,repositories/},domain{repositories/,entities?},
    │   │      presentation{widgets/},application?}/
    │   └── common/<module>/     # shared data consumed by >1 feature — usually no presentation/
    │         {data{models/,repositories/},domain{repositories/}}/
    └── main.dart (+ main_dev.dart / main_prod.dart)
```

### The two module buckets
`lib/modules/` has **two homes**, and picking the right one is the rule:

| Bucket | For | Precedent |
|---|---|---|
| `modules/features/<m>/` | a user-facing vertical with its own screens, views and ViewModels | e.g. `order_listing`, `profile` |
| `modules/common/<m>/` | data other modules consume — lookups, reference data, identity; usually no `presentation/` | e.g. `reference_data`, `identity` |

Default to `features/`. Promote to `common/` only once a **second** module needs the same data —
promotion is cheap, and a premature `common/` entry invites unrelated things to pile into it.

### Repositories come in a pair
A repository is **two files**:

| File | Holds |
|---|---|
| `domain/repositories/<m>_repository.dart` | the abstract interface — method signatures only, no implementation, no JSON |
| `data/repositories/<m>_repository_impl.dart` | the concrete `…Impl` — HTTP-blind, takes a `GenericApiService` by constructor, returns typed DTOs via an explicit decoder |

Consumers (ViewModels, other repositories) depend on the **abstract** type, never on `…Impl`. So
`domain/` is **not optional** for a module that has a repository — it holds that interface. `domain/`
may also hold pure entities, but the interface is its primary tenant.

> `assets/` sits at the **project root**, not under `lib/` — per Flutter convention.

| Adding… | Goes in… |
|---|---|
| Color/typography/spacing/icon token | `core/theme/` (`app_colors.dart`, `app_theme.dart`, `app_typography.dart`, `app_icons.dart`, `constant.dart`, `extensions/`) |
| Project-agnostic reusable widget | `core/widgets/{buttons,common,dialogs,layouts}/` |
| Pure helper/validator | `core/utils/` |
| Network core (transport/service/response/exception) | `core/network/` (+`implementations/`) |
| Locale key map | `app/localization/localization_keys/<locale>.dart` |
| Route definitions | `app/navigation/application/router.dart` (`AppRoute` enum + `PageRouter`) |
| App-wide provider wiring | `app/providers/providers.dart` |
| DTO for module X | `modules/<bucket>/X/data/models/<n>_model.dart` |
| Repository interface for module X | `modules/<bucket>/X/domain/repositories/<n>_repository.dart` |
| Repository implementation for module X | `modules/<bucket>/X/data/repositories/<n>_repository_impl.dart` |
| Screen (state+view+VM) for module X | `modules/features/X/presentation/` |
| Repository, service or app-wide provider | `lib/app/providers/providers.dart` (see §4) |
| Copyable core infra provider (storage, `Dio`, transport) | `lib/core/providers/providers.dart` (see §4) |

Naming: files `lower_snake_case.dart` (`<f>_view.dart`, `_viewmodel.dart`, `_state.dart`,
`_repository.dart`, `<n>_model.dart` (DTO), `<n>_manager.dart` — never PascalCase filenames). Classes
PascalCase + role suffix (`LoginViewModel`, `ContactModel`); providers `<n>Provider`. `part` directives
must match filename exactly. Folders `lower_snake_case`; root pillars exactly `lib/core`,
`lib/modules`, `lib/app`.

## 4. State management — Riverpod + Freezed

Flow: `UI → ViewModel → (Application) → Repository → Domain models`. Mandated: Riverpod
**codegen variant only** + Freezed. No side effects in `build()` — trigger loads from UI/init method.

| Provider type | Use |
|---|---|
| `@riverpod` function (autoDispose, default) | Stateless deps — repos, services |
| `@riverpod class` (Notifier) | ViewModel over multi-field Freezed state |
| `AsyncNotifier` | Simple single future/stream async |
| `@Riverpod(keepAlive: true)` | Long-lived infra only — session, config/env, theme, locale, storage, `Dio` clients, bootstrappers. Chosen deliberately, never by reflex; still release resources in `ref.onDispose` |

**Scope — providers are centralized in two files.** Copyable core infrastructure providers (storage,
persistence, crypto, `Dio`, transports) live in `lib/core/providers/providers.dart`; repository,
service and app-wide providers live in `lib/app/providers/providers.dart`. Never beside the class they
construct and never in a per-module `providers/` folder. One file is the DI registry; a new repository adds a line to it. This
trades module self-containment for a single readable list of everything the app wires — and it keeps
the `apiServiceProvider` / `systemApiServiceProvider` choice (§6) visible in one place rather than
scattered. ViewModel providers are the exception, and only because they aren't hand-written:
`@riverpod` on the Notifier generates them.

**ViewModel purity — MUST NOT**: hold/reference `BuildContext`; call `Navigator`/`PageRouter`/import
routing; show dialogs/snackbars/`ScaffoldMessenger`; raw HTTP/JSON; touch Dio/secure storage; emit
`developerMessage` to UI. Widget is a passive observer — no business flags in local `StatefulWidget`
state.

```dart
@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    @Default(false) bool isLoading,
    @Default('') String errorMessage,     // user-facing only, from ApiException.message.userMessage
    @Default([]) List<Contact> contacts,
  }) = _ContactsState;
}

@riverpod
class ContactsViewModel extends _$ContactsViewModel {
  @override
  ContactsState build() => const ContactsState();     // no side effects here

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');       // atomic, before I/O
    try {
      final contacts = await ref.read(contactsRepositoryProvider).getContacts();
      state = state.copyWith(isLoading: false, contacts: contacts);  // atomic success
    } on ApiException catch (e) {
      GlobalLogger().logMessage(e.message.developerMessage, level: GlobalLogLevel.error);
      state = state.copyWith(isLoading: false, errorMessage: e.message.userMessage);
    }
  }
}
```

Rules: every transition via `copyWith` (never mutate in place / torn state); `isLoading:false` set in
**both** success and error paths; `@Default(...)` on collections; empty success = empty list, not an
error. Union/sealed `.when()` states only for mutually-exclusive modes where data needn't persist
across the transition. ❌ torn state, ❌ nav-bool in state, ❌ one-shot effects in state.

Codegen: `dart run build_runner build --delete-conflicting-outputs`; `watch` during active dev.
Re-run after any `@riverpod`/`@freezed`/state-shape change — never hand-edit generated files.

## 5. One-shot effects — `UiEffect`

One-shot effects (snackbars, dialogs, navigation) are never stored in state — they'd replay on
rebuild. Emitted on a stream **after** state stabilizes (`isLoading:false` first), consumed by the UI.

`UiEffect { String id; Object scenario; UiFeedback? feedback; UiAction? action; }` — `scenario` is an
enum **or** a String scenario-constant; never branch UI on it. `UiFeedback`: dialog/snackBar/toast.
`UiAction`: `none / navigate / pop / doublePop / custom`. Deduped **globally/statically** by `id` via
`UiEffectRunner`. **UI performs it, the VM only emits.** Subscribe via `listenUiEffects`
(ConsumerStatefulWidget) / `bindUiEffects` (ConsumerWidget). Models at
`lib/core/utils/side_effects/ui_effect/`, runner/listener at `lib/app/ui/ui_effect/`.

**A `UiEffect` navigate action is the only legal VM-initiated navigation trigger.** ❌ The VM never
calls `Navigator`, `PageRouter`, or `showDialog`. Build effects with `UiEffect.create(...)` (never pass
`id`). For one error, use persistent state **or** a transient effect — not both.

**Full contract** — model API, scenarios, custom actions, VM stream wiring, listener lifecycle, why
dedup is global: `references/ui-effect.md`. Open it before wiring effects.

## 6. Networking

Repositories are **HTTP-blind** — all traffic through `GenericApiService`'s verb helpers with an
explicit `decoder`/`listDecoder`, delegating to the `ApiTransport` interface. MUST NOT import `Dio`
outside `core/network/implementations/` or `app/network/`.

- **`ApiTransport`** (interface, `core/network/`) — HTTP verbs; concrete impls inject tokens, run
  401 refresh-retry, normalize to `ApiException`, parse into `SingleResponse<T>`/`ListResponse<T>`.
- **`GenericApiService`** — single repo entry point, one helper per verb and shape:
  `get/post/put/delete<T>` (take `decoder: T Function(dynamic)`, return `SingleResponse<T>`) and
  `getList/postList/putList/deleteList<T>` (take `listDecoder: List<T> Function(List<dynamic>)`,
  return `ListResponse<T>`). Each takes `path`, optional `query`/`body`/`headers`, and an
  `ApiRequestConfig config` for per-request differences (base-URL override, gateway toggle) — never
  feature booleans. Delegates to `ApiTransport`; never returns raw `Map`/`dynamic`.
- **Responses** — `SingleResponse<T> {status, data, message}`, `ListResponse<T> {status, items,
  pagination (PaginationMeta?), message}`, `ApiMessage {userMessage, developerMessage}`.
- **`ApiException`** — the only error crossing layer boundaries: `{status?, ApiMessage(userMessage,
  developerMessage), code?}`. Raw `DioException` MUST NOT escape the transport.
- **`SessionAccessor`** (interface) — `getAccessToken()`, `refreshAccessToken()` (serialized),
  `clear(reason:)`. Concrete impl **`SessionManager`**. Knows nothing about UI/navigation/persistence.
- **Two API service providers — pick deliberately.** A repository implementation is constructed with
  one of:

  | Provider | Auth | Use for |
  |---|---|---|
  | `apiServiceProvider` | the signed-in user's bearer token | anything behind login — the default |
  | `systemApiServiceProvider` | client credentials, no user session | data needed **before** login: reference data, lookups, config |

  Getting this wrong fails at runtime, not compile time, and only on the pre-login path — a
  reference-data repository wired to `apiServiceProvider` looks fine until a cold start hits it
  before authentication. Ask "does this load before the user signs in?" when declaring the provider.
- **`DioTransport`** — primary concrete `ApiTransport`, wraps `Dio`; interceptors inject `Bearer`
  token and log via `GlobalLogger` (redacted). `AuthRepository` alone uses a session-free
  `authApiServiceProvider`/`AuthDioTransport` pipeline; other repos use the session-aware one.

```dart
final resp = await _api.getList<ContactModel>(
  path: '/contacts',
  query: {'page': page, 'size': size},
  listDecoder: (list) => list.map((e) => ContactModel.fromJson(e as Map<String, dynamic>)).toList(),
);
return resp.items;   // safe — the transport throws ApiException on any failure

final one = await _api.get<ContactModel>(
  path: '/contacts/$id',
  decoder: (json) => ContactModel.fromJson(json as Map<String, dynamic>),
);
return one.data;
```

Repos: `try { ... } on ApiException { rethrow; }` (may enrich, must rethrow — never swallow).

**401 flow (infra-owned, autonomous)**: inject Bearer → execute → on 401 intercept → single-flight
`refreshAccessToken()` → retry once → on failure `clear()` + throw canonical `ApiException`
(`AUTH_REFRESH_FAILED`). Logout is deterministic, not in the transport: `SessionManager.clear()`
flips `SessionState` → the app shell observes it and resets the stack to `/` via the global tier
(`PageRouter.pushNamedAndRemoveUntilGlobal(AppRoute.root)`); `AppEntry` then renders
Splash/Login/Landing from `SessionState` (§7).
*"401 recovery is automatic. Logout is deterministic. Features remain unaware."*

**Error propagation chain**: Transport (normalize) → Service (transparent conduit) → Repository
(rethrow, may enrich) → ViewModel (catch `ApiException`, log `developerMessage`, map `userMessage`
to `state.errorMessage` or a `UiEffect` error feedback, clear `isLoading`). No empty catches, no
log-only, no defaulting to success on error.

## 7. Navigation — `AppRoute` + `PageRouter`

`PageRouter` (`lib/app/navigation/application/router.dart`) is the **single routing authority** and
the only place navigation lives, built on native `Navigator`. There is no `AppNavigator` facade, no
`AppRoutes` string class, and no `lib/core/routing/` — don't introduce them. **GoRouter is not
used.** Rationale: `flutter-template/DECISIONS.md` → navigation entry.

- **`AppRoute` enum** — each value carries a unique `path` (`login('/login')`). Never hardcode a
  route string at a call site; always reference `AppRoute`.
- **`PageRouter.generateRoute(RouteSettings)`** — static dispatcher matching `settings.name` against
  `AppRoute.values`, casting `settings.arguments` to the expected type, returning `MaterialPageRoute`.
  Wired to `MaterialApp.onGenerateRoute`. **MUST NOT** contain business logic, state mutation, or
  data fetching — it maps and extracts, nothing else.
- Navigation is initiated **only from Presentation**.
- `generateRoute` always has an unknown-route fallback (a fixed `AppRoute`, e.g. `root`) — never null.
- Deep links (`app_links`) and push taps enter through the global tier and the app shell, which
  checks auth state, bootstrap readiness and required arguments before routing, with a safe fallback.

### The two tiers — picking the right one is the rule

| Tier | Helpers | Use from |
|---|---|---|
| **Context** | `pushNamedEnum(context, route)`, `pushNamedString(context, route)`, `pushReplacementNamedEnum`, `pushReplacementNamedString`, `pushNamedEnumAndRemoveUntil`, `pushNamedStringAndRemoveUntil` | inside the widget tree |
| **Global** | `pushNamedGlobal`, `pushReplacementNamedGlobal`, `pushNamedAndRemoveUntilGlobal`, `popGlobal`, `popUntilRootGlobal` | outside it — services, push-notification taps, deep links, app-shell |

Plain back-navigation from a widget is `Navigator.of(context).pop()`, **not** a `PageRouter` call.
All helpers take `{Object? arguments}` — deliberately wider than the reference's
`Map<String, dynamic>?`, so typed payloads (`NotificationDto`, `PdfViewerArgs`) survive; a map still
compiles.

### Three approved entry points
```dart
// A. Direct UI interaction — context tier
onPressed: () {
  PageRouter.pushNamedEnum(context, AppRoute.orderListing);
  // with arguments:
  // PageRouter.pushNamedEnum(context, AppRoute.pdfViewer, arguments: pdfArgs);
}
// back:
Navigator.of(context).pop();

// B. App-shell / infrastructure reacting to global state — global tier
PageRouter.pushNamedAndRemoveUntilGlobal(AppRoute.root);   // push + clear stack
PageRouter.pushNamedGlobal(AppRoute.notifications);        // e.g. push-notification tap

// C. ViewModel-driven — via UiEffect only (§5). The VM emits; the UI performs.
UiEffect.create(
  scenario: ...,
  action: UiAction.navigate(
    command: NavCommand.pushNamed(route: AppRoute.orderDetails.path),
  ),
);
```
`UiEffectRunner` navigates on the **context tier** (it receives the view's context) and pops with
`Navigator.of(context)`; only the dialog/snackbar surfaces, which own no context, use `popGlobal`.
`NavCommand` variants: `pushNamed` / `pushReplacementNamed` / `pushNamedAndRemoveUntil`.

> `const` does not work on a `NavCommand` carrying `AppRoute.x.path` — it is not a constant expression.

### Argument handling
Extract and cast arguments **inside `generateRoute` only**, then inject into the screen constructor:
```dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  if (settings.name == AppRoute.contactDetails.path) {
    final dto = settings.arguments as ContactDto;
    return MaterialPageRoute(builder: (_) => ContactDetailsView(contact: dto));
  }
  // …
}
```

## 8. M3 theming — everything comes from `context`

**M3 is the production model, not a migration target.** Every module under `lib/modules/` is on
role-based theming, verified light + dark. New code follows this section directly.

**Full M3 contract** — every colour role, the type scale with line heights, shape scale, elevation
levels, state layers, motion tokens, window size classes, canonical layouts, the component catalogue
(and what replaces deprecated widgets), component theming, accessibility and content rules, and a
review checklist: `references/m3-design.md`. Open it before designing a screen or building a widget.

```dart
// ✅ CORRECT
color: Theme.of(context).colorScheme.primary
color: Theme.of(context).colorScheme.onSurfaceVariant
style: Theme.of(context).textTheme.titleLarge
color: context.appColors.success            // semantic extension (8.3)

// ❌ FORBIDDEN in lib/modules/
color: AppColors.primary
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)
color: Color(0xFF336699)
```

### 8.1 Colors → `ColorScheme` roles
Standard roles cover the palette: `primary/onPrimary/primaryContainer/onPrimaryContainer`,
`secondary…`, `tertiary…`, `error…`, `surface/onSurface`, `surfaceContainerLow…Highest`,
`outline/outlineVariant`, `inverseSurface/onInverseSurface/inversePrimary`. Always pair a color with
its `on*` foreground. **`surfaceVariant` is deprecated → use `surfaceContainerHighest`.**
For dark mode, don't trust `fromSeed` tones blindly — pin the brand roles you care about, check AA
contrast, and supply explicit role overrides where the generated tone drifts off-brand.

### 8.2 `AppColors` is the theme's INPUT, not a widget API
`lib/core/theme/app_colors.dart` stays, but is never read inside widgets. It supplies the seed +
pinned brand roles for `ColorScheme`, and the source values for the semantic `ThemeExtension` (8.3).
Those stay as named constants, consumed by the theme, surfaced to widgets via `context`.

**Strict M3 — no off-scheme brand assets.** M3 has no gradient role, so a "brand gradient" becomes a
solid role: `primary` + `onPrimary` for a brand header or hero button. Always-dark and over-media
surfaces use roles too, never fixed colours:

| Surface | Roles |
|---|---|
| Full-screen camera / video / media viewer | wrap in `Theme(data: AppTheme.dark)`; `scrim` background and dimming, `onSurface` / `onSurfaceVariant` text |
| Dimming layer over content or a preview | `scrim.withValues(alpha: …)` |
| Hint pill / toast over a preview | `inverseSurface` + `onInverseSurface` (the M3 snackbar pair) |

The only fixed colours outside the theme are third-party sign-in brand colours via `BrandColors`
(Google/Apple guidelines mandate them).

### 8.3 Semantic colors M3 lacks → one `ThemeExtension`
`success / onSuccess / successContainer`, `warning…`, `info…` are not M3 roles. Expose them through a
**single** `AppColorsExtension : ThemeExtension` registered in both light and dark `ThemeData`,
accessed as `context.appColors.success`. Seed from existing `AppColors` session tokens — **reference
the constants, don't duplicate hex**. This is the only sanctioned extension; don't spawn parallel ones.

### 8.4 Typography → one central custom `TextTheme`
Font family is **`Inter`** (bundled in `pubspec.yaml`), **not `Roboto`** — set once in the `TextTheme`
builder so it can't drift. M3 type-scale sizes: display 57/45/36 · headline 32/28/24 · title 22/16/14
· body 16/14/12 · label 14/12/11 — with M3 line heights (`height: lineHeight / fontSize`), weights
and letter-spacing per the table in `references/m3-design.md` §3. Widgets consume
`Theme.of(context).textTheme.<role>` — never hardcode `fontSize`.

```dart
// lib/core/theme/app_typography.dart — single source; wired into ThemeData.textTheme
static TextTheme build() => const TextTheme(
  displayLarge:  TextStyle(fontFamily: 'Inter', fontSize: 57, height: 64 / 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
  headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w400),
  titleLarge:    TextStyle(fontFamily: 'Inter', fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w400),
  titleMedium:   TextStyle(fontFamily: 'Inter', fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  bodyLarge:     TextStyle(fontFamily: 'Inter', fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
  bodyMedium:    TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
  labelLarge:    TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  // …fill the remaining roles
);
```

### 8.5 Shape, spacing, elevation
Non-color tokens (radii, spacing, elevation) live in `lib/core/theme/constant.dart` as `Constants.*`,
or in a `ThemeExtension` if they must be theme-aware. Shape scale: extraSmall 4 · small 8 · medium 12
· large 16 · extraLarge 28 · full (pill), applied through component themes (cards 12, dialogs and
bottom sheets 28, buttons pill). 4 dp spacing grid 4/8/12/16/24/32/48. No magic numbers in widgets.
**Elevation:** levels 0–5 = 0/1/3/6/8/12 dp, expressed by tone — a raised surface takes a higher
`surfaceContainer*` step; shadows only where an element must separate from busy content.

### 8.5a States and motion
- Interactive elements show M3 state layers (hover 8%, focus 10%, pressed 10%, dragged 16%) and the
  disabled treatment (content 38%, container 12% of `onSurface`). Built-in components do this; custom
  tappables use `Material` + `InkWell` or `WidgetStateProperty` — never a bare `GestureDetector`.
- Motion uses Flutter's `Durations.*` (short 50–200, medium 250–400, long 450–600 ms) and `Easing.*`
  (`emphasizedDecelerate` in, `emphasizedAccelerate` out, `standard` for small changes). No magic
  durations or `Curves.linear`. Respect `MediaQuery.disableAnimationsOf(context)`.

### 8.6 Master theme (light + dark, brand-seeded)
Build both brightnesses from the **project's brand primary** — `AppColors.primary`, whose hex is
defined once in `lib/core/theme/app_colors.dart` and nowhere else — pinned, **never** the M3 sample
purple `0xFF6750A4`. The brand value is per project; this skill never hardcodes it.

```dart
// lib/core/theme/app_theme.dart
static ThemeData _build(Brightness b, AppColorsExtension ext) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,                 // ✅ brand seed (both brightnesses)
    primary: AppColors.primary,                   // ✅ pin brand; pin more roles as needed
    brightness: b,
  ),
  textTheme: AppTypography.build(),               // ✅ central TextTheme
  fontFamily: 'Inter',
  extensions: [ext],                              // ✅ semantic colors, light/dark variant
  // appBarTheme / inputDecorationTheme / navigationBarTheme … from role tokens
);
static ThemeData get light => _build(Brightness.light, AppColorsExtension.light);
static ThemeData get dark  => _build(Brightness.dark,  AppColorsExtension.dark);
```

### 8.7 Iconography (SVG via `flutter_svg`)
Icons are **monochrome SVG assets recolored at runtime** via `BlendMode.srcIn`, so they follow the
theme like any role color. Source set: **Eva Icons** (MIT), the library behind the UI team's Phoenix
Figma template. SVGs must be monochrome (single fill, no stroke/gradient/clip) for `srcIn` to work.

- **Assets:** `assets/icons/*.svg` at the project root; declare `assets/icons/` under
  `flutter: assets:` in `pubspec.yaml`.
- **Central path registry** — `lib/core/theme/app_icons.dart`:
  ```dart
  abstract final class AppIcons {
    static const String home = 'assets/icons/home.svg';
    static const String notification = 'assets/icons/notification.svg';
    static const String arrowBack = 'assets/icons/arrow_back.svg';
  }
  ```
- **Reusable widget** — `lib/core/widgets/common/app_svg_icon.dart`, theme-aware by default:
  ```dart
  class AppSvgIcon extends StatelessWidget {
    const AppSvgIcon(this.assetName, {super.key, this.size = 24, this.color, this.semanticLabel});
    final String assetName; final double size; final Color? color; final String? semanticLabel;
    @override
    Widget build(BuildContext context) {
      final resolved = color ?? IconTheme.of(context).color;   // ✅ theme-aware default
      return SvgPicture.asset(
        assetName, width: size, height: size, semanticsLabel: semanticLabel,
        colorFilter: resolved == null ? null : ColorFilter.mode(resolved, BlendMode.srcIn),
      );
    }
  }
  ```
- **Laws:** never hardcode an icon asset path in a widget — reference `AppIcons`; size from
  `Constants.*`; `flutter_svg` is already a dependency (don't add another SVG package).

## 9. M3 components & adaptive layout
Full component catalogue with the widget to use for each need: `references/m3-design.md` §9. Style
components once via `ThemeData` component themes in `core/theme/app_theme.dart`; feature widgets pick
a variant (`FilledButton.tonal`, `Card.outlined`), never a one-off `style:`.

- **Buttons (one per hierarchy level):** `FilledButton` (primary, ≤1/screen), `FilledTonalButton`
  (important secondary), `OutlinedButton` (secondary), `TextButton` (tertiary/dialogs), `IconButton`,
  `FloatingActionButton` (≤1/screen); `ElevatedButton` sparingly.
- **Cards:** elevated (default), filled (`surfaceContainerHighest`, **not** `surfaceVariant`),
  outlined (`outlineVariant`).
- **Navigation:** `NavigationBar` (mobile 3–5), `NavigationRail` (tablet/landscape),
  `NavigationDrawer` (desktop), `TabBar` (secondary). *Where a project still has
  `BottomNavigationBar`, migrate to `NavigationBar` as a deliberate task, not incidentally.*
- **Icons:** outlined = unselected, filled = selected; size 18/20/24/48; color from a role token.
- **Text scaling:** respect the system font-size setting — never clamp `TextScaler` to 1.0 globally;
  check key screens at large text sizes.
- **Touch targets:** minimum 48 × 48 dp, 8 dp apart; icon-only controls carry a `tooltip`.
- **Deprecated in new code:** `ToggleButtons` → `SegmentedButton`; `PopupMenuButton`/`DropdownButton` →
  `MenuAnchor`/`DropdownMenu`; `ButtonBar` → `OverflowBar`; `MaterialStateProperty` →
  `WidgetStateProperty`; `background` → `surface`.
- **Window size classes:** compact < 600 · medium 600–839 · expanded 840–1199 · large 1200–1599 ·
  extra-large ≥ 1600. Margins 16 on compact, 24 above. Canonical layouts: list-detail, supporting
  pane, feed. For layout construction and
  overflow/constraint debugging, the `flutter-build-responsive-layout` and `flutter-fix-layout-issues`
  skills apply.

## 10. Storage & localization
- **Storage (two-tier):** core `SecurePersistenceInterface`/`SharedPersistenceInterface` (impls
  `FssSecurePersistence`/`SPrefSharedPersistence`); composed into core-internal `AuthStorage` (secure
  tokens, used only by `SessionManager`) and `LocalStorage` (prefs). Feature code consumes
  **`AppStorage`** (non-sensitive) / **`SecureAppStorage`** (sensitive) from `app/` only — never the
  core interfaces or `AuthStorage`/`LocalStorage` directly. Tokens only in secure storage.
- **Localization:** `LocaleNotifier` (`@riverpod`, keepAlive) is source of truth, persists to
  `LocalStorage`; key maps in `app/localization/localization_keys/<locale>.dart` (`lower_snake_case` keys,
  registered in `LocalizationsRegistry` before `runApp()`); resolve via `ref.t('key')`. No inline
  user-facing strings; missing key returns the key itself (never crashes). The design half obeys this
  too — no hardcoded labels in widgets.

## 11. Infrastructure
- **Logging:** `GlobalLogger` only (no `print`); log `developerMessage` + stack traces; never log
  PII, tokens, or full HTTP bodies; never use the logger for user-facing strings.
- **Bootstrap** (`main.dart`, orchestration only): `ensureInitialized()` → register localization
  before `runApp()` → build a `ProviderContainer` to preload async deps → `runApp` in
  `ProviderScope`/`UncontrolledProviderScope`. Flavors (`main_dev.dart`/`main_prod.dart`) set base
  URL/env then delegate to shared bootstrap.

## 12. Dependencies (architecture-critical)

| Concern | Package |
|---|---|
| State mgmt | `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator` (codegen) |
| Immutable state | `freezed_annotation`/`freezed` |
| JSON | `json_annotation`/`json_serializable` |
| Networking | `dio` (wrapped by `DioTransport` behind `ApiTransport`) |
| Vector icons | `flutter_svg` |
| Secure storage | `flutter_secure_storage` |
| Prefs storage | `shared_preferences` |
| Logging | `logging` (wrapped by `GlobalLogger`) |
| Token parsing | `jwt_decoder` |
| Lints | `flutter_lints` + `riverpod_lint` — 3.x is an analyzer plugin (top-level `plugins: riverpod_lint: ^3.x` in `analysis_options.yaml`), **not** `custom_lint` |
| Deep links | `app_links` (routed through `PageRouter`'s global tier) |

Plus Firebase, auth (google/apple sign-in), media/AV, ML, and platform packages already in
`pubspec.yaml` — prefer the package already chosen for a concern over introducing an alternative.

**Public-template divergence:** this skill descends from the public FlutterReferenceApp
(github.com/nadeeshac32/FlutterReferenceApp) — same four layers, Riverpod MVVM with codegen,
`AuthSessionManager`-style session, reporter/captor analytics, chainable validators, `FlavorConfig`
flavors. It uses `http`+`http_interceptor`, `go_router`, per-feature `providers/`, and no Freezed.
**BESTINET apps do not** — it uses `dio`/`ApiTransport`,
`AppRoute`+`PageRouter`, and `freezed`. Follow this skill, not that README, wherever they differ.

## 13. Legacy vocabulary in older BESTINET code — map before reusing

Older naming that predates the canonical vocabulary. Same *concept*, current class names — reuse them
when touching that code, write *new* code against the canonical names in §6/§7/§10:

| You may see in current code | Canonical equivalent |
|---|---|
| `AuthSessionManager` (`features/authentication/application/session/`) | `SessionManager` implementing `SessionAccessor` |
| `NetworkClient` / `NetworkService` (+`AuthInterceptor`, `ExpiredTokenRetryPolicy`) | `ApiTransport`/`GenericApiService`, concretely `DioTransport` |
| Auth client (`postSignInRequest`, `postRefreshTokenRequest`, …) | `AuthRepository` via the session-free `authApiServiceProvider`/`AuthDioTransport` |
| `AppNavigator.push/go/replace/pushResult` facade | **Not used** — use the `PageRouter` tiers (§7) |
| `AppRoutes` string-constant class | **Not used** — `AppRoute` enum only |
| `RouteExtras` map builders / `lib/core/routing/` | **Not used** — pass typed `Object? arguments` |
| `rootNavigatorKey` shim | `PageRouter.navigatorKey` directly |
| `pushNamedEnum(route)` with no context | Context tier now takes `context`; context-free calls are the `…Global` helpers (§7) |
| `Validator` (`core/utils/validators/`) | Same — already canonical |
| `AuthStorage` / `LocalStorage` | Same — already canonical (but features use `AppStorage`/`SecureAppStorage`) |

## 14. Adding a feature — workflow
1. `lib/modules/features/<module>/` (or `common/<module>/` if >1 module consumes it) with `data/`
   + `presentation/`; add `application/` only when §2's criteria apply.
2. DTO `data/models/<n>_model.dart` (`@freezed`/json_serializable, `fromJson`).
3. Repository **pair** — interface `domain/repositories/<n>_repository.dart`, impl
   `data/repositories/<n>_repository_impl.dart` using the `GenericApiService` verb helper with an
   explicit decoder, rethrowing `ApiException`.
4. State `presentation/<feature>_state.dart` (`@freezed`, `isLoading`+`errorMessage`).
5. ViewModel `presentation/<feature>_viewmodel.dart` (`@riverpod`, pure).
6. View `presentation/<feature>_view.dart` — `ref.watch` state, `bindUiEffects`/`listenUiEffects`, `core/widgets/`, theme from `context`.
7. Provider — add the repository to `lib/app/providers/providers.dart`, choosing
   `apiServiceProvider` or `systemApiServiceProvider` (§6). VM provider is generated.
8. Navigation — add a value to `AppRoute`, a typed `PageRouter` helper, and the argument cast in
   `generateRoute`.
9. Localization — keys in `app/localization/localization_keys/`, register, use `ref.t()`.
10. Codegen — `build_runner build --delete-conflicting-outputs`.
11. Tests — repo (success+error) + VM (loading lifecycle + `copyWith`). See §16.

## 15. Non-negotiable laws & PR blockers

**Hard blockers:** `Navigator`/`PageRouter`/`showDialog`/`ScaffoldMessenger` in a Notifier ·
`BuildContext` below Presentation · repo returning `dynamic`/`Map` · `dio` imported outside
`core/network/implementations/` or `app/network/` · tokens in `SharedPreferences` · missing decoder
on a `GenericApiService` call · hand-edited `*.g.dart`/`*.freezed.dart` · `developerMessage` shown to users ·
cross-feature imports · feature logic in `core/` · hardcoded route path string at a call site.

**Design laws:** colors and text in feature widgets come from `context` — `colorScheme.*`,
`textTheme.*`, or `context.appColors.*`. No `AppColors.x`, `Color(0xFF…)`, `Colors.<name>`, or raw
`fontSize:` in `lib/modules/`. Hex/`ColorScheme`/`TextTheme` defined only in `lib/core/theme/` +
`main.dart`. The pack ships a portable theme guard: copy `scripts/theme_guard.dart` to
`tool/theme_guard.dart` and `scripts/theme_guard_test.dart` to `test/`, then run
`dart run tool/theme_guard.dart` (`just guard-theme` where a justfile exists). It is the **single**
enforcement path. It allows `Colors.transparent`, token font sizes (`fontSize: Constants.x`) and
non-Flutter import prefixes (e.g. `pw.TextStyle` for PDF export). **Fix a violation by moving to a role (8.2),
never by suppressing it.** `// m3-ignore: <reason>` (or `-begin`/`-end`/`-file`) is a last resort for
a value no role can express, and only with the user's agreement. Don't wire a `custom_lint` theme lint while the
app pins `freezed_annotation` below `^3.0.0` — every `custom_lint >= 0.7.4` requires it. Without a
guard, grep touched files for `AppColors.`, `Color(0x`, `Colors.` and `fontSize:`. Seed light **and**
dark from the project brand, never M3 purple. Font **Inter**, set once centrally. Semantic
success/warning/info via the single `AppColorsExtension` — no duplicate hex, no parallel extensions.
Verify every touched screen in light **and** dark, at large text scale, and against the review
checklist in `references/m3-design.md` §12.

**Self-review pass:** no `BuildContext` in VM → all network via `GenericApiService` → no cross-feature
imports → errors reach `errorMessage`/`UiEffect` → theme from `context` → generated files regenerated.

## 16. Testing & quality gates
Isolation absolute (no real network/storage in unit tests); prioritize ViewModel + Repository logic
over pixel-perfect widget tests. `ProviderContainer` + `overrides` is the DI tool for tests; prefer
hand-written `Fake`s, Mocktail for interaction verification. Every new feature ships: repo tests
(success+error via `FakeApiTransport`), VM tests (loading lifecycle + `copyWith` transitions), mock
DTO data. Test files mirror `lib/`, suffixed `_test.dart`. For widget/integration test mechanics see
the `flutter-add-widget-test` / `flutter-add-integration-test` skills.

**CI gates:** `dart analyze`/`flutter analyze` zero warnings — run **`dart analyze`**: `flutter analyze` and
`analyze <path>` skip analyzer plugins, so `riverpod_lint` findings appear only on a whole-project `dart analyze`;
suppress a plugin finding with the namespaced `// ignore: riverpod_lint/<rule>`; `dart format` compliant; all unit tests
pass; `build_runner` run in CI, fails on stale generated files; the theme guard, if the project has
one. Don't assume CI enforces a gate until you've seen it in the pipeline config — run the checks
locally regardless.

| Error | Cause | UX |
|---|---|---|
| Auth failure | 401 | transport refreshes; on failure, session cleared → stack reset to `/` |
| Forbidden | 403 | "Permission Denied" state, often blocking |
| Not found | 404 | empty/missing illustration |
| Server error | 500–599 | generic "Server is busy"; log diagnostics |
| Timeout/socket | network | inline "Connection error" + Retry |
| Parsing | decoder fail | generic "Unexpected error"; detail logged |

Recoverable (timeout, 404) → inline state + Retry. Fatal (403, critical 500, one-shot action failure,
terminal auth) → dialog (`CustomDialogAlert`).

### Validation commands
Prefer the project's own `justfile` recipes when it defines them (check `just --list`); otherwise use
the plain command.

| Change surface | Plain command |
|---|---|
| One area | `flutter analyze <path>` |
| Whole repo | `flutter analyze` |
| Riverpod/Freezed/json_serializable change | `dart run build_runner build --delete-conflicting-outputs` |
| Theme/design change | the project's theme guard if present, else the grep in §15 |
| Startup/auth/flavor change | launch every flavor entry point once, plus the related tests |
| Single test / full suite | `flutter test <path>` / `flutter test` |

Regeneration is required whenever a `@riverpod`/`@freezed`/`json_serializable` annotation, state
shape, or provider signature changes — assume it's needed, don't check if the file "looks" stale.

## 17. Known inconsistencies (reconciled — don't re-litigate)
- Layer-flow arrow written two ways (`…→Domain` vs `…→Core`) — Domain is an optional inward target,
  Core is the terminal infra edge.
- **Module layout, repository pair and provider scoping (§3, §4)** — older BESTINET spec text
  describes a flatter shape (`lib/modules/<m>/`, repos flat in `data/`, per-module provider files).
  The §3/§4 shape is authoritative; see `flutter-template/DECISIONS.md` (module layout entry).
- Older BESTINET text describes a single `call<T>(path, method, decoder)` returning `ServerResponse<T>`.
  The shipped surface is the verb helpers in §6 (`get`/`getList`/…); use those.
- **Navigation: `AppRoute`+`PageRouter`, two tiers (§7).** Settled — a context-free single tier was
  tried and reversed; don't reopen it. GoRouter is not used; if you find it wired up in code, that is
  stale, not a signal.
- **`assets/` is at the project root**, not under `lib/` (§3).

## 18. Bug-triage guardrails
Separate observations (what code/logs show) from hypotheses (your best guess) — don't present a
hypothesis as confirmed root cause. Never invent endpoints/DTO fields/routes not already in the
codebase. Flag regression risk explicitly when a fix crosses startup/auth/navigation/storage
boundaries.

## 19. Output contract
For any implementation/fix, state: which validation command(s) ran + result; whether codegen was
needed and run; any unresolved assumption or gap filled without confirmation; whether the touched
area has real test coverage or only the boilerplate `widget_test.dart`. For reviews: lead with
findings by severity; if none, say so and still note residual/untested risk.

## 20. Running the project
JDK 17 for Android; simulator API 35 max. `flutter clean && flutter pub get` on fresh checkout.

**iOS with Google ML Kit** (e.g. `google_mlkit_face_detection`): the minimum iOS version must be
**15.5** (set it in `ios/Podfile` *and* every `IPHONEOS_DEPLOYMENT_TARGET`, or `pod install` fails
for every iOS build). ML Kit ships no arm64 *simulator* slice, so **iOS 26 simulators on Apple
Silicon cannot link the app** (`Framework 'Pods_Runner' not found`) — use an iOS 18 simulator
under Rosetta, or put ML Kit behind a platform channel with Apple Vision on iOS. Physical iPhones
are unaffected. The ML Kit plugins also don't support Swift Package Manager yet, which Flutter warns
"will become an error".
Flavor names and entry points are per project — read them from the `justfile`/`READMEFIRST/` rather
than assuming: `flutter run --flavor <flavor> -t lib/main_<flavor>.dart`.

## 21. Reference files
This pack is self-contained — never point to a project-local docs folder for rules. Full detail for
this skill: `references/architecture-rules.md` (layers, placement, providers, networking, storage,
logging, theming policy, core widgets, error UX), `references/m3-design.md` (full Material 3
contract), `references/ui-effect.md` (UiEffect contract) and
`references/workflow.md` (planning from a PRD, build order, decision records, placeholders). Deeper
detail lives in sibling skills: `flutter-wire-generic-api-service` (networking), `flutter-mobile-security`
(storage, sessions, logging), `flutter-add-form-validation`, `flutter-add-paginated-list`,
`flutter-add-auth-screen`, `flutter-configure-flavors`, `flutter-setup-localization-bestinet`, and
the testing skills. Settled decisions and their rationale: `flutter-template/DECISIONS.md`.