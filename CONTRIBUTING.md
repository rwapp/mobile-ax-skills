# Contributing

Thanks for helping build human-centered accessibility skills. This guide defines the
conventions every skill must follow so the library stays coherent and reviewable.

Read [DECISIONS.md](DECISIONS.md) first if you want the *why* behind these rules.

## Core philosophy (don't lose this)

The project exists to fix two flaws in existing accessibility skills: they **overcomplicate**
(not grounded in accessibility expertise) and they're **code-focused, not outcome-focused** (see
[DECISIONS.md](DECISIONS.md) #0). Hold these:

- **Experience, not just code.** A skill's job is not only to emit correct code — it's to
  protect the **end user's experience** and hand the **developer** a clear, human-readable way
  to verify it. If your skill only outputs code, it isn't done. **This is the primary goal.**
- **Cleanest code that achieves the outcome — but secondary.** Favour the simplest correct
  treatment; an over-engineered "accessible" solution is its own failure (it's the overcomplication
  flaw in disguise). But never trade away the accessible experience for tidier code, and never let
  "clean code" become the point. Experience first, simplicity second.
- **Grounded in real accessibility understanding.** Guidance must reflect how accessibility
  actually works, not plausible-sounding invention. If you aren't sure a treatment is correct,
  find out or flag it — don't ship confident guesses. This is the quality bar.
- **Build-time, not audit-time.** Skills run *while the agent authors a view*, not as a
  post-hoc scanner.
- **Progress over perfection.** Help the developer spend limited time where it matters; never
  imply that one check (or this skill alone) makes an app "accessible".

## The three roles — use these words

Be precise and consistent throughout every skill:

- **developer** — writes the app, reads the report, runs the assistive technologies.
- **agent** — builds the code and produces the report.
- **end user** — a person with a disability using the app.

Do **not** use "user" ambiguously, and do **not** use "prompter".

## Adding a skill

**Frame the skill around a developer action, backed by at least one WCAG criterion.** Two rules,
both required:

- **Action is the entry point.** The unit is *a thing a developer or agent does while building an
  app* — "adding an image", "adding a button". Name the skill by the action (`swiftui-images`),
  never by a criterion (`swiftui-1.1.1`). No dev thinks "I must satisfy 4.1.2"; they think "I'm
  adding an icon — what does accessibility need here?"
- **At least one WCAG SC is required, as backing.** It's what makes the guidance evidence-based
  and standards-backed rather than opinion — a skill that cites no SC is vanity, not meaningful
  advice. The SC is the authority the guidance rests on, not the subject of the skill.

