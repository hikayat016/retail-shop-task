---
description: "Use when touching auth, tokens, sessions, biometrics, secure storage, networking, TLS, permissions, deep links, WebView, logs, release signing, screenshots, PDPA, Act 854, OWASP, MASVS, or penetration-test findings."
---

# Flutter Mobile Security

Use `.github/skills/flutter-mobile-security/SKILL.md` before changing security-sensitive code.

Essential rules:

- Security guidance outranks convenience and general architecture guidance where they conflict.
- Keep tokens, credentials, and sensitive identifiers out of normal preferences, logs, screenshots, crash reports, and generated docs.
- Use the project secure storage abstraction for secrets; use normal app storage only for non-sensitive preferences.
- Route network behavior through the existing transport/service abstractions so TLS, headers, error normalization, and logging remain centralized.
- Do not surface developer diagnostics to users.
- Treat worker personal data as sensitive. Minimize persistence, logging, and display exposure.
- Update `READMEFIRST/SECURITY_BASELINE.md` when security posture, release gates, or known residual risks change.
