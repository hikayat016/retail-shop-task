---
name: flutter-add-auth-screen
description: >-
  Adds authentication screens and flows in the BESTINET Flutter architecture. Use when implementing
  sign in, sign out, guest sign in, forgot password, sign up, OTP/TAC, session bootstrap, auth
  errors, secure storage, or post-login navigation.
---

# Flutter Add Auth Screen

## Use When

- Building login, signup, forgot password, OTP, TAC, or session screens.
- Wiring authentication repositories and session managers.
- Handling auth errors or post-login navigation.

## Required Skills

- Read `flutter-bestinet-core` first.
- Read `flutter-mobile-security` before touching tokens, passwords, OTPs, biometrics, secure
  storage, logging, screenshots, or session state.

## Layering

- Widgets render the form and observe ViewModel state, following M3: the sign-in action is the one
  `FilledButton`, secondary routes (forgot password, sign up) are `TextButton`s, OTP/TAC uses filled or
  outlined fields from the app's `inputDecorationTheme`, and errors use the `error` role. Third-party
  sign-in buttons use `BrandColors` (the sanctioned fixed-colour exception).
- ViewModels validate submit intent, set loading state, call auth/session services, and emit effects.
- Application layer owns `SessionManager` or equivalent orchestration.
- Repositories call auth APIs through `GenericApiService`.
- Secure storage abstractions own token persistence — tokens go through core-internal `AuthStorage`,
  touched only by `SessionManager`.
- `SessionState` has three variants: `bootstrapping`, `authenticated(session, …)`,
  `unauthenticated(…, reason)`. Features read identity (e.g. `userId`) from it but never depend on
  `Dio`, `DioTransport`, `AuthStorage` or `SessionManager` otherwise.

## Post-login bootstrap

- Work that needs a signed-in user (push/FCM registration, identity hydration) runs from a
  **post-login bootstrapper** mounted in the always-present `AppEntry`, keyed off `SessionState` — so
  it also covers restored sessions, push-notification taps and deep links. Never in a screen's
  `initState`. The shell does not block on it.
- Model the routine as a plain `Future<void> fn(Ref)` awaited by a `@Riverpod(keepAlive: true)`
  bootstrapper Notifier that owns the once-per-session guard — **not** a `FutureProvider`, whose
  cache either skips the work on a second sign-in or runs it twice if you invalidate first.
- Device-test tip: to tell a restored session from a fresh sign-in, check that no WebView/SSO
  process started and bootstrap ran within ~10 ms of the first frame. Wall-clock login time misleads
  because autofill makes sign-in fast.
- Logout teardown: see `flutter-mobile-security` §3 (`SessionExternalCleanup`, WebView cookies).

## State Shape

Auth state should model at least:

- field values or form validity
- loading/submitting flag
- field-level errors when needed
- form-level user-facing error
- one-shot success/navigation effect

Use Freezed or the existing immutable state pattern.

## Security Rules

- Never store tokens in normal preferences.
- Never log passwords, OTPs, TACs, access tokens, refresh tokens, or raw auth responses.
- Clear sensitive field state when leaving the flow if the app pattern requires it.
- Treat biometric or PIN unlock as a security design decision, not a UI toggle.

## Navigation

- ViewModels must not call `Navigator` or `PageRouter` directly.
- Sign-in and sign-out change `SessionState`; the app shell's root selector re-evaluates and shows the
  right screen. Use a `UiEffect` navigate action only for navigation **inside** the auth flow (e.g.
  login → OTP). No navigation bools in state.
- Logout is deterministic: `SessionManager.clear()` flips `SessionState`, the app shell resets the
  stack to `AppRoute.root` via the global tier, and `AppEntry` picks the screen. Features SHOULD NOT
  show a blocking dialog for `AUTH_REFRESH_FAILED` — stop loading and let the shell route.
- Use `pushReplacement…` helpers so Login is not left in history after sign-in; there must be no way
  back into protected screens after logout.
- Use `AppRoute` and `PageRouter`; do not introduce `GoRouter`.

## Avoid

- Auth HTTP calls in widgets.
- Storing credentials for convenience.
- Showing backend developer messages to users.
