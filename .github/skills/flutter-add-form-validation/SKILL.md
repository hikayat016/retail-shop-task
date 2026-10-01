---
name: flutter-add-form-validation
description: >-
  Adds form validation patterns for BESTINET Flutter apps. Use when building forms, field validators,
  chained validation rules, submit validation, async validation, or reusable input components with
  Riverpod ViewModels and M3 form UI.
---

# Flutter Add Form Validation

## Use When

- A screen collects user input.
- Validation rules are repeated across screens.
- A form needs both local field validation and submit-time business validation.

## Ownership

- Pure formatting and simple field validation can live in `core/utils/validators/`.
- Feature-specific validation belongs near the feature ViewModel or form state.
- Server validation belongs in repositories or application services and returns normalized errors.
- Widgets render validation messages but do not own business validation.

## Validator Rules

- Validators must be pure functions.
- Validators must not read Riverpod providers, storage, network clients, or `BuildContext`.
- Reusable validators should return user-facing strings or a typed validation result.
- Keep validation messages localizable when the project has localization enabled.

## Chaining Pattern

Use small validators and compose them:

```dart
typedef FieldValidator = String? Function(String value);

FieldValidator requiredField(String message) =>
    (value) => value.trim().isEmpty ? message : null;

FieldValidator all(List<FieldValidator> validators) => (value) {
  for (final validator in validators) {
    final error = validator(value);
    if (error != null) return error;
  }
  return null;
};
```

Use this as a pattern, not a required API. Match existing project utilities when present.

## ViewModel Rules

- Store submitted field values and validation state in immutable state.
- Submit methods should guard against invalid forms before calling repositories.
- Async submit must set loading state before I/O and clear it in success/error paths.
- ViewModels may translate repository `ApiException` into field-level or form-level messages.
- Non-trivial or multi-step forms keep **one immutable form object** inside state, with the current
  step stored separately: field edits touch only the form, step changes touch only the step, so values
  survive step changes. Top-level state keeps only screen-wide flags. Extract the form object early.
- Keep field-level and screen-level errors separate. Editing a field clears only that field's server
  error. Map backend field errors back onto the form fields.

## Widget Rules

- Use `Form` and `TextFormField` where that matches existing UI.
- Use M3 theme roles and shared input widgets when present. Text fields follow M3: one style app-wide
  (filled or outlined, set in `inputDecorationTheme`), a persistent label (never placeholder-only),
  supporting text below, error text in the `error` role replacing supporting text, 48 dp tap height,
  and `SegmentedButton`/`DropdownMenu`/`Switch`/`Checkbox` for choices. Submit with a `FilledButton`.
- Controllers stay local to widgets as input plumbing; the ViewModel's form object is the source of
  truth for values (sync controllers from it when state must survive route or step changes).
- Do not run network validation from `build()`.

## Avoid

- Business rules inside `onChanged` when they belong in the ViewModel.
- Storing passwords, tokens, or OTPs in normal app storage.
- Logging sensitive form values.
