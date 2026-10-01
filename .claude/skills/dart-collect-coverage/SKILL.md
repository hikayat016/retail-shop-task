---
name: dart-collect-coverage
description: >-
  Collects Dart and Flutter test coverage. Use when measuring unit/widget coverage, validating new
  feature tests, preparing quality reports, or checking whether ViewModels, repositories, and pure
  utilities are covered.
---

# Dart Collect Coverage

## Use When

- A feature adds important ViewModel, repository, validator, or widget behavior.
- A release or review asks for test coverage evidence.
- You need to identify untested business logic.

## Commands

Flutter app:

```bash
fvm flutter test --coverage
```

Without FVM:

```bash
flutter test --coverage
```

Pure Dart package:

```bash
dart test --coverage=coverage
```

## Interpretation

- Prioritize meaningful coverage over raw percentages.
- ViewModels, validators, mappers, repositories, and security-sensitive logic deserve focused tests.
- Generated files should usually be excluded from coverage reporting.
- UI-only layout code may be better validated by widget tests than unit tests.

## Avoid

- Adding shallow tests only to raise a percentage.
- Treating coverage as proof that behavior is correct.
- Ignoring failing tests because coverage was generated.
