# Architecture rules — full detail

`SKILL.md` is the summary. This file holds the rest of the BESTINET Playbook's rules, so the pack
works without any project-local docs folder. Section numbers match `SKILL.md`.

## §2 Layers and pillars
- **Domain** never knows where its data comes from (API, local storage, cache).
- Any class that depends on an infrastructure library (Dio, FlutterSecureStorage, a plugin) lives in
  `core/` or `app/`, never in `modules/`.
- **Features talk to each other only through `app/` or global providers**, never by direct import.
- `core/` stays stateless (exceptions: logger, theme state), uses generic names with no project
  prefix (`CustomButton`, not `BankAppButton`), and documents every utility and service.
- `core/` ships default implementations of its interfaces (`DioTransport`, `SessionManager`,
  `Fss…`/`SPref…Persistence`) in `core/<m>/implementations/`, so it can be copied unchanged. A project
  that needs a different one (an `HTTPTransport`, another `SessionAccessor`) puts it in `app/` and
  swaps it in through provider wiring — never by editing `core/`.
- **`application/`** is for multi-repository logic, workflows reused across screens, session/auth
  steps, or bootstrap/sync policy. Never for pass-through wrappers, pure data access (belongs in the
  repository), pure UI transitions (belongs in the VM) or app-wide shell glue (belongs in `app/`). It
  must never become a dumping ground.
- **Domain entities:** add them when DTOs are noisy, several responses map to one concept, or the
  concept spans several screens. Skip them when the DTO already fits, the feature is small and
  read-only, or the entity would mirror the DTO field for field. Domain never imports transport
  implementations or app glue.
- **Module boundaries** follow business capability — not screen, widget type or endpoint grouping. No
  one-module-per-screen, no catch-all module.
- **Promotion** — a second consumer is the earliest trigger, not an automatic one. Steps: (1) strip
  feature imports and business logic, (2) generalise parameters, (3) move to the right `app/` or
  `core/` submodule, (4) update every reference. Path: feature-local → `app/` → `core/`.
- **Ready for `core/` only if** the abstraction is stable, the naming is generic, it carries no app
  vocabulary, route names, storage keys or backend quirks, and its API still makes sense in another
  app. If it needs several app-specific caveats to make sense, it isn't ready.
- **`app/` is not a second utility bucket.** Business workflows stay in modules even when the UI is
  shared.
- **Constants have three homes:** technical/protocol → `core/constants/`; app-specific cross-module →
  `app/constants/`; single-capability → the module. No copy strings or screen titles in constants.
- **Crypto** primitives and key normalisation live centrally in `core/`; modules call the exposed
  services and never reimplement crypto or invent key-storage formats.
- **`core/services/`** return typed results, never raw plugin responses, and hold no navigation or
  screen policy — project-specific policy moves to `app/`.
- An optional copied core capability that planning rejects is deleted early — both the core folder and
  its app wiring.
- Don't re-implement date formatting, JSON parsing or validation in a feature — reuse or extend
  `core/utils/`.

**Checklist for any PR touching `core/`:** no imports from `modules/` or `app/`; the file would work
unchanged in another project; utilities are pure; core widgets get data through the constructor; new
logs are redacted; styling comes from `context`.

## §3 Placement additions
| Adding… | Goes in… |
|---|---|
| UiEffect scenario constants | `modules/<bucket>/<m>/domain/<m>_ui_scenario.dart` |
| Custom UiAction token (`@freezed` union) | `modules/<bucket>/<m>/domain/<m>_ui_action.dart` |
| Enum with behaviour (`fromValue`, `label`, `isTappable`) | `domain/` of its module |
| Device-I/O plugin (camera, picker, cropper, `permission_handler`, `dart:io`) | `core/services/<svc>/application/` |
| Third-party brand colours (Google/Apple sign-in) | `core/theme/brand_colors.dart` (`BrandColors`) |
| Locked logos (never recoloured) | a separate `AppBrandAssets` registry beside `AppIcons` |
| Structural, non-user-facing identifiers | `core/theme/strings.dart` — user text goes in localization keys |

