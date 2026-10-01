---
name: dart-add-unit-test
description: >-
  Adds focused Dart unit tests. Use when testing pure utilities, validators, DTO mappers,
  repositories with fake services, ViewModels with Riverpod ProviderContainer overrides, or bugfix
  behavior that does not require a widget test.
---

# Dart Add Unit Test

## Use When

- Testing pure Dart logic.
- Testing ViewModel state transitions without rendering widgets.
- Testing repository mapping with fake services.
- Locking down a bugfix.

## Test Placement

- Mirror the source path under `test/` where practical.
- Name files `<source>_test.dart`.
- Keep tests focused on one behavior per case.

## Riverpod Testing

- Use `ProviderContainer` and provider overrides for ViewModel/repository tests.
- Dispose the container after each test.
- Avoid real network, storage, or platform channels in unit tests.

## What To Assert

- Initial state.
- Loading state before async work.
- Success state and mapped data.
- Error state using user-facing messages.
- Repository decoder and mapper behavior.
- `SessionManager` (mandatory): fake `AuthRepository` + `AuthStorage`; assert `refreshAccessToken()`
  is serialized (single-flight), sign-out clears secure storage, and a 401 input ends in an
  unauthenticated session with storage cleared.

## Avoid

- Sleeping in tests.
- Depending on test execution order.
- Calling real APIs.
- Testing generated code directly.
