---
name: dart-use-path-package
description: >-
  Uses Dart path handling safely. Use when joining paths, normalizing file names, handling generated
  files, build artifacts, local documents, test fixtures, or cross-platform filesystem paths.
---

# Dart Use Path Package

## Use When

- Code manipulates file paths.
- Tests load fixtures.
- Build scripts generate or copy files.
- Paths must work across macOS, Windows, Linux, Android, or iOS tooling.

## Rules

- Prefer `package:path/path.dart` for joining, normalizing, basename, dirname, extension, and relative
  path operations.
- Do not concatenate paths with `/` in Dart code unless the value is a URL path by design.
- Keep URL path handling separate from filesystem path handling.
- Validate user-controlled file names before writing.

## Flutter Notes

- Asset paths in `pubspec.yaml` use forward slashes and are not filesystem paths at runtime.
- Temporary, document, and cache directories should come from the appropriate platform path provider
  abstraction when used.
- Do not store sensitive files in normal cache or documents directories without security review.

## Avoid

- Hardcoded absolute local machine paths.
- Assuming path separators.
- Writing generated files outside approved project folders.