A `domain/` file that needs a Presentation import doesn't belong in `domain/`.

A Freezed class with JSON needs both `part 'x.freezed.dart';` and `part 'x.g.dart';`; a Riverpod
provider file needs `part 'x.g.dart';`.

**Device-I/O seam:** a `core/services` wrapper returns a typed result with explicit outcomes —
`captured`, `cancelled`, `permissionDenied`, `permissionPermanentlyDenied`, `failed` — never `null`.
The ViewModel maps the result to state and imports no plugin.

## §4 State management
- **One screen, one ViewModel, one atomic Freezed state object.** No `StateProvider`, no per-field
  providers, no scattered local flags (`isSaving`, `errorText`). Never hand-write `copyWith` or
  equality.
- **`setState` is allowed** only for purely local, ephemeral UI state: a dropdown value beside its
  `TextEditingController`, a third-party controller counter (PDF page index), a WebView progress flag,
  a leaf widget's animation/expansion toggle. **Forbidden** for anything another widget or the VM
  needs, anything derived from repository data, or one-shot effects — and never as a wrapper such as
  `setState(() => showDialog(...))`.
- `ref.read` inside methods (one-off repository access, VM actions); `ref.watch` in `build()` and for
  providers that change over time. In a provider body: `ref.watch` for reactive deps, `ref.read` for
  static services. Widgets use `ref.watch(p.select(...))` on large state to limit rebuilds.
- **ViewModel MUST NOT** also: call `GenericApiService` directly (always via a repository); call
  `showModalBottomSheet`; run platform-channel or platform-specific logic; import `dart:ui` or any
  `package:flutter/*` (zero Flutter imports — a reviewer check); hold `Color` values (colours resolve
  in the view through roles).
- **Error message convention:** either `String? errorMessage` (null = no error) or
  `@Default('') String errorMessage` (empty = no error) — mirror the module; check with the matching
  idiom (`!= null` vs `isNotEmpty`). Clear it at the start of every retry. A persistent error renders
  inline with a Retry bound to a VM action, and stays until the VM clears or replaces it.
- Clearing `isLoading` in a `finally` block is an allowed alternative to clearing it in both paths.
- **Initial load:** from the view's `initState` via
  `WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(xProvider.notifier).load())`.
- **Provider bodies** only resolve dependencies and construct objects — no network calls, no storage
  clearing, no `vm.load()`. `providers.dart` only wires; implementation lives in concrete classes.
- **No circular provider dependencies.** Move shared logic to a lower-level provider. Known trap:
  `apiTransportProvider` ↔ `sessionManagerProvider` — break it with `ref.read` at the call site.
- **One-shot routines are not `FutureProvider`s.** Write them as a plain `Future<void> fn(Ref)`
  awaited by a `@Riverpod(keepAlive: true)` Notifier that owns the once-per-session guard (see
  `flutter-add-auth-screen` → post-login bootstrap).
- **Before creating a provider** decide its owner, its dependents, whether it's reusable, its
  lifetime, and whether it can be safely overridden in tests.
- Provider anti-patterns: a name that exposes the implementation instead of the capability; one
  provider with several responsibilities; a hidden service locator outside Riverpod. No business side
  effects during any provider's construction.
- No giant shared base-state for unrelated screens; don't store raw backend payloads in state.
- **Runtime mock mode** is not test overrides: app providers pick mock or real from flavor config and
  features depend only on the contract. Mock-only branches inside a repository are allowed only when
  the selection is explicit. Platform/integration dev controllers are chosen centrally too. Temporary
  mocks are documented — an undocumented mock or placeholder blocks a PR.
- **Codegen:** re-run after every `git pull`/merge, after structural renames or moves, and after
  adding or removing a Notifier `build()` parameter. Troubleshooting — "Undefined class `_$Name`": missing/mismatched `part`; "Conflict in
  outputs": add `--delete-conflicting-outputs`; "Provider not found": generator hasn't run.

