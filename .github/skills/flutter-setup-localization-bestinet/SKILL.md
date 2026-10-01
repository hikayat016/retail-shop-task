---
name: flutter-setup-localization-bestinet
description: >-
  Sets up or extends localization in the BESTINET Flutter architecture. Use when adding localized
  strings, locale switching, ARB/generated localization, app localization key maps, or user-facing
  messages from ViewModel and ApiException flows.
---

# Flutter Setup Localization BESTINET

## Use When

- Adding localization to a new app.
- Adding user-facing strings to widgets, ViewModels, or error handling.
- Converting hardcoded UI text into localization keys.
- Wiring locale selection or persistence.

## Source Of Truth

- Follow the current app localization approach first.
- If the app uses ARB/generated `AppLocalizations`, add strings to ARB files and regenerate.
- If the app uses app-level localization key maps, add keys under the app localization layer:
  `lib/app/localization/` (`language_support.dart` + `localization_keys/<locale>.dart`).
- Do not invent a second localization system — no parallel `core/i18n/` catalog. Retire an old
  catalog only after a key-set comparison proves it adds nothing.

## Architecture Rules

- Widgets resolve localized display strings from context or approved localization helpers.
- ViewModels should avoid `BuildContext`; they may expose message keys or user-facing messages from
  normalized exceptions depending on the existing pattern.
- `ApiException.message.userMessage` must be safe for users. `developerMessage` must not be shown.
- Repository and data layers do not import Flutter localization widgets.
- One key-map file per locale, named by language and country (`en_us.dart`), each exporting a
  `Map<String, String>`; all maps go into a single `LocalizationsRegistry.register(...)` call before
  `runApp()`.
- `.t('key')` is an extension on both `Ref` and `WidgetRef`. `AppLocalizations.of(context).translate('key')`
  is the context-based alternative and only works once `AppLocalizationsDelegate()` is registered in
  `MaterialApp.localizationsDelegates` (with `supportedLocales: LocalizationsRegistry.supportedLocales`).
- Never use `developerMessage` as a localization key — map only `userMessage` or error codes.
- **A missing key resolves to the key itself**, so text that is not a key (a message the server
  already localized) passes through translation unchanged. That lets fallback error messages in
  `core/network` be keys (`common_error_connection`) that the view resolves with `context.t(...)`,
  while server messages show as sent.
- **Core widgets can't import `app/`.** Give them their few strings through a core-level
  `CoreStringsScope` (an `InheritedWidget` in `core/localization/` with English defaults) that
  `MaterialApp.builder` fills from the key maps. Core services report failures as enums, not
  sentences, and the view maps them to keys.
- Platform/exception text (`CameraException.description`, plugin `toString()`) is developer text:
  log it, show a translated message.

## Adding Strings

- Add a stable key named `feature_component_description` (e.g. `login_input_password_label`);
  generic strings use a shared `common_*` section (`common_button_save`).
- Add all supported locales in the same change when the project requires complete coverage.
- Include placeholder metadata when using ARB.
- Keep text short enough for mobile layouts and translated expansion.

## Validation

- Register the key maps for tests in `test/flutter_test_config.dart` (`testExecutable`), or every
  widget test renders keys instead of text.
- Keep a coverage test: every literal `.t('key')` in `lib/` exists in the fallback locale, every
  locale has the same key set, and `{placeholders}` match across locales.

- Run generation or `flutter pub get` when localization codegen requires it.
- Run `flutter analyze` or the project analysis command.
- Check the screen at narrow widths when adding long translated strings.

## Avoid

- Hardcoded user-facing text in feature widgets once localization is active.
- Localizing logs or developer diagnostics.
- Using localization inside repositories.
