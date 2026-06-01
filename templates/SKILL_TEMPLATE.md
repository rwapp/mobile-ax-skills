---
name: <platform>-<topic>            # e.g. swiftui-images. Lowercase, hyphenated, unique.
description: <one sentence trigger> # The only thing the agent sees before loading. Must clearly say
                                    # when to load this (build-time, what platform, what UI element) and
                                    # not fire on unrelated work. e.g. "Use when building or adding an
                                    # Image or SF Symbol in SwiftUI, to make it accessible from the start."
version: 0.1.0                      # Collection version (same in every skill). Machine-managed — do
                                    # not hand-edit. The release workflow stamps it from /VERSION.
wcag: "2.2"                         # WCAG version targeted. The specific SCs cited are named by
                                    # the author at generation time (see references.md), never
                                    # chosen by the agent.
platform: swiftui                   # swiftui | compose. One platform per skill.
license: MIT                        # Repo license. Keep self-identifying when the folder is vendored.
---

# <Skill title>

> One-paragraph statement of what this skill helps the **agent** build, and the
> **experience** it protects for the **end user**. Remember the three roles:
> **developer** (writes the app, reads the report, runs the assistive technologies),
> **agent** (you, building the code), **end user** (a person with a disability using the app).

This is a **build-time** skill: it guides the agent *while authoring* a view so accessibility is
built in from the start, not retrofitted. It is **not** a scanner or audit. After building,
the agent **must** produce the output below — that hand-off to the developer is the
primary deliverable, because the experience can only be fully verified by a human.

## When this applies

<Bullet the situations that load this skill, and the situations that do *not* (point to sibling skills instead).>

## How to decide what to build (compact decision summary)

<The core classification/decision branches, inline, so the agent always sees them.
Keep it short; push edge cases to decision-tree.md.>

- If <condition> → <treatment>
- If <condition> → <treatment>
- **Can't tell from context? → Ask the developer before applying.** (Accessibility correctness
  over guessing. Only ask when genuinely ambiguous.)

See `decision-tree.md` for edge cases and nuance.

## Code treatments

<Concrete, minimal code for each branch above.>

## Required output (the deliverable)

After building, the agent **must** produce **both** surfaces. This is fixed across all skills.

### 1. Chat (short hook) — 2–4 sentences
- A one-line note of what was built (the developer can see the diff — keep it brief), and that
  it was built with accessibility in mind. This is the only place a "what I did" summary belongs.
- A pointer to `ACCESSIBILITY-TESTPLAN.md`.
- A one-line ask to **verify with the relevant assistive technologies** (AT-neutral — do
  not say "with VoiceOver" as if it were the whole of accessibility).

### 2. `ACCESSIBILITY-TESTPLAN.md` in the developer's repo (durable)
**Upsert by component section** — find the heading for this screen/component and update it;
do not blindly append. The file must always reflect the current state.

Fill these four headers with **instance-specific** content (no generic boilerplate). Lead with
the experience — it's what the developer is here to verify; don't restate the diff.

The file opens with a one-time **preamble** that explains "Start here" and the priorities *once*,
so those don't repeat under every component. Write it only when creating the file; if the file
already exists, leave the preamble alone and just upsert this component's section.

```markdown
# Accessibility test plan

**About this plan.** Each component below lists a ⭐ *Start here* check — the single highest-impact
thing to verify first. It's a starting point, not a full audit: working through everything here
doesn't by itself guarantee the screen is accessible.

Each check has a priority — the impact on someone using assistive technology if that treatment is
wrong:

- **P1 — Blocker:** the end user cannot complete the task.
- **P2 — Significant impact:** major friction or confusion, but the task is still possible.
- **P3 — Noticeable impact:** a smaller annoyance or rough edge.
- **P4 — Doesn't follow best practice:** works, but isn't ideal.

---

## <Screen / component name>  (updated <YYYY-MM-DD>)

### Intended accessibility experience
<What the end user should perceive — across the relevant ATs.>

### How to verify it yourself
⭐ Start here: <single highest-impact check for this instance, in plain language.>

- **P1 — Blocker**
  - With <AT>: <what to do> → <what to look for>
- **P2 — Significant impact**
  - With <AT>: <what to do> → <what to look for>
- **P3 — Noticeable impact** / **P4 — Doesn't follow best practice**
  - ...

### WCAG
- <[ref-anchor]>: <criterion> — why it applies here   (link comes from references.md)

### Learn more
- <[ref-anchor]>: <what it teaches>                    (link comes from references.md)
```

**AT-neutrality:** name the assistive technologies that actually matter for *this* instance,
ranked, each with what to look for — they behave differently (e.g. a screen reader announces
a label; a voice-control tool uses that same label as the spoken activation phrase). Name **only
your own platform's** stack, never the other's:
- **Apple (SwiftUI):** VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type.
- **Android (Compose):** TalkBack, Voice Access, Switch Access, Keyboard Access.
A purely decorative element should be verified as **not focusable by any AT**.

**Judging severity (general method):** to assign a P-level, ask *"if I got this treatment wrong,
what can the end user no longer do?"*
- They **can't complete the task** → **P1**.
- They can, but with **major friction or confusion** → **P2**.
- **Minor** annoyance / rough edge → **P3**.
- It works but **isn't best practice** → **P4**.
Severity is about the end user, not where the element sits — a blocker is P1 wherever it lives.
WCAG conformance level is a useful prior when severity is unclear (Level A skews toward P1, AAA
toward P4), but the user-impact question above decides.

## Severity guidance for this skill

<Replace this with per-situation anchors for *this* skill's decisions, so the agent can rank
without re-deriving each time — e.g. "decorative element → usually P2 unless it steals focus from
something critical; element carrying the only copy of needed information → often P1." Mirror the
branches in the decision summary above. Keep it short.>

**References:** cite by anchor (e.g. `[wcag-1.1.1]`) defined in `references.md`, which declares
the WCAG criteria and docs this skill covers. Cite only what's declared there for the branch you
took. **Never choose a criterion or doc of your own, and never invent a URL.** If a slot has no
URL yet, name it and note the link is pending.

> **Authoring note (for whoever generates this skill):** a skill is organised around a **developer
> action** (e.g. "adding an image"), never around a WCAG criterion — the action is the entry point.
> But **at least one WCAG SC is required** as the *backing*: it's what makes the guidance
> evidence-based rather than opinion (a skill citing no SC is vanity). The SCs are a **required
> input to the generation prompt** — name them action-first (e.g. "a skill for adding images
> accessibly, following WCAG 2.2 SCs 1.1.1, 1.4.5 & 4.1.2"). The generating agent records exactly
> those and must **refuse to generate the skill if none are given**. It never infers, adds, or
> drops criteria. See CONTRIBUTING / DECISIONS #1a.