## §6 Networking and session
- What each core network piece must not know: `ApiException` knows nothing about UI or Dio;
  `SingleResponse`/`ListResponse` hold no business logic and don't decode their payload; `GenericApiService` has no
  hardcoded endpoints, imports no feature models, depends only on `ApiTransport`; `ApiTransport` knows
  only `SessionAccessor`, never session logic. `core/network` never imports the concrete
  `SessionManager`.
- `SessionAccessor`:
  ```dart
  Future<String?> getAccessToken();
  Future<String?> refreshAccessToken();   // null on failure
  Future<void> clear({String? reason});
  ```
- **Refresh mechanics:** (a) on success, new tokens are saved before `refreshAccessToken()` returns;
  (b) a retry-guard flag in `requestOptions.extra` makes the retry happen once; (c) on failure the
  transport calls `clear(reason:)`, sets a terminal-auth flag in `extra`, and lets the 401 propagate;
  (d) `request()` sees the flag and throws `ApiException(status: 401, code: 'AUTH_REFRESH_FAILED')`
  with a user-safe "Session expired" message.
- **Dio base config:** connect, receive and send timeouts all set; base URL from the flavor config;
  content-type defaults to `application/json`. If the core default `dioProvider` is used, `main.dart`
  overrides it with the real base URL.
- **Adding a transport:** a class in `app/network/` implementing `ApiTransport`; implement every
  verb; turn library errors into `ApiException`; return `SingleResponse<T>`/`ListResponse<T>`. Wire it as a named
  provider in `app/providers/` and switch a feature by overriding `apiServiceProvider`. No business or
  session logic in a transport. Dio by default; native HTTP only inside a transport for lightweight or
  binary-stream cases.
- General retry policy lives in infrastructure; features offer only a manual Retry. Terminal
  failures propagate as canonical errors and never loop.
- Features never depend on `Dio`, `DioTransport`, `AuthStorage` or `SessionManager` directly — the one
  exception is reading identity (e.g. `userId`) from session state.
- Infrastructure classes (transports, `app/network`, `app/application`) never import Views,
  ViewModels or feature DTOs, and never take a `BuildContext`.
- `SessionState` variants: `bootstrapping`, `authenticated(session, …)`, `unauthenticated(…, reason)`.

