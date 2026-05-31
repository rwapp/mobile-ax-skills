# Accessible mobile experiences — agent skills

A library of **agent skills** that help developers build *accessible native mobile
experiences* — not just accessible code — in **SwiftUI** and **Jetpack Compose**.

> **Status: early / experimental.** Conventions are still settling. Feedback and
> contributions welcome (see [CONTRIBUTING.md](CONTRIBUTING.md)).

## Why this exists

Agents already try to make UI code accessible. They do an okay job — but with a lot of
misunderstandings. Accessibility skills exist to help, and they do better than an agent alone, but
they tend to have two problems:

1. **They aren't grounded in accessibility expertise**, so while better than nothing, they often
   **overcomplicate** things.
2. **They're code-focused, not outcome-focused** — they aim at "code that looks accessible" rather
   than "an experience that actually works for a disabled person."

This collection aims to fix both. Each skill is built to produce **the most likely-accessible
*outcome***, in the **cleanest code** that achieves it — while accepting that accessibility is
ultimately about humans, and can only be confirmed accurately by a human experiencing the finished
product. The accessible *experience* is the goal; clean code is how we get there without the
overcomplication, not the goal itself.

## What makes these different

Most accessibility tooling scans finished code and emits a checklist of failures. These skills
are intended to generate accessible code in the first instance, and provide guidance to check the
agent's output — keeping **humans at the centre**:

- **Build-time, not audit-time.** A skill loads *while the agent authors a view* and builds it
  accessibly the first time — because you can't add the blueberries to a muffin you've already
  baked.
- **Organised by what you're building, not by spec rules.** Each skill is about a developer
  action — *adding an image*, *adding a button* — and brings the relevant WCAG criteria along as
  an attribute of that action, never the other way around.
- **Experience, not just code, with an honest hand-off.** An agent can't experience the app it
  builds or be certain it read the author's intent. So rather than pretend otherwise, the skill
  has the agent report back in plain language — here's the intended experience, why it matters,
  and how to verify it — and ask the developer to confirm. That hand-off is the primary deliverable.
- **Progress over perfection.** Verification steps are prioritised and led by a single
  *"Start here"* item, so a developer with limited time knows where it matters most.
- **Agent-agnostic.** Plain-Markdown skills in the emerging `SKILL.md` convention; no
  dependence on any one agent's tools or hooks.

## Repository layout

```
skills/<platform>-<topic>/   # one atomic skill per topic (e.g. swiftui-images)
  SKILL.md                   # frontmatter + authoring guidance + decision summary + output contract
  references.md              # WCAG / how-to / blog / video links, cited by anchor
  decision-tree.md           # fuller classification nuance + edge cases
  examples/                  # before/after fixtures showing what "good" looks like
templates/                   # copy-to-start template for new skills
DECISIONS.md                 # why the conventions are what they are (ADR-style)
CONTRIBUTING.md              # how to add or change a skill
CHANGELOG.md                 # repo-level release history
```

## How an agent uses a skill

Skills load and trigger the usual way (via each skill's `description`). What's specific here is
the output: as it builds, the agent applies the skill's decision logic — asking the developer when
something is genuinely ambiguous — and then produces a short summary in chat plus an upserted
`ACCESSIBILITY-TESTPLAN.md` in the developer's repo, with instance-specific, prioritised
verification steps and links.

## Skills

| Skill | Platform | Topic | Maturity |
|-------|----------|-------|----------|
| [swiftui-images](skills/swiftui-images/) | SwiftUI | Images & SF Symbols | experimental |

Maturity reflects how proven a skill is, independent of the collection version.

- **experimental** — early; the guidance works but hasn't been widely used or reviewed, and may
  change. Try it, but verify the output carefully.
- **stable** — reviewed and used enough to rely on; changes will be more conservative.

What earns promotion to *stable* is defined in [CONTRIBUTING.md](CONTRIBUTING.md#quality--maturity).

## Versioning

The whole collection shares **one version** (fixed versioning), held in the root
[`VERSION`](VERSION) file and stamped identically into every `SKILL.md`'s `version:` frontmatter.
The `version:` line is machine-managed, don't hand-edit it. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the release process.

## License

[MIT](LICENSE). Use it, modify it, ship it in commercial projects — no warranty, no liability.
