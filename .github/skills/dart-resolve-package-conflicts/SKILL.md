---
name: dart-resolve-package-conflicts
description: >-
  Resolves Dart and Flutter package version conflicts. Use when pub get fails, dependency solving
  reports incompatible constraints, generated packages drift, or Flutter/Dart SDK constraints block
  upgrades.
---

# Dart Resolve Package Conflicts

## Use When

- `flutter pub get` or `dart pub get` fails.
- A package upgrade creates SDK or transitive dependency conflicts.
- Build tooling packages such as Riverpod, Freezed, build_runner, or analyzer disagree.

## Workflow

1. Read the solver error carefully; identify the first direct dependency causing the conflict.
2. Check `environment.sdk` and the Flutter SDK version.
3. Prefer compatible version ranges over pinning exact versions unless the project requires a pin.
4. Keep codegen package versions compatible with runtime annotations.
5. Run `flutter pub get` after each focused change.
6. Run analysis or tests after dependency resolution succeeds.

## Riverpod/Freezed Compatibility

- Keep `riverpod_annotation`, `riverpod_generator`, `flutter_riverpod`, and `riverpod_lint`
  mutually compatible.
- Keep `freezed_annotation`, `freezed`, `json_annotation`, and `json_serializable` compatible when
  present.
- Analyzer constraints often come through code generation tools; do not upgrade analyzer alone unless
  the generator stack supports it.

## Avoid

- Running broad major upgrades without a reason.
- Deleting lockfiles as the first step.
- Committing dependency changes without a successful `pub get`.
