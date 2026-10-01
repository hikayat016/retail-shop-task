---
name: flutter-configure-flavors
description: >-
  Configures Flutter environment flavors and app runtime configuration. Use when adding dev, QA,
  UAT, pilot, prod, base URLs, environment labels, secure-screen flags, logging levels, analytics
  captors, or build-time environment behavior.
---

# Flutter Configure Flavors

## Use When

- Adding or changing build flavors.
- Wiring environment-specific base URLs, app names, logging, analytics, or security flags.
- Creating a new app from the portable template.

## Flavor Rules

- Keep flavor names explicit and stable: for example `dev`, `qa`, `uat`, `pilot`, `prod`.
- Keep platform flavor configuration in Android/iOS platform files.
- Keep runtime environment access behind app-level configuration providers.
- Do not scatter `const String.fromEnvironment` reads through feature code.

## Security Posture

- Production and production-like flavors should default to the strict posture.
- If a flavor handles real personal data, treat it like production for screen capture, logging, and
  storage rules.
- Debug convenience must not leak into distributable builds.
- Consult `flutter-mobile-security` before changing secure-screen, signing, backup, logging, TLS, or
  storage behavior.

## Provider Pattern

- Expose flavor config through an app-layer provider.
- Features consume typed config, not raw environment strings.
- Keep configuration immutable after bootstrap.

## Documentation

- Update `READMEFIRST/TESTER_NOTES.md` when build commands or installable artifacts change.
- Update security baseline when flavor security posture changes.
- Document which flavors point to real data.

## Avoid

- Feature-level checks like `if (flavor == 'prod')` unless there is no better app-layer policy.
- Committing signing material.
- Reusing production endpoints from non-production builds without an explicit decision.
