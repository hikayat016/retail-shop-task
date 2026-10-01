<!-- Generated from flutter-template/adapters/codex/AGENTS.md. Edit the template, then run flutter-template/bin/apply-template.sh codex. -->
# AGENTS.md

This is Retail Shop. Follow the in-repo architecture and security rules before changing code.

Detailed skills live in `.agents/skills/<skill>/SKILL.md`. Codex discovers them automatically; when a
task matches one of the routes below, open that skill before writing code.

## Project Shape

- Use the layered MVVM layout already in the repo: `lib/core/`, `lib/modules/`, and `lib/app/`.
- Feature code lives under `lib/modules/features/<module>/`; shared cross-feature data lives under `lib/modules/common/<module>/`.
- Use Riverpod code generation (`@riverpod` Notifier) and Freezed for state. `@Riverpod(keepAlive: true)` is only for long-lived infra (session, config, storage, `Dio`, bootstrappers).
- Do not assume Clean Architecture with dartz: no `Either`/`Failure`/`dartz`, no UseCase classes, no Equatable entities. Do not introduce `provider`, `get_it`, or a second router.
- Repository contracts belong in `domain/repositories/`; implementations belong in `data/repositories/`.
- Repositories return typed DTOs/domain models via `GenericApiService` verb helpers (`get`/`post`/`put`/`delete`, `getList`/`postList`/…) with an explicit `decoder`/`listDecoder`; errors normalize to `ApiException`.
- Repository, service, and app-wide providers are centralized in `lib/app/providers/providers.dart`; copyable core infra providers in `lib/core/providers/providers.dart`.
- Navigation uses `AppRoute` and `PageRouter` with two tiers: context helpers inside the widget tree, `...Global` helpers outside it. No GoRouter, no `AppNavigator` facade, no `AppRoutes` string class, no `lib/core/routing/`.
- User-facing one-shot effects use the existing `UiEffect` framework (`lib/core/utils/side_effects/ui_effect` + `lib/app/ui/ui_effect`).
- M3 role-based theming is the production model: feature widgets read colours and typography from the theme via `context`, never `AppColors.x`, `Color(0xFF...)`, or static tokens.

## Task Routing

- Flutter architecture, screens, widgets, themes, routes, networking, localization, Riverpod, Freezed, repositories, or ViewModels: `flutter-bestinet-core`.
- Tokens, sessions, login, biometrics, storage, networking security, TLS, permissions, deep links, WebView, logging, signing, obfuscation, screenshots, PDPA, Act 854, OWASP, MASVS, or penetration-test findings: `flutter-mobile-security`. Security rules outrank the other skills where they conflict.
- Paginated lists, infinite scroll, refresh, filtering, search, or server-side paging: `flutter-add-paginated-list`.
- Forms, validators, submit validation, field errors, or reusable inputs: `flutter-add-form-validation`.
- API repository methods, DTO decoders, GenericApiService wiring, or ApiException handling: `flutter-wire-generic-api-service`.
- Environment flavors, runtime app config, base URLs, logging posture, or secure-screen flags: `flutter-configure-flavors`.
- Analytics events, analytics captors, local debug analytics, or privacy-safe event dimensions: `flutter-add-analytics-reporter`.
- Localization setup, localization keys, generated localizations, or user-facing message text: `flutter-setup-localization-bestinet`.
- Sign in, sign out, guest sign in, forgot password, signup, OTP/TAC, or session bootstrap screens: `flutter-add-auth-screen`.
- Widget tests: `flutter-add-widget-test`. Integration tests: `flutter-add-integration-test`. Widget previews: `flutter-add-widget-preview`.
- Layout overflows or constraint errors: `flutter-fix-layout-issues`. Responsive layouts: `flutter-build-responsive-layout`.
- Unit tests, mocks, static analysis, package conflicts, coverage, path handling, doc examples, Dart documentation, primary constructors, or pattern matching: the matching `dart-*` skill.
- Non-code documentation, release notes, tester notes, handover notes, build notes, or markdown files: `readmefirst`.

## Working Rules

- Prefer minimal, targeted diffs that follow nearby code style.
- Do not hand-edit generated files such as `*.g.dart` or `*.freezed.dart`; regenerate them with `dart run build_runner build --delete-conflicting-outputs`.
- Do not show `developerMessage` values to users; UI text must use user-facing messages.
- Store sensitive values only through secure storage abstractions.
- Keep non-code project documentation inside `READMEFIRST/`, not as loose root markdown files.
- Do not edit `.agents/skills/`, `.claude/skills/`, or `.github/skills/` directly; edit `flutter-template/skills/` and regenerate with `flutter-template/bin/apply-template.sh`.
- After Dart or Flutter changes, run a focused validation command (for example `flutter analyze <paths>` and the related tests) and report the result. Before finishing, run a whole-project `dart analyze`: only it runs analyzer plugins such as `riverpod_lint`.