## §7 App shell and navigation
- **One declarative root selector** (the app's `AppEntry`) watches launch, session and intro-gate state
  and picks Splash, Retry (launch failed), Intro, Unauthenticated or Authenticated. A successful login
  or logout changes `SessionState` and the shell re-evaluates — features never duplicate root routing.
- Split **launch-critical**, **deferred** and **post-login** work; never block launch on non-critical
  work. Post-login work runs through providers observing session state (`flutter-add-auth-screen`).
- **Reinstall:** preferences reset but the Keychain survives — clear the secure session once on first
  launch after install, before restoring. Invalidate in-flight bootstrap/refresh work on logout so an
  old session can't come back. "Authenticated but not fully hydrated" is a `SessionManager` state.
- Runtime resources (the `SharedPreferences` instance, environment URL maps) enter through root
  `ProviderScope` overrides; core providers may be seams that must be overridden at startup. Preload
  only what the first frame needs.
- `generateRoute` always has an unknown-route fallback (a fixed `AppRoute`, e.g. `root`, or an error
  route) — it never returns null.
- Use the `pushReplacement…` helpers when the current screen must not stay in history (Login →
  Landing, wizard steps). A deep link that resolves to `/` leaves the choice of screen to `AppEntry`.
  There is no way back into protected screens after logout.

## §8 Theming — policy detail
- **Seeding:** `ColorScheme.fromSeed(seedColor: AppColors.seed).copyWith(<only the roles actually
  used>)` for both brightnesses, with paired `light*`/`dark*` constants and a seed token separate from
  `primary`. Never assign the whole role set. Every pinned role gets an AA check against its `on*`
  partner. Colours with no M3 role go in the extension.
- **New semantic role:** add the full quartet (colour, `on*`, container, `on*`-container) for light
  and dark, AA-checked, in the single extension. Don't overload `warning` for something that isn't a
  caution. High-luminance hues take a dark `on*`.
- Theme tokens get semantic names (`successGreen`, not `lightGreen400`).
- **Theme mode:** default `ThemeMode.system`; a saved explicit choice overrides it. The control is a
  3-way System / Light / Dark selector — a binary switch can't return to "system".
- **Sanctioned fixed-colour exception:** third-party sign-in brand colours via `BrandColors`, and
  nothing else. Immersive surfaces (over-video UI, camera capture, full-screen media viewers, map
  overlays) are **not** exceptions: wrap them in the app's dark theme and use `scrim`,
  `onSurface`/`onSurfaceVariant` and `inverseSurface`/`onInverseSurface` (SKILL.md §8.2). No
  gradients — use a solid role. `m3-ignore` is a last resort, only with the user's agreement.
- **Icons vs logos:** keep `AppIcons` (recolourable) and `AppBrandAssets` (locked, rendered without a
  colour filter) as separate registries, so nothing invites recolouring a logo. No `'assets/**.svg'`
  literals in `lib/modules/` (theme-guard rule `hardcoded-asset-path` where a guard exists).
- No `GoogleFonts.*` overrides; a deliberately different font is a recorded decision.
- **Migration policy:** migrate one module at a time, fully completed, analyzed and built — never with
  a parallel fleet, never merging a half-converted feature. Every step leaves analyze clean and the app
  booting.

## Cache and refresh policy
- Choose per data set: **cache-first**, **blocking** or **silent refresh**. Escalate silent → blocking
  when stale data could invalidate the next action, when an auth decision depends on it, or when it
  would mislead the user.
- One sync service (in `application/` or `app/`) owns the policy; app storage holds loaded flags and
  last-refresh timestamps. ViewModels use the service and never own refresh policy.

## §9 Core widgets and dialogs
- A widget belongs in `core/widgets/` only if it is constructor-driven (no feature-provider reads),
  imports no module DTOs/enums/VMs, has no navigation policy, and is used by more than one module.
  App-wide but branded widgets go in `app/ui/`; everything else stays in its module. Core dialogs never
  own business routing.
- **Core widget contract:** data only through the constructor (never `ref.watch` on a feature
  provider); no navigation — take a `VoidCallback`, never import `PageRouter`; visual variants
  ("danger") are constructor enums/params; only internal visual state; strings arrive already
  localised (a widget may resolve only universal "OK"/"Cancel" itself); inline errors arrive as an
  `errorMessage` param. A widget with a single consumer stays in its feature.
- `core/widgets/` subfolders: `buttons/`, `common/` (fields such as `CommonTextField`,
  `CommonDropdownField`, `EnhancedDatePickerField`), `dialogs/`, `layouts/`.
- **Dialogs:** `CustomDialogAlert` for `ApiException` user messages and simple OK dismissal;
  `CustomDialog` for confirmations (primary action + Cancel, destructive actions) and blocking flows.
  Features never style their own dialogs. After an error dialog closes, the UI calls `vm.clearError()`.

## §10 Storage
- Persistence interfaces:
  ```dart
  abstract class SecurePersistenceInterface {        // all async
    Future<void> deleteKey(String k); Future<String?> readString(String k);
    Future<void> saveString(String k, String v); Future<bool> readBool(String k);
    Future<void> saveBool(String k, bool v);
  }
  abstract class SharedPersistenceInterface {        // async writes, sync reads
    Future<void> saveString(String k, String v); String? readString(String k);
    Future<void> saveBool(String k, bool v); bool? readBool(String k);
    Future<void> saveInt(String k, int v); int? readInt(String k);
  }
  ```
- Storage classes **wrap** a persistence interface (never extend it); providers expose interfaces,
  not concrete classes. Storage keys live only inside storage classes — never in VMs or UI. One
  storage class never mixes sensitive and non-sensitive data.
- Session tokens live in core-internal `AuthStorage`, touched only by `SessionManager`.
  `SecureAppStorage` holds other secrets. `AppStorage` holds feature flags, UI prefs, cached choices
  and app config, and may be used from ViewModels.

## §11 Infrastructure
- `main.dart` contains no provider definitions; any init routine over ~10 lines moves to a utility or
  provider in `app/` or `core/`.
- `MaterialApp` wiring: `supportedLocales: LocalizationsRegistry.supportedLocales`;
  `localizationsDelegates` includes `AppLocalizationsDelegate()`; `onGenerateRoute:
  PageRouter.generateRoute`; `initialRoute` from `AppRoute`; theme from `core/theme`.
- **Post-login work** (push registration, identity hydration) runs from a bootstrapper mounted in the
  always-present `AppEntry`, keyed off `SessionState` — see `flutter-add-auth-screen`.
- **Logging levels** (`GlobalLogger`, a singleton over `package:logging` adding file/function
  context; verbosity per flavor): **debug** — branch/variable tracing, off in prod; **info** —
  milestones (token refreshed, repository initialised); **warning** — recoverable events (retries, a
  401 trigger, a missing localization key); **error** — caught `ApiException`s, storage failures,
  terminal refresh failure, always with the stack trace. If `GlobalLogger` is backed by
  `dart:developer log()`, its output never reaches Android logcat — don't rely on logcat to verify.
- **Utilities:** pure utilities are the only code allowed as top-level/static without a provider. No
  static mutable state, no async or I/O (file writes belong in storage adapters or services), no
  `BuildContext`; depend only on the SDK and core primitives. `JsonHelper` does defensive raw-map reads
  (`readInt`/`readString`) and never holds DTO `fromJson`.

## §16 Feedback channel
| Situation | Channel |
|---|---|
| Something the user fixes on this screen | inline / banner |
| Acknowledgement, blocking issue, destructive confirmation, follow-up after dismissal | dialog (`afterDismiss` for "acknowledge, then act") |
| Brief non-blocking note | snackbar / toast |
When unsure, use the least disruptive option; avoid unnecessary dialogs.

## §16 Error UX additions
| Error | UX |
|---|---|
| 400 / 422 / validation | recoverable — inline, or a transient snackbar/toast via UiEffect |
| `AUTH_REFRESH_FAILED` | no blocking dialog — stop loading; the app shell routes on `SessionState` |

Every data screen renders **four distinct states**: loading (shimmer or progress), empty after a
successful fetch (illustration), error with Retry, and data. A fatal error may use a full-screen error
view instead of a dialog.

## §16 Testing ownership
- Each layer's tests have an owner, including application-service tests (session transitions,
  cache/refresh policy) and shell/root-selection tests.
