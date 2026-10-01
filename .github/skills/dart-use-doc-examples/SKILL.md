---
name: dart-use-doc-examples
description: >-
  Adds useful Dart documentation examples. Use when documenting reusable APIs, validators,
  repositories, utilities, widgets, or package-like core code where examples clarify correct usage.
---

# Dart Use Doc Examples

## Use When

- A reusable API is easy to misuse.
- A validator, mapper, helper, or service has non-obvious behavior.
- Public or core APIs need examples for future teams or agents.

## Rules

- Keep examples short and compilable in spirit.
- Show the preferred architecture path, not shortcuts.
- Use domain-neutral sample data unless the API is project-specific.
- Avoid secrets, tokens, real endpoints, or personal data in examples.

## Format

Use Dart doc comments:

```dart
/// Validates a worker identifier.
///
/// Example:
/// ```dart
/// final error = validateWorkerId('A123');
/// expect(error, isNull);
/// ```
String? validateWorkerId(String value) => null;
```

## Avoid

- Long tutorials in API docs.
- Examples that bypass Riverpod, repositories, or security abstractions.
- Duplicating behavior that tests already explain better.