So: action-first, SC-backed. This keeps the library build-time and human-centered rather than
audit-shaped (see [DECISIONS.md](DECISIONS.md) #1a). It's also why a single SC can't *be* a skill —
e.g. 4.1.2 spans images, buttons, toggles and fields.

1. Copy `templates/SKILL_TEMPLATE.md` to `skills/<platform>-<topic>/SKILL.md` and
   `templates/references.template.md` to `skills/<platform>-<topic>/references.md`.
2. Keep skills **atomic** — one folder per topic (images, buttons, dynamic type…). Cross-link
   sibling skills rather than growing one mega-skill.
3. Fill in the frontmatter (see below), the decision logic, the code treatments, and the
   required output contract.
4. Add a `decision-tree.md` for edge cases, and at least one `examples/` fixture
   (see [Quality & maturity](#quality--maturity)).
5. Add a row to the Skills table in `README.md` (maturity **experimental** — see below) and an
   entry to `CHANGELOG.md`.

### Frontmatter (required, self-identifying)

```yaml
name: swiftui-images
description: <one-sentence trigger>
version: 0.1.0         # machine-managed — do NOT hand-edit (stamped from /VERSION; see Versioning)
wcag: "2.2"
platform: swiftui      # one platform per skill
license: MIT
```

The `description` is the **only** thing the agent sees before deciding to load the skill. It
must clearly state *when* to load (build-time, which platform, which UI element) and not fire
on unrelated work. The frontmatter must remain self-describing so a vendored copy is
identifiable without this repo's git history.

Leave `version:` at whatever the template carries — it's the shared collection version, stamped
automatically and verified by CI, so don't set or bump it by hand (see [Versioning](#versioning-fixed--single-collection-version--automated)).

## The required output contract (fixed across all skills)

Every skill makes the agent produce **two surfaces** (see the template for exact shape):

1. **Chat (short hook)** — 2–4 sentences: a one-line note of what was done (the developer can see
   the diff — keep it brief), that it was built **with accessibility in mind** (not a claim that
   it *is* accessible — only verification can establish that), a pointer to the test plan, and an
   AT-neutral ask to verify.
2. **`ACCESSIBILITY-TESTPLAN.md`** in the developer's repo — **upserted by component section**
   (update the component's heading, don't blindly append) with four headers, experience-first:
   *Intended accessibility experience*, *How to verify it yourself*, *WCAG*, *Learn more*. Do **not** add a
   "what I changed" section — the diff/commit already records that; the brief "what I did" lives
   only in the chat hook.

### AT-neutrality (required)

Do not reduce accessibility to VoiceOver or TalkBack. Different end users rely on different assistive
technologies and they respond **differently** to the same code. In chat use AT-neutral language
("assistive technologies"); in the test plan name the ATs that matter **for that instance**,
**ranked**, each with what to look for. Example: a screen reader announces a label, but Voice
Control / Voice Access uses that same label as the phrase the end user must *speak* to activate
the control — so a label can pass with a screen reader and still break voice control.

- SwiftUI skills name the Apple stack (VoiceOver, Voice Control, Switch Control, Dynamic Type).
- Compose skills name the Android stack (TalkBack, Voice Access, Switch Access).

### Prioritization (required)

The "How to verify" section must:

- Lead with one **"Start here"** check — the single highest-impact thing to confirm for this
  instance — framed as *where to begin*.
- Rank the remaining checks **P1–P4** by **severity** — how badly the end user is affected if the
  agent got *this treatment* wrong — **not** a found defect and **not** a WCAG conformance level:
  - **P1 — Blocker** (end user can't complete the task), **P2 — Significant impact**,
    **P3 — Noticeable impact**, **P4 — Doesn't follow best practice**.
- **Severity is about the user, not the location.** If an issue blocks the end user, it's P1
  *wherever it lives* — being stuck on a buried screen is still being stuck. Don't lower a
  blocker's severity because the screen is rarely visited; how *often* a screen is reached is a
  separate concern (it can guide where the developer *starts*, but it doesn't change the P-number).
- Conformance level is a **useful prior, not the rule.** WCAG levels broadly encode severity
  (Level A = fundamental/blocking, AAA = enhancement), so when severity is unclear a Level A
  failure usually outranks a AAA one. Let level nudge, not decide — rank by actual user impact.
- It is normal for most items to land at P2.

The meta-explanations — that "Start here" is **not** a sufficiency guarantee, and the P1–P4
legend — live **once** in a file preamble at the top of `ACCESSIBILITY-TESTPLAN.md` (written when
the file is first created), **not** under every component. This keeps a growing file from
repeating the same caveat dozens of times. See the
template for the exact preamble wording.

## References — humans choose them, the agent never does

The agent must never decide *which* WCAG success criteria or documentation a skill cites, nor
invent their URLs. Both the relevance mapping and the URLs are **human** authoring decisions.

**WCAG success criteria are a required input to skill generation** — but as an *attribute of the
action*, not the subject of the skill (see [DECISIONS.md](DECISIONS.md) #1a). Lead with the action
and name the SCs that apply to it, e.g.:

> "Generate a skill for **adding images accessibly in SwiftUI**, following WCAG 2.2 SCs
> 1.1.1, 1.4.5 & 4.1.2."

Phrasing it criterion-first ("generate a skill for WCAG 4.1.2") is the audit-shaped framing this
project avoids — describe the action, attach the criteria.

- The generating agent records **exactly** the SCs you named — it must not infer, add, or drop
  criteria. If it thinks another SC is relevant, it may say so for *you* to decide; it must not
  add it itself.
- **If a generation prompt names no SCs, the agent must refuse to generate the skill** and ask
  which criteria apply. No skill ships with agent-chosen criteria.

**Links** live in the skill's `references.md` as **named, described anchor slots**, cited from
`SKILL.md` by anchor (e.g. `[wcag-1.1.1]`). Two kinds, handled differently:

- **WCAG SC URLs — derived and CI-checked.** The Understanding-doc URL is built deterministically
  from the (human-specified) SC number via the canonical [`wcag-slugs.yml`](wcag-slugs.yml) map:
  `https://www.w3.org/WAI/WCAG22/Understanding/<slug>.html`. Because this is a lookup, not a
  judgement, the agent *may* fill these — and CI (`scripts/check-references.sh`) verifies every
  WCAG URL matches the map and resolves, so a wrong/guessed slug fails the build. If an SC isn't
  in the map, add it there with a slug verified against w3.org — never invent one.
- **All other links** (how-to / demo / blog / video) are **entirely human-authored.** When
  generating a skill, the agent must add **no entries at all** for these — not the slot, not a
  placeholder, not a URL. Choosing *which* docs a skill cites is a human decision, just like
  choosing the SCs. The contributor adds and verifies them.
  - **Useful escape valve:** if the generating agent knows resources that could genuinely help
    (a good VoiceOver demo, a Voice Control explainer, an alt-text guide), it should **list them
    in chat as suggestions, clearly marked as unverified**, for the author to check and add by
    hand. Suggesting is not declaring — suggestions never go into `references.md` directly.
  - **Preferred source:** [Appt.org](https://appt.org/en/) — platform-specific mobile-accessibility
    documentation (iOS/SwiftUI, Android/Compose) with code examples and real assistive-technology
    usage data. Prefer it when adding (or suggesting) how-to / learning references and it covers
    the topic. It's a strong default, not a requirement — verify the specific page before adding.
  - Once a human *has* added a slot, the run-time agent treats a blank URL as pending (cites it by
    name, notes the link is pending) and **never invents** the URL.
- At run time the agent only cites references the skill **already declares** for the branch it
  took — it never introduces a criterion or doc the skill didn't author.

## Versioning (fixed / single collection version — automated)

This library uses **one version for the whole collection** (fixed/locked versioning, like
Angular or Babel), stamped identically into every `SKILL.md`'s `version:` frontmatter so a
vendored skill folder stays self-identifying even when separated from this repo's git history.

- **Canonical source:** the root [`VERSION`](VERSION) file.
- **Do not hand-edit `version:` in any `SKILL.md`.** It is machine-managed. A CI check
  (`.github/workflows/check-versions.yml`) fails any PR whose skill versions drift from `VERSION`.
- **Cutting a release** (maintainers): run the **Release** workflow from the Actions tab and
  choose the [semver](https://semver.org/) bump — *patch* (wording/link fixes), *minor* (new
  guidance/treatments or a new skill), *major* (a change that alters the code or experience a
  previous version produced). The workflow bumps `VERSION`, stamps every `SKILL.md`, updates the
  CHANGELOG heading, commits, tags `vX.Y.Z`, and creates a GitHub Release.
- **Locally**, `scripts/stamp-version.sh` stamps `VERSION` into every skill, and
  `scripts/stamp-version.sh --check` verifies they're in sync.

Trade-off accepted: because all skills share one version, the number doesn't tell a consumer
whether the *specific* skill they use changed — the CHANGELOG does. For a curated, coherent
library this is the right simplicity (see [DECISIONS.md](DECISIONS.md) #10).

## Quality & maturity

Quality bar conventions are **still being defined** (see DECISIONS.md). For now:

- Include at least one `examples/` fixture: a `Before` (untreated), an `After` (correct
  treatment), and an `expected-experience.md` describing the intended AT experience and the
  prioritised verification steps a correct run should produce. **Trap cases** — inputs that
  look alike but need opposite treatments — are especially valuable.
- A human running the relevant assistive technologies on the result is the ultimate check.

### Maturity

Each skill carries a **maturity** in the [README](README.md) Skills table — how proven it is,
independent of the shared collection version:

- **experimental** — early; the guidance works but hasn't been widely used or reviewed, and may
  change. **New skills start here.**
- **stable** — reviewed and used enough to rely on; changes will be more conservative.

What earns promotion to **stable** is part of the quality bar that's still being defined — likely
a combination of expert review, fixtures (including trap cases), and real-world use confirmed with
assistive technology. Until that's settled, only promote a skill to *stable* by maintainer
agreement, not unilaterally.

## An honest limitation

A skill is instructions to a probabilistic system; we **cannot hard-guarantee** the agent
emits the report. We raise the floor by framing the test plan as the primary deliverable,
giving an exact fill-in template, and requiring fixed headers. An agent-specific hook *could*
enforce it but would not be portable, so it is intentionally out of scope for the
agent-agnostic core.
