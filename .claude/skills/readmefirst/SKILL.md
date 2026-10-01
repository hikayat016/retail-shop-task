---
name: readmefirst
description: >-
  Non-code docs and builds live in one READMEFIRST/ folder at the repo root: index, notes, security
  baseline, tester notes, builds, plus the writing rules. Use when writing or moving any non-code
  document (notes, handover, onboarding, release notes, changelog, tester instructions, decisions)
  or staging a build for someone else to install.
metadata:
  standards: internal convention
---

# READMEFIRST — where non-code information lives

## 0. The rule

Everything about a project that is **not** source code and not an in-code comment goes in one
folder at the repo root:

```
READMEFIRST/
├── README.md              # index — what is here, current state, who should read what
├── MOCKUP_NOTES.md        # or ARCHITECTURE_NOTES.md — what is real vs. stubbed, decisions, deviations
├── SECURITY_BASELINE.md   # status against the security skill (never the rules themselves)
├── TESTER_NOTES.md        # hand to testers alongside a build
└── builds/                # distributed artifacts, gitignored
```

The repo root keeps only: source, `pubspec.yaml`/manifest, platform folders, and a **short**
`README.md` that summarises and points here.

**Why one folder.** Loose `NOTES.md`, `TODO.md`, `SECURITY.md`, `dist/` at the root are invisible:
nobody knows which exist, which are current, or which to read first. One folder with an index makes
the set discoverable and makes staleness obvious.

Not a rigid list — add files the project needs (`API_NOTES.md`, `RELEASE_CHECKLIST.md`). The rule is
the **location and the index**, not the filenames.

## 1. The index is mandatory

`READMEFIRST/README.md` is the first thing anyone reads. It must answer, in this order:

1. **What this is** — one paragraph, including whether it is a mockup, a prototype or production.
2. **A table of the files** and what question each one answers.
3. **Current state** — latest build, environments, what hardware it has actually been verified on.
4. **"If you are a…"** — tester / picking up the code / reviewing security / cutting a release.
5. **What is not done** — the two or three things a newcomer would otherwise discover the hard way.

Every other file in the folder opens with a one-line pointer back:

```markdown
> Part of `READMEFIRST/`. See [README.md](README.md) for the index.
```

so a file read in isolation still leads to the rest.

## 2. The root README stays a summary

It is what someone sees first on the host. Keep it short and make it hand off:

- what the product is and who operates it
- why it exists — the problem, in two or three sentences
- the stack, as a table
- how to run it
- **what is real and what is not**, if anything is simulated
- a "Read next" section linking into `READMEFIRST/`

Never duplicate detail between the root README and `READMEFIRST/`. Two copies of a fact become two
different facts.

## 3. Builds

`READMEFIRST/builds/`, gitignored, named so the file alone identifies itself:

```
<Product>-<ENV>-v<version>-<YYYYMMDD>.apk
```

Every staged build has a checksum in `TESTER_NOTES.md` that **matches the file on disk**. Verify it
after every restage — a stale checksum is worse than none, because it looks like assurance:

```bash
shasum -a 256 READMEFIRST/builds/*.apk
```

Signing material (`key.properties`, `*.jks`, `*.p12`) is **never** in this folder and never
committed.

## 4. Writing rules

These are the ones that actually get violated.

1. **Say what is not done.** A document listing only capabilities reads as a product claim. State
   the gaps, the simulated parts, and what has never been tested — especially the platform or device
   nobody has tried.
2. **Edit in place; never append a correction.** Appending leaves both statements in the file, and a
   reader believes whichever they hit first. In a security document that is actively dangerous.
   Before adding a paragraph, search for the one it supersedes and replace it.
3. **Verify your edit landed.** A formatter may have reflowed the text a scripted replace was
   matching, so the replace silently does nothing and the file keeps its old claim. Assert the
   match, then re-read what you wrote.
4. **Counts and versions go stale silently.** "four flavors", "Flutter 3.38.3", "five endpoints" —
   grep for them whenever the underlying thing changes.
5. **Record the why, not just the what.** "PILOT blocks screen capture" is a fact; "PILOT is
   pre-production but runs against real worker data, so it takes the production posture" survives
   the next person asking to turn it off.
6. **Date decisions and name the deciding party** when a document contradicts an approved spec — a
   proposal, an SOW, a regulator-facing document. Say plainly that the other document now needs
   updating; do not quietly diverge.
7. **Findings go in the project, rules go in the skill.** A baseline file holds this project's
   status. Never copy a project's findings into a portable skill.

## 5. When to add a file vs. extend one

Extend an existing file when the new information answers a question that file already answers. Add a
new file when a distinct audience would read it on its own — testers, security reviewers, whoever
runs releases. If you cannot name that audience, it is a section, not a file.

Adding a file means adding a row to the index in the same change. An unlisted file does not exist.

## 6. Verification

Run after touching anything in the folder:

```bash
# Links resolve
python3 - <<'PY'
import os, re
for root, _, files in os.walk('READMEFIRST'):
    for f in [x for x in files if x.endswith('.md')]:
        p = os.path.join(root, f)
        for l in re.findall(r'\]\(([^)]+)\)', open(p).read()):
            if l.startswith(('http', 'mailto', '#')):
                continue
            if not os.path.exists(os.path.join(root, l.split('#')[0])):
                print('BROKEN', p, '->', l)
print('link check done')
PY

# Checksum in the notes matches the artifact on disk
shasum -a 256 READMEFIRST/builds/*

# Stale version/count claims after a bump
grep -rn "<old version>" READMEFIRST *.md
```

## 7. Adopting this in a project

1. `mkdir -p READMEFIRST/builds`, move every loose non-code markdown and any `dist/` into it.
2. Write the index (§1) and add the pointer line to each moved file.
3. Trim the root README to a summary that links here (§2).
4. Gitignore `READMEFIRST/builds/`.
5. Re-read the moved files end to end **once** — consolidation is when contradictions surface, and
   fixing them then is far cheaper than leaving them for a reader to trip over.
