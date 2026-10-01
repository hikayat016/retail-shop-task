---
description: "Use when working on Flutter/Dart architecture, screens, widgets, routes, Riverpod, Freezed, repositories, networking, localization, theming, or deciding where code belongs in this app."
applyTo: "lib/**/*.dart,test/**/*.dart,pubspec.yaml,analysis_options.yaml"
---

# BESTINET Flutter Core

Use `.github/skills/flutter-bestinet-core/SKILL.md` as the canonical detailed guide.

Essential rules:

- Follow the shipped project shape: `lib/core/`, `lib/modules/`, and `lib/app/`.
- Default user-facing verticals to `lib/modules/features/<module>/`; promote shared data to `lib/modules/common/<module>/` only once a second module needs it.
- Keep layers clean: Presentation -> Application -> Data -> Core, with Domain used for repository interfaces and pure entities.
- Use Riverpod code generation and Freezed state; `@Riverpod(keepAlive: true)` only for long-lived infra (session, config, storage, `Dio`, bootstrappers). No `Either`/`Failure`/`dartz`, UseCase classes, or Equatable entities. ViewModels must not hold `BuildContext`, call navigation APIs, show UI, parse raw HTTP/JSON, or touch secure storage directly.
- Put repository interfaces in `domain/repositories/` and implementations in `data/repositories/`.
- Add repository, service, and app-wide provider wiring to `lib/app/providers/providers.dart`; copyable core infra providers go in `lib/core/providers/providers.dart`.
- Use `GenericApiService` verb helpers (`get`/`post`/…, `getList`/`postList`/…) with an explicit `decoder`/`listDecoder` for data access. Normalize failures to `ApiException` before UI state.
- Use `AppRoute` and `PageRouter` with two tiers: context helpers inside the widget tree, `...Global` helpers outside it. Do not introduce `GoRouter`, an `AppNavigator` facade, an `AppRoutes` string class, `lib/core/routing/`, a parallel `Navigator` abstraction, or feature-local routing systems.
- Use the existing `UiEffect` pattern (`lib/core/utils/side_effects/ui_effect` + `lib/app/ui/ui_effect`) for one-shot user-facing effects.
- Feature widgets read colors, typography, shapes, and spacing from theme/context. Do not use `AppColors.x` or hardcode feature-level hex colors.
- Do not hand-edit generated files.
