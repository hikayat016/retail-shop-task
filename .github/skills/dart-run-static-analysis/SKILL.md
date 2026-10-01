---
name: dart-run-static-analysis
description: >-
  Runs Dart and Flutter static analysis for focused validation. Use after Dart changes, before
  reviews, when diagnosing analyzer warnings, or when checking lints in packages, apps, tests, and
  generated-code workflows.
---

# Dart Run Static Analysis

## Use When

- Dart or Flutter code changed.
- A lint, type error, or analyzer warning appears.
- Preparing for review or handoff.

## Commands

Prefer the project toolchain:

```bash
fvm flutter analyze
```

If the project does not use FVM:

```bash
flutter analyze
```

For pure Dart packages:

```bash
dart analyze
```

## Workflow

1. Run analysis after the smallest meaningful code change.
2. Fix errors related to your change first.
3. Do not refactor unrelated analyzer findings unless asked.
4. If generated files are stale, run the project's code generation command rather than editing them.

## Riverpod/Freezed Notes

- Missing generated providers usually mean codegen has not run.
- Do not hand-edit `*.g.dart` or `*.freezed.dart`.
- Prefer fixing the source annotation, part directive, or provider definition.
