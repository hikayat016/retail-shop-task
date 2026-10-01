# GitHub Copilot Instructions

This is Retail Shop. Follow the in-repo architecture and security rules before changing code.

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

- For Flutter architecture, screens, widgets, themes, routes, networking, localization, Riverpod, Freezed, repositories, or ViewModels, use `.github/skills/flutter-bestinet-core/SKILL.md`.
- For tokens, sessions, login, biometrics, storage, networking security, TLS, permissions, deep links, WebView, logging, signing, obfuscation, screenshots, PDPA, Act 854, OWASP, MASVS, or penetration-test findings, use `.github/skills/flutter-mobile-security/SKILL.md`.
- For paginated lists, infinite scroll, refresh, filtering, search, or server-side paging, use `.github/skills/flutter-add-paginated-list/SKILL.md`.
- For forms, validators, submit validation, field errors, or reusable inputs, use `.github/skills/flutter-add-form-validation/SKILL.md`.
- For API repository methods, DTO decoders, GenericApiService wiring, or ApiException handling, use `.github/skills/flutter-wire-generic-api-service/SKILL.md`.
- For environment flavors, runtime app config, base URLs, logging posture, or secure-screen flags, use `.github/skills/flutter-configure-flavors/SKILL.md`.
- For analytics events, analytics captors, local debug analytics, or privacy-safe event dimensions, use `.github/skills/flutter-add-analytics-reporter/SKILL.md`.
- For localization setup, localization keys, generated localizations, or user-facing message text, use `.github/skills/flutter-setup-localization-bestinet/SKILL.md`.
- For sign in, sign out, guest sign in, forgot password, signup, OTP/TAC, or session bootstrap screens, use `.github/skills/flutter-add-auth-screen/SKILL.md`.
- For tests, use the matching test skill in `.github/skills/flutter-add-widget-test/` or `.github/skills/flutter-add-integration-test/`.
- For widget previews, use `.github/skills/flutter-add-widget-preview/SKILL.md`.
- For layout overflows or constraint errors, use `.github/skills/flutter-fix-layout-issues/SKILL.md`.
- For responsive layout work, use `.github/skills/flutter-build-responsive-layout/SKILL.md`.
- For static analysis, package conflicts, coverage, unit tests, mocks, path handling, or doc examples, use the matching Dart skill in `.github/skills/`.
- For Dart documentation, primary constructors, or pattern matching, use the matching Dart skill in `.github/skills/`.
- For non-code documentation, release notes, tester notes, handover notes, build notes, or markdown files, use `.github/skills/readmefirst/SKILL.md`.

## Working Rules

- Prefer minimal, targeted diffs that follow nearby code style.
- Do not hand-edit generated files such as `*.g.dart` or `*.freezed.dart`.
- Do not show `developerMessage` values to users; UI text must use user-facing messages.
- Store sensitive values only through secure storage abstractions.
- Keep non-code project documentation inside `READMEFIRST/`, not as loose root markdown files.
- After Dart or Flutter changes, run a focused validation command and hot reload or hot restart when an app is connected.
