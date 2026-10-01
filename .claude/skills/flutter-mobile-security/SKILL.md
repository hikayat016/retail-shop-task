---
name: flutter-mobile-security
description: >-
  OWASP MASVS v2 / Mobile Top 10 rules for this stack (AppStorage vs SecureAppStorage, DioTransport,
  SessionManager, GlobalLogger), PR blockers, release gate and quick scan. Use for any security,
  privacy or compliance ask and when touching tokens, sessions, login, biometrics, storage, TLS,
  permissions, deep links, WebView, logging, signing, backups, screenshots, PDPA, Act 854 or pentests.
metadata:
  standards: OWASP MASVS v2.x, OWASP Mobile Top 10 (2024)
---

# Flutter — Mobile Application Security

## 0. Read first

**Precedence.** Security rules here outrank convenience, and outrank the project's architecture
skill (`flutter-bestinet-core`, `flutter-layered-riverpod-core`, or whatever that project calls it)
where they conflict. If a rule here blocks a pattern that skill allows, this one wins — say so and
record the conflict in the project's decision notes (`READMEFIRST/`) rather than silently choosing.

**Portable.** This skill is project-agnostic and travels with the template. It assumes only the
shared stack vocabulary — `AppStorage`/`SecureAppStorage`, `ApiTransport`/`DioTransport`,
`SessionManager`, `ApiException`, `GlobalLogger`. Where a project names things differently, map
the role, not the identifier. Findings belong in the **project's** own security baseline file,
never in this skill — keep it a rule set, not a log.

**Scope.** Client-side only. The app is never the security boundary: every rule here reduces
exposure, none of them replaces server-side authorisation and validation. If a control can be
bypassed by an attacker with a rooted device and a proxy, treat it as defence in depth, not as a
control you can rely on.

**Be concrete.** When reviewing, cite `file:line` and name the MASVS control or Top-10 category. Do
not report "could be more secure" without a concrete failure path.

---

## 1. The standards, mapped

| Top 10 (2024) | What it means here |
|---|---|
| M1 Improper Credential Usage | Hardcoded keys; tokens in the wrong store; credentials in logs or URLs |
| M2 Inadequate Supply Chain | Stale Flutter/Dart, unpinned or unvetted packages, unverified native SDKs |
| M3 Insecure Authentication/Authorization | Biometric as a boolean; client-side role checks; no re-auth on sensitive actions |
| M4 Insufficient Input/Output Validation | Trusting QR payloads, deep links, or server data as safe |
| M5 Insecure Communication | No pinning, cleartext allowed, ATS exceptions, ignored cert errors |
| M6 Inadequate Privacy Controls | PII on screen captured in screenshots/snapshots; over-collection; no consent trail |
| M7 Insufficient Binary Protection | No obfuscation; debug symbols shipped; secrets recoverable from the bundle |
| M8 Security Misconfiguration | Debug-signed releases, `allowBackup`, exported components, debuggable builds |
| M9 Insecure Data Storage | Sensitive data in SharedPreferences, caches, backups, or plaintext files |
| M10 Insufficient Cryptography | Home-rolled crypto, ECB, static IVs, keys not in Keystore/Keychain |

MASVS v2 groups referenced below: **STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE,
PRIVACY**.

---

## 2. Non-negotiable — PR blockers

Reject the change if any of these is true.

1. A token, refresh token, password, PIN, or biometric template reaches `AppStorage`,
   `SharedPreferences`, `LocalStorage`, a plain file, or a log line. Secrets go to the secure tier
   only — session tokens via core-internal `AuthStorage` (owned by `SessionManager`), every other
   secret via **`SecureAppStorage`** (MASVS-STORAGE-1, M9).
2. A secret, API key, or credential is a literal in Dart, Gradle, plist, or an `.env` committed to
   the repo. Anything in the bundle is public (MASVS-STORAGE-2, M1/M7).
3. A release build is signed with debug keys, or ships `debuggable`/`--debug` (M8).
4. TLS verification is disabled or relaxed — `badCertificateCallback` returning `true`,
   `NSAllowsArbitraryLoads`, `usesCleartextTraffic="true"` (MASVS-NETWORK-1, M5).
5. A screen showing passport numbers, permit numbers, salary, biometric capture, or contract PII has
   no capture protection (MASVS-PRIVACY-3, M6). See §6.
6. `GlobalLogger` receives PII, a token, a full request/response body, or a `developerMessage` is
   surfaced to the user (MASVS-PRIVACY-2, M1).
7. An authorisation decision is made **only** on the client — a hidden button is not an access
   control (MASVS-AUTH-2, M3).
8. `catch (e) {}` that swallows a security-relevant failure (auth, decrypt, verification).
9. Biometric login that gates on a stored boolean rather than a hardware-backed key (§5, M3).
10. New third-party SDK added without an owner, a licence check, and a note on what data it
    receives (M2).

---

## 3. Storage — MASVS-STORAGE

Two tiers, and the split is the rule:

