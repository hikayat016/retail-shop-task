# Workflow — planning, building and recording decisions

Open this when planning a module from a PRD or design, starting a non-trivial change, or deciding
whether something needs a decision record. `SKILL.md` §14 is the per-feature checklist; this is the
process around it.

## 1. Pick the mode
- **Brownfield** — live code is the main source of truth (change, bugfix, refactor, review). If the
  repo already has a stable pattern for the case, copy it instead of inventing one.
- **Greenfield** — requirements, a PRD or designs are the main source of truth.
- **Bugfix:** find the originating layer, make a narrow fix, add the missing rule if one was missing.
- **Refactor:** preserve behaviour first; move code only when the target layer clearly owns it.

## 2. Sources of truth
- Design artifacts are truth for **UI only**, never for business rules.
- Explicit technical input (API contracts, auth rules) overrides anything generated or assumed.
- **Never invent** JSON schemas, endpoints, DTO fields, routes, auth rules, storage keys or business
  constraints. Where something is missing, use an obvious, easy-to-replace placeholder and log it
  (see §5).
- Docs vs code conflict: confirm what the code does. Intentional → update the docs/skill. Accidental →
  fix the code and record the rule. Unsure → log it and ask.

## 3. Before building
- Check whether existing providers, routes, storage wrappers or core widgets already own part of the
  change. Don't introduce a parallel pattern.
- Design **state, the ViewModel and the effect contract before the UI**; pull out the form object
  early for anything beyond a trivial form.

## 4. Planning modules from a PRD
- Draw module boundaries by **business capability** (see `architecture-rules.md` §2).
- Classify each shared service as hypothetical, already present, or misplaced — don't build the
  hypothetical ones.
- List app-shell responsibilities (launch, session, intro gate, deep links) separately from modules.
- Spot cross-cutting concerns early: auth, reference data, localization, analytics, security capture
  protection, offline/cache policy.
- **Missing-requirements checklist** before coding: API contracts and error shapes, auth mode per
  endpoint (user vs system service), pagination, validation rules, empty/error states, copy for every
  locale, analytics events, sensitive-data classification.
- **Build order across the app:** shell → auth → shared reference data → primary modules → secondary
  modules → hardening.
- **Build order inside a module:** data contract (DTO + repository pair) → providers → state + VM → UI
  shell → effects + navigation → validation → tests.
- Deliver in phases; each phase leaves `flutter analyze` clean and the app booting.
- **Plan output checklist:** modules with their bucket (`features/` vs `common/`), each module's
  screens, repositories and provider choice, routes, shared services, open questions, placeholders.

## 5. Decision records
Write one when a choice affects more than one file or layer, when two correct-looking options exist,
or when you add a deliberate placeholder or exception. Skip it when the rules already answer the
question or it's a local naming choice.

An entry has: **date, topic, context, options, choice (or "pending"), implications.**
- Portable rule changes → `flutter-template/DECISIONS.md` (then edit the skill and regenerate).
- Project-only deviations, placeholders and temporary exceptions → the project's `READMEFIRST/` notes.

**Temporary exceptions** are isolated, documented, kept out of generic layers (`core/`), and given a
cleanup path and trigger. Never promote one into a rule.

## 6. Generated planning artifacts
When a chain of generated artifacts is used (design analysis → technical input → PRD → module plan →
per-module context packs):
- Keep the PRD implementation-agnostic; architecture decisions belong to the module plan.
- Stale generated artifacts lose to this skill and to the code.
- Refine an artifact when the inputs changed slightly; regenerate when a source of truth changed.
- Check each stage's output against the previous stage before moving on — missing screens, invented
  fields and dropped requirements are the usual failure modes.
