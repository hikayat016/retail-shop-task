---
name: flutter-add-analytics-reporter
description: >-
  Adds an analytics reporting abstraction for Flutter apps. Use when introducing analytics events,
  multiple analytics captors, local debug analytics, Firebase or vendor analytics, privacy-safe event
  dimensions, or environment-specific analytics wiring.
---

# Flutter Add Analytics Reporter

## Use When

- The app needs analytics events.
- More than one analytics destination may exist.
- Dev builds need local/debug event capture.
- Event logging must respect privacy and security rules.

## Architecture

- Put reusable analytics interfaces in `core/` only if they are project-agnostic.
- Put app-specific captor selection and provider wiring in `app/`.
- Feature ViewModels may request analytics through an abstract reporter.
- Widgets should not talk directly to vendor analytics SDKs.

## Recommended Shape

```text
AnalyticsEvent -> AnalyticsReporter -> AnalyticsCaptor(s)
```

- `AnalyticsEvent`: typed event name plus typed dimensions.
- `AnalyticsReporter`: fans out to enabled captors.
- `AnalyticsCaptor`: vendor/local implementation.

## Privacy Rules

- Read `flutter-mobile-security` before adding analytics around identity, auth, documents, worker
  data, or location.
- Never log tokens, passwords, OTPs, full document numbers, or sensitive payloads.
- Prefer stable event names and low-risk categorical dimensions.
- Make PII decisions explicit in `READMEFIRST/SECURITY_BASELINE.md` when analytics changes scope.

## Flavor Rules

- Dev and QA may enable local debug captors.
- Production should use only approved analytics captors.
- Captor selection belongs to app configuration, not feature code.

## Testing

- Enforce the privacy rules in the reporter (validate each event before any captor sees it), and
  test that every catalogue event passes and that free text and non-primitive dimensions are dropped.
- The reporter provider reads the environment, so ViewModel tests that report events override it
  with a recording captor. That also lets them assert the events, including that no username or
  identifier rides along.
- Test captor selection per flavor, so a production flavor can't quietly gain a debug captor.
- A captor that throws must not break the feature or the other captors.

## Avoid

- Importing analytics SDKs in feature widgets.
- Logging raw API responses.
- Hiding analytics side effects inside repositories.