| Store | Backed by | Holds | Never holds |
|---|---|---|---|
| `AppStorage` (`app/storage/`) | `shared_preferences` | theme, locale, non-identifying UI prefs | anything in the "sensitive" list |
| `AuthStorage` (`core/storage/`, core-internal) | `flutter_secure_storage` (Keychain / Keystore) | access + refresh tokens (user and client-credentials) — read/written **only** by `SessionManager` | anything not session-token |
| `SecureAppStorage` (`app/storage/`) | `flutter_secure_storage` (Keychain / Keystore) | other secrets, session identifiers features need, any cached PII | — |

**Sensitive — extend per product:** access/refresh tokens, session ids, user credentials, personal
names, government identifiers (passport, NRIC, permit), financial terms tied to a person, biometric
templates and scores, face images, document scans, phone numbers, email and home addresses.

Rules:
- Core interfaces (`SecurePersistenceInterface`, `AuthStorage`, `LocalStorage`) are **core-internal**.
  Feature code consumes `AppStorage` / `SecureAppStorage` from `app/` only.
- iOS Keychain items: set an accessibility class no broader than
  `first_unlock_this_device` — never `always`, never synchronisable to iCloud for tokens.
- Android: `EncryptedSharedPreferences` via `flutter_secure_storage`, Keystore-backed.
- **Backups:** `android:allowBackup="false"` plus `dataExtractionRules`; on iOS exclude caches
  holding PII from iCloud backup.
- Image/document picks land in a **temp** directory — delete after upload; never leave a scan of a
  passport in app documents.
- **Reinstall:** iOS Keychain survives an uninstall while preferences don't — on the first launch after
  install, clear the secure session before restoring it.
- Clear everything sensitive on logout: `SessionManager.clear()` must wipe secure storage, not just
  flip a flag.
- **Session teardown seam.** Define a `SessionExternalCleanup` interface in `core/session/` with a
  no-op default that logs loudly; the app overrides it, and `SessionManager.clear()` calls it last so
  **every** teardown path runs it — voluntary logout, missing refresh token, refresh failure.
  WebView-based SSO must clear the WebView cookie jar there: a server `end_session` call is not
  enough, because its failure is swallowed and the involuntary paths never make it.

---

## 4. Network — MASVS-NETWORK

All traffic through `GenericApiService` (verb helpers) → `ApiTransport` → `DioTransport`. Security lives in
the transport, not in repositories.

- **TLS 1.2 minimum, 1.3 preferred.** No plaintext HTTP anywhere, including dev flavors — use a
  staging HTTPS host instead.
- **Certificate pinning** on your API and identity-provider hosts. Pin to the SPKI hash of an intermediate,
  not a leaf, and ship **two** pins (current + backup) so rotation cannot brick the fleet. Pinning
  failures must surface as a canonical `ApiException`, never as a silent retry loop.
- Android: an explicit `network_security_config.xml` with `cleartextTrafficPermitted="false"` and
  the pin set. iOS: no `NSAppTransportSecurity` exceptions; if one is unavoidable, scope it to a
  single domain and record why in the project's `READMEFIRST/SECURITY_BASELINE.md`.
- Never put PII, tokens, or identifiers in a **URL or query string** — they land in logs and proxies.
  Use the body.
- Interceptors log method, host, path, status, and duration only. Never headers, never bodies.
- Debug-only proxy/`HttpOverrides` helpers must be compiled out of release
  (`kReleaseMode` guard, or a `main_dev`-only wiring).

---

## 5. Auth, session and biometrics — MASVS-AUTH

- Tokens: short-lived access token, refresh in `AuthStorage` (secure tier, `SessionManager` only). The 401 single-flight
  refresh-retry in the transport stays the only refresh path; on failure `clear()` + canonical
  `AUTH_REFRESH_FAILED`.
- **Biometric login is not a login.** It must unlock a Keystore/Keychain-held credential:
  - iOS: Keychain item with `.biometryCurrentSet` access control.
  - Android: `setUserAuthenticationRequired(true)` and `setInvalidatedByBiometricEnrolment(true)`.
  - Consequence: enrolling a new fingerprint/face invalidates the key and forces a password login.
    A `bool biometricEnabled` in preferences provides **none** of this.
- Re-authenticate before high-consequence actions — submitting a signed contract, changing the
  registered mobile number, disabling biometrics.
- Enforce the server's session lifetime; add an idle timeout (lock the app, clear the in-memory
  session) for a field app that gets left unlocked.
- OTP/TAC: never log it, never prefill it from the clipboard automatically, rate-limit resends
  client-side as a courtesy while the server enforces it for real.

---

## 6. Platform & privacy — MASVS-PLATFORM / PRIVACY

**Screen capture.** Any screen showing personal data, contractual terms or biometric capture:
- Android: `FLAG_SECURE` on the window.
- iOS: no `FLAG_SECURE` equivalent — obscure the UI on `inactive`/`background` so the app-switcher
  snapshot is blank, and restore on `resumed`.
Apply narrowly and deliberately; blanket `FLAG_SECURE` breaks legitimate screen sharing in support
calls.

