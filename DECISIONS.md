# Design decisions

ADR-style log of why the conventions are what they are, so contributors understand the intent
and can challenge it deliberately rather than by accident. Newest decisions can be appended.

## 0. The problem this collection answers

**Problem statement:** Agents already try to make UI code accessible, and do an okay job — but
with many misunderstandings. Accessibility skills exist to help and beat the agent alone, but have
two recurring flaws: (1) they aren't grounded in accessibility expertise, so they **overcomplicate**;
(2) they're **code-focused, not outcome-focused** — aiming at code that looks accessible rather
than an experience that works for a disabled person.

**Aim:** Skills that produce the **most likely-accessible *outcome***, in the **cleanest code**
that achieves it, while accepting that accessibility is about humans and can only be confirmed
accurately by a human experiencing the finished product.

**Two principles that follow (both are project values, with a clear ranking):**

- **Primary — accessible experience is the goal.** Everything else serves this. (This is the root
  of #1, #1a, #1b.)
- **Secondary — clean, minimal code is how we get there.** The produced code should be the
  simplest that achieves the outcome. This is a deliberate counter to flaw (1): an over-engineered
  "accessible" solution is its own failure. But it is explicitly *secondary* — never trade away the
  accessible experience for tidier code, and never let "cleanest code" become the point.
- **Provenance — guidance must be grounded in real accessibility understanding** (counter to flaw
  (1)): skills should reflect how accessibility actually works, not plausible-sounding invention.
  This sets the quality bar for contributions (see CONTRIBUTING).

**Why state it:** the rest of this log records the *solution*; naming the two flaws keeps the
project from drifting back into them.

## 1. Skills are human-centered and build-time, not audit-time

**Decision:** A skill is loaded *while the agent authors a view* and builds it accessibly the
first time, then hands the developer a plain-language report on the intended experience and how
to verify it. It is not a code scanner that emits a checklist.

**Why:** Two reasons. First, accessibility is about humans using assistive technology — something
an agent can't fully verify — so the *experience* and the human verification hand-off are the gap
code-focused skills leave. Second, **retrofitting is always harder than building it in** — you
can't add the blueberries to a muffin you've already baked; fixing wrong structure/labels/semantics
later means reworking code that already "looks done".

## 1a. Skills are organised by developer action, not by WCAG criterion

**Decision:** Two things are true at once, and both are load-bearing:

- **The action is the entry point.** The unit of a skill is a *thing a developer or agent does
  while building an app* — "adding an image", "adding a button", "building a selectable list". A
  skill is **always** framed and named by its action, even when the action maps cleanly to one
  criterion. SCs are never the unit.
- **At least one WCAG SC is the backing — and is required.** Every skill must cite ≥1 SC. The SC
  is what makes the guidance *evidence-based and standards-backed* rather than one person's
  opinion; a skill with no SC is vanity, not meaningful accessibility advice. So the SC is the
  authority the guidance rests on — surfaced once the developer is already doing the action.

So: action is the entry point, the SC is the backing. Required, but never the organising unit.

- **Good:** a skill for *adding an image*, backed by SCs 1.1.1, 1.4.5, 4.1.2.
- **Not allowed:** a skill "for WCAG 4.1.2"; a skill named by criterion (`swiftui-4.1.2`); a
  generation prompt that leads with the criterion; a skill that cites **no** SC.
- The author specifies the SCs at generation (per #9) — as criteria that *apply to the action*,
  phrased action-first: "a skill for adding images accessibly, following SCs 1.1.1, 1.4.5 & 4.1.2."

**Why:** No one thinks "I must satisfy 4.1.2"; they think "I'm adding an icon — what does
accessibility need here?" So the action is the entry point — but the answer must rest on a
standard or it's just opinion, hence ≥1 SC as backing. Organising *by* criterion would be
audit-shaped thinking, turning the library into the linter we're not building — and it doesn't
even work mechanically: one SC like 4.1.2 spans images, buttons, toggles and fields.

## 1b. The differentiator is the honest hand-off, not the code generation

**Decision:** What sets this project apart from other accessibility skills is **not** that it
generates better accessible code — it's that it makes the agent **own its limits and hand off to a
human for verification.** Every skill must produce that hand-off: *"I've built this as accessibly
as I can, but I'm an agent — I can't experience the running app and can't be certain I understood
your intent. Here's the experience I was aiming for, why it matters, and how to check it — please
verify."* The verification loop is the deliverable; the code is table stakes.

**Why:** Other skills (including good community ones) already generate accessible code well, so
"we generate accessible code" is no reason to exist. The genuine gap is what an agent *can't* do
alone — perceive the built app, or be sure it read the author's intent — and a skill that stops at
the code pretends those limits away. Closing that gap honestly is the thing only this approach
does. Frame it as *complementing* code-generation skills, not competing: they do the code; this
does the verification they leave out.

## 2. Atomic skills

**Decision:** One folder per topic (`skills/<platform>-<topic>/`), cross-linking siblings,
rather than one mega-skill.

**Why:** Easier to reason about in isolation, easier to contribute and review one folder at a
time, and scales to a large catalogue. A shared template keeps them consistent.

## 3. Three explicit roles: developer / agent / end user

**Decision:** Standardise on these three terms everywhere; avoid ambiguous "user".

**Why:** The domain has three distinct actors and conflating them makes guidance
unclear. "end user" must stay reserved for the person with a disability.

## 4. Required, fixed output contract

**Decision:** Every skill makes the agent emit the same report — short hook in chat, full detail
in an `ACCESSIBILITY-TESTPLAN.md` in the developer's repo. The durable file has four sections,
**experience-first**: *Intended accessibility experience*, *How to verify it yourself*, *WCAG*, *Learn more*.

**Why:** Consistency across contributors, and it operationalises decision #1. A fixed
fill-in-the-blank template is the most reliable way to get a probabilistic agent to comply.

**Refined:** an earlier draft had five sections led by "What I changed". Dropped it from the
durable file — it restated the diff/commit (noise in a doc that's re-read over time, and the kind
of verbosity that makes people stop reading). The brief "what I did" now lives only in the
ephemeral chat hook. The *experience* leads, since that's what the developer is there to verify.

## 5. Test plan is upserted by component section

**Decision:** Re-running a skill updates that component's section rather than appending.

**Why:** The file should always reflect current state. Append-only logs rot and contradict
themselves. Respects that verification is asynchronous — the developer reads it when they can.

## 6. Ask when genuinely ambiguous

**Decision:** If intent can't be inferred from context (e.g. decorative vs. meaningful image),
the agent asks the developer rather than guessing.

**Why:** Confidently-wrong accessibility is actively harmful. A little friction beats a wrong
treatment. The bar is *genuine* ambiguity, not every decision.

## 7. AT-neutrality

**Decision:** Don't reduce accessibility to VoiceOver. Chat language is AT-neutral; the test
plan names the assistive technologies relevant to the instance, ranked, with what to look for.

**Why:** Different end users use different ATs that behave differently with the same code (e.g.
screen reader vs. Voice Control treatment of labels). Optimising only for a screen reader leaves
people out.

## 8. Prioritization: "Start here" + P1–P4 by impact-if-wrong

**Decision:** Verification leads with one "Start here" item (explicitly *not* a sufficiency
guarantee), then ranks the rest P1–P4 by **severity**: **P1 — Blocker** (end user can't complete
the task), **P2 — Significant impact**, **P3 — Noticeable impact**, **P4 — Doesn't follow best
practice**. Severity = how badly the end user is affected **if the agent got this treatment
wrong** — about the *user*, not the location: a blocker is P1 wherever it lives. How often a screen
is reached is a separate concern (it guides where the developer *starts*, not the P-number). Not a
found defect; not a WCAG conformance level (though level is a useful prior when severity is
unclear). The full legend and the "not a guarantee" caveat appear **once** in a preamble at the top
of `ACCESSIBILITY-TESTPLAN.md`, not under every component.

**Why:** "Progress over perfection" — help the developer spend limited time well. Because this is
build-time (the agent already applied a treatment), the meaningful axis is the consequence of that
treatment being wrong, not defect triage or conformance.

**Refined:** an earlier draft told the developer they could **re-rank** the priorities. Removed —
developers will adjust if they truly disagree anyway, and explicitly inviting it just encourages
sliding everything down to a softer priority. The agent assigns the priority and stands behind it.

## 9. The agent never chooses accessibility references — humans declare them

**Decision:** An agent must never decide *which* WCAG success criteria or documentation a skill
cites, nor invent their URLs. Both the *relevance mapping* and the URLs are human authoring
decisions:

- **WCAG SCs are a required input to skill generation.** The contributor names them in the
  generation prompt (e.g. "…following WCAG 2.2 SCs 1.1.1, 1.4.5 & 4.1.2"). The generating agent
  records exactly those — it does not infer, add, or drop criteria. **If the prompt names no SCs,
  the agent refuses to generate the skill** and asks for them.
- **WCAG SC *URLs* may be agent-filled — because that's derivation, not choice.** Once a human
  has named the SC, building its Understanding-doc URL is a deterministic lookup in the canonical
  `wcag-slugs.yml` map, and CI (`scripts/check-references.sh`) verifies every WCAG URL matches the
  map and resolves (hard-fail on wrong slug or 404; soft-fail on network error). So the agent
  fills these and a machine catches any error — no reliance on agent recall.
- **Docs / how-to / blog / video references** are entirely human-authored. At generation the
  agent adds **no entries at all** for these — not the slot, not a URL — because choosing which
  docs to cite is a judgement, like choosing the SCs. If the agent knows useful resources it
  **suggests them in chat as unverified**, for the author to verify and add by hand (suggesting ≠
  declaring). The contributor supplies and verifies the URLs.
- At **run time**, the agent only *cites what the skill already declares* for the branch it took.
  It never introduces a criterion or doc the skill didn't author.

**Why:** Picking the wrong criterion or an off-base article is its own confidently-wrong harm, and
a domain judgement that belongs to a human — a generating agent's instinct to be "helpful" (tossing
in 1.4.11 because "images") is the overreach being ruled out. The dividing line is **choice vs.
derivation**: choosing which SC applies is human; turning a chosen SC into its URL is mechanical, so
the agent may do it *provided the result is machine-checkable* — hence CI-verified, not trusted.

**Refined:** an earlier draft framed this narrowly as "no agent-invented URLs". Broadened: the
agent chooses **no** references at all (criteria included), and **refuses** to generate a skill
whose SCs weren't human-specified.

## 10. Versioning: single (fixed) collection version, stamped into every skill, automated

**Decision:** One version for the whole collection (fixed/locked versioning, like Angular/Babel),
held canonically in the root `VERSION` file and **stamped identically into every `SKILL.md`'s
`version:` frontmatter**. The `version:` line is machine-managed — never hand-edited. A release
is cut by a manual-dispatch GitHub Action (choose patch/minor/major) that bumps `VERSION`, stamps
all skills via `scripts/stamp-version.sh`, updates the CHANGELOG, commits, and tags `vX.Y.Z`. A CI
check fails any PR whose skill versions drift from `VERSION`. Skills also carry self-identifying
`name`, `wcag`, `platform`, `license`.

**Why:** Stamping the version into each skill keeps a vendored folder self-describing when git
history is lost. A *single* version suits a curated library where consumers don't pin individual
skills; the trade-off (it doesn't reveal which skill changed) is covered by the CHANGELOG.
Automation removes the hand-editing burden and prevents drift.

**Superseded:** an earlier draft used independent per-skill versions; rejected as over-engineered
for a curated library.

## 11. License: MIT

**Decision:** MIT for the whole repo (code and prose).

**Why:** The intent is "use it freely — including commercially — modify it, don't sue me." MIT
delivers that with the standard no-warranty disclaimer and minimal, familiar terms. Rejected:
CC BY-NC (forbids the commercial use we want; CC discourages CC for software), CC0/Unlicense
(truer to "I don't claim this" but no familiarity advantage), Apache-2.0 (its patent grant solves
a risk this prose-heavy repo doesn't have).

---

## Intentionally deferred

- **Quality-gate definition** — how we formally judge a skill's output is good (fixtures vs.
  rubric vs. trap cases vs. manual AT gate). To be decided after watching the first skill run
  against the trap fixture.
- **Jetpack Compose skills** — conventions are platform-neutral so Compose slots in later.
- **Dynamic Type skill** — when built, add a cross-link from `swiftui-images`' "Images of text"
  guidance (which already warns that images of text don't scale with Dynamic Type). This is a
  *cross-link, not a migration*: the images-of-text guidance stays here; it just points to the
  Dynamic Type skill for the "prefer real text because it scales" reasoning.
- **Colour skill** — owns 1.4.1 Use of Color (a cross-cutting SC: text, links, form states,
  charts, not just images). Includes the **recolour-only state icon** overlap with
  `swiftui-images`: when the *same* glyph is recoloured to signal state (e.g. `circle.fill` green
  vs. grey), colour is the only visual differentiator → a 1.4.1 failure a colourblind *sighted*
  user hits. This skill's image label fixes the screen-reader case but **not** that — so when the
  colour skill exists, add a cross-link from the status section. (Does *not* apply when different
  symbols signal the states — then shape already differs.) Intentionally not cited as an SC of
  `swiftui-images`, since a label doesn't satisfy 1.4.1.
- **Buttons skill (`swiftui-buttons`)** — when built, the *action* guidance in `swiftui-images`'
  "Tappable / interactive images" section (decision-tree) moves there, and `swiftui-images`
  cross-references it. Note this is a *move of the action part, not a deletion*: an image inside a
  button still has an image-treatment decision here (hide the inner image; the button carries the
  label), so this skill keeps that and points to the buttons skill for the rest.
- **Enforcement hook** — out of scope (not portable / not agent-agnostic).