- VM tests also cover field errors, form persistence and effect emission; repository tests cover list
  vs single responses; mocks are honest about their limits.
- Test at the cheapest correct layer — widget tests don't compensate for bad VM structure.
- **"Done"** means tests added or deferred with a stated reason, gaps documented, deferred validation
  recorded.

## §15 Review checklist by file type
- **ViewModel:** no Flutter imports, no `BuildContext`, one atomic state, `isLoading` cleared on every
  path, errors to state **or** effect, effects via `UiEffect.create`.
- **Repository:** interface + impl pair, verb helper with explicit decoder, no status-code checks,
  rethrows `ApiException`.
- **Provider:** in the right registry file, deliberate lifetime, no side effects, no cycles.
- **UI:** theme from `context`, strings from localization, listener closed in `dispose`, four data
  states rendered.
- **Startup/shell:** launch-critical only, root selector untouched by features, post-login work in the
  bootstrapper.
- **Transport/session:** canonical `ApiException`, single-flight refresh, no token outside `AuthStorage`,
  redacted logs.

## §18 Regression hotspots
Session/auth, startup, provider wiring, form-state refactors, field-error mapping, navigation after an
effect, mock/real switching, transport/storage contracts, cache + refresh. Flag regression risk when a
change touches any of these.

## §18 Deleting code
Before deleting a token, file or class, check external and internal references **and** the actual
imports — a name grep is not enough.
