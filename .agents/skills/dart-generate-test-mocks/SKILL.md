---
name: dart-generate-test-mocks
description: >-
  Creates test doubles for Dart and Flutter tests. Use when faking repositories, services,
  transports, storage, analytics, or session managers for unit and widget tests in a Riverpod app.
---

# Dart Generate Test Mocks

## Use When

- A test needs to isolate a ViewModel, repository, or service.
- A dependency performs network, storage, analytics, or platform work.
- Provider overrides need fake implementations.

## Preferred Test Doubles

- Prefer small handwritten fakes for stable project interfaces.
- Use mocks only when verifying interactions matters.
- Use stubs for simple return values.
- Keep fake data builders near tests when they are feature-specific.

## Riverpod Pattern

- Override providers with fake implementations in `ProviderContainer` or widget test scopes.
- Do not override low-level transport when a repository fake is enough.
- For repository tests the seam is `apiTransportProvider.overrideWithValue(FakeApiTransport())`;
  override `authStorageProvider` with an in-memory fake.
- Test the smallest useful unit.

## Fake Design

- Implement the same abstract interface as production code.
- Expose simple controls for success, failure, and captured input.
- Throw `ApiException` or project-normalized errors when testing error flows.
- `FakeApiTransport` returns canned success, wrapped-error and 401 responses; repository tests cover
  all three.

## Avoid

- Mocking generated providers directly when overriding dependencies is cleaner.
- Real secure storage, shared preferences, network, or analytics in unit tests.
- Over-specified interaction tests that break during harmless refactors.