**Permissions — least privilege.** Declare only what is used, when it is used. `image_picker` needs
**no** Android camera or storage permission (system intent + Photo Picker) — do not add them. Every
iOS `NS*UsageDescription` must say truthfully what the data is used for; an unused declaration is
both an App Store risk and an OWASP finding.

**Clipboard / keyboard:** `autocorrect: false` and `enableSuggestions: false` on fields carrying
names, passport numbers and registration numbers — the keyboard cache is a data store. Passwords and
OTP fields must not be in the keyboard learning path.

**Components:** no exported Android activity/receiver/provider beyond the launcher. Deep links and
QR payloads are **untrusted input** — validate shape and authorise server-side before acting; a QR
code must never carry a signed decision, only a reference the server resolves.

**Local data-protection law (e.g. PDPA 2010, Act 854 in Malaysia):** collect the minimum, state the purpose at the point of capture, keep the
consent trail server-side, and make deletion a real code path rather than a UI state.

---

## 7. Logging and errors

- `GlobalLogger` only; no `print`/`debugPrint` in shipped code.
- Log the `developerMessage`; show the `userMessage`. The two never swap.
- Redaction is opt-out, not opt-in: assume a field is sensitive unless it is provably not.
- Crash/analytics SDKs inherit the same rule — a breadcrumb containing a passport number is a breach.

---

## 8. Supply chain and binary — MASVS-CODE / RESILIENCE

- Keep Flutter/Dart on a supported stable; a toolchain a year behind carries known CVEs. Record the
  pinned version (`.fvmrc`) so every build and CI agent agrees.
- Pin dependency versions; review `pubspec.lock` changes in PRs like code.
- Release builds: `--obfuscate --split-debug-info=<dir>`, symbols archived out of the repo.
- Root/jailbreak detection and anti-tamper are defence in depth for a field app handling biometric
  consent — expect bypass, use them for telemetry and step-up friction, never as the only gate.

---

## 9. Release gate

Run before any build leaves the team — UAT, pilot or production.

- [ ] Release signed with the real keystore/provisioning profile, not debug keys.
- [ ] `allowBackup=false` + data extraction rules; iOS caches excluded from backup.
- [ ] No cleartext; pinning active and tested against a proxy (build must **fail** to connect).
- [ ] Obfuscation on; symbols archived.
- [ ] Permission list == permissions actually used.
- [ ] Capture protection verified on the PII screens (screenshot attempt produces a blank frame).
- [ ] No secret in the bundle: `strings`/`grep` the built artefact for known key prefixes.
- [ ] Tokens verified present in Keychain/Keystore and **absent** from prefs, files and backups.
- [ ] Logs from a full happy-path run contain no PII or tokens.
- [ ] `flutter analyze` clean, tests pass, and the project's theme guard clean if it has one.

## 10. Quick scan

First pass over a diff or a fresh checkout. Hits are leads, not verdicts.

```bash
# Secrets and credentials in source
grep -rniE "(api[_-]?key|secret|passwd|password|token)\s*[:=]\s*['\"][^'\"]{8,}" lib android ios

# TLS weakened
grep -rniE "badCertificateCallback|NSAllowsArbitraryLoads|usesCleartextTraffic|ALLOW_ALL_HOSTNAME" lib android ios

# Sensitive data heading for the wrong store
grep -rniE "AppStorage|SharedPreferences" lib | grep -iE "token|password|passport|nric|biometric"

# Logging that should not exist
grep -rnE "\bprint\(|debugPrint" lib

# Platform misconfiguration
grep -rn "signingConfigs.getByName(\"debug\")" android/app/build.gradle.kts
grep -rn "allowBackup" android/app/src/main/AndroidManifest.xml
```

## 11. Review recipe

1. What data does this change touch, and is any of it in the sensitive list (§3)?
2. Where does that data come to rest — memory, prefs, secure store, disk, log, screen, network?
3. Which of those resting places survives: app backgrounding, backup, logout, uninstall?
4. What does an attacker with a rooted device and a proxy see?
5. Which control is defence in depth versus load-bearing? Say which is which.
6. Cite `file:line` + MASVS control + Top-10 category for every finding. Rank by exploitability
   against **this** product's threat model: state your own — who holds the device,
   on what network, and what the app can reach.

## 12. Adopting this skill in a project

On first adoption, and then on a fixed cadence:

1. Run the §10 quick scan and the §11 review recipe over the whole repo.
2. Write the findings to a `SECURITY_BASELINE.md` **in that project** — one row per finding, with
   status, severity and the file it lives in. Not here. Keep it beside the project's other
   non-code docs (e.g. a `READMEFIRST/` folder) rather than loose at the repo root.
3. Record the adoption, and any deliberate deviation from §2, in that project's `READMEFIRST/` notes.
4. Re-run before every release and update the baseline. A baseline that is never updated is worse
   than none: it reads as assurance while describing a codebase that no longer exists.

A project that cannot yet satisfy a §2 blocker (no API hosts for pinning, no SSO for real
biometrics) records it as **deferred with a trigger** — the event that unblocks it — rather than
quietly dropping it.
