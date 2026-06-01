---
name: swiftui-images
description: Use when building or adding an Image or SF Symbol in SwiftUI, to make it accessible from the start — decide whether it should be labelled, hidden, or marked as a selected state, and hand the developer a way to verify the experience.
version: 0.1.0 # collection version (machine-managed; stamped from /VERSION — do not hand-edit)
wcag: "2.2"
platform: swiftui
license: MIT
---

# Accessible Images & SF Symbols in SwiftUI

This skill helps the **agent** build SwiftUI `Image`s (including SF Symbols) that give the
**end user** the right experience with assistive technology, and hand the **developer** a clear
way to verify it.

It is a **build-time** skill: apply it *while authoring* the view so accessibility is built in
from the start, not retrofitted. After building, you **must** produce the output in
["Required output"](#required-output-the-deliverable). That hand-off is the primary deliverable,
because whether an image's meaning truly lands can only be confirmed by a human using assistive
technology.

## Why images need attention in SwiftUI

A SwiftUI `Image` is, by default, **visible to assistive technology but has no meaningful
label** — a screen reader may focus it and announce only "image" (or the asset/symbol name).
That is rarely the right experience. Every image is one of two things to an end user: it
**carries meaning** (and must be described) or it is **decoration** (and should be skipped).
Getting this wrong either hides information from end users or clutters their navigation with
noise.

## When this applies

Apply this skill when you are adding or editing any of:

- `Image("asset")`, `Image(systemName:)` (SF Symbols), `Image(uiImage:)`, `AsyncImage`.
- An image used *inside* a control (a button's icon, a row's leading glyph, a selection tick).

It does **not** cover: text fields, buttons' labels in general, navigation, or Dynamic Type
sizing — those belong to sibling skills. If the image is purely a button's visual and the button
itself needs a label, see the buttons skill (and still apply the "image inside a control" branch
below).

## How to decide what to build (compact decision summary)

Ask, in order:

1. **Does the image convey information the end user needs that *isn't already in adjacent
   text*?** → Make it accessible with a **meaningful label**.
   - A photo / illustration → label = a concise description of its content ("alt text").
   - The image **contains text** → label = that text **verbatim, as shown** (don't translate or
     summarise — the label mirrors what a sighted user reads). If the on-screen text is in the
     wrong language for the user, that's a localisation gap in the *image*, not something to fix
     by translating in the label. See [`decision-tree.md`](decision-tree.md).
   - The image conveys **status** (e.g. a coloured dot, a checkmark, a warning glyph) → label =
     the *status in words*, not the shape (e.g. "Online", not "green circle").
   - The image is **complex** (a chart, graph, diagram, map) → a short label alone can't carry it.
     Give a brief label for *what it is* **plus a longer description of the information** somewhere
     the end user can reach (adjacent text, a disclosure, or `.accessibilityValue` / a detail
     view). Don't cram a paragraph into the label. See [`decision-tree.md`](decision-tree.md).
   - **But if a visible text label already conveys that same meaning, the image is redundant —
     treat it as decorative (step 2), don't label it.** Two elements saying the same thing makes
     assistive tech announce it twice ("gearshape, Settings"). The meaning must reach the end
     user once; it doesn't matter whether that's via the text or the image.

2. **Is the image purely decorative** — it adds no information the end user needs, either because
   it's ornamental *or because adjacent text already conveys its meaning*? → **Hide it** from
   assistive technology, with **no** label. (Most ornamental SF Symbols, and most icons paired
   with a text label, fall here.)

3. **Is the image being used to indicate a selected state** (e.g. a checkmark on the chosen
   row, a filled vs. outline icon for the active tab)? → **Hide the image**, and express
   selection on the **enclosing control** with the `.isSelected` trait — never as a separate
   focusable image. Ensure that control has its own label.

4. **Is the content unknown at build time** (`AsyncImage`, remote or user-supplied images)? → You
   can't hardcode a description. In preference order: use a **server-provided** alt/description;
   derive a label from **surrounding data** ("Photo posted by <author>"); or, if genuinely
   unknowable and non-essential, treat as **decorative**. Handle the **loading and failure**
   states too — classify the failure by meaning: hide it if the image was decorative, but if the
   image was the point, say it failed ("Couldn't load photo"). This is often genuinely ambiguous,
   so **ask the developer** (step 5). See [`decision-tree.md`](decision-tree.md).

5. **Still can't tell from context which of the above it is?** → **Ask the developer** before
   applying. Only ask when it is *genuinely* ambiguous (e.g. an icon that might be decorative
   or might be the only indicator of status). Phrase it as a concrete choice:
   *"Is this <icon> purely decorative, or does it convey status the end user needs? a) decorative — I'll hide it  b) meaningful — I'll label it with the status."*

See [`decision-tree.md`](decision-tree.md) for edge cases: icon + adjacent text (avoiding
double-speak), tappable images, images that are both meaningful *and* part of a control,
complex images needing a long description, remote/`AsyncImage` content, multi-state SF Symbols,
and text-in-image / localisation caveats.

## Code treatments

**Meaningful — add a label:**
```swift
Image("teamPhoto")
    .accessibilityLabel("Four colleagues laughing around a laptop")

// Status conveyed by an icon: describe the status, not the glyph.
Image(systemName: "circle.fill")
    .foregroundStyle(.green)
    .accessibilityLabel("Online")

// Image of text: label is the text itself.
Image("salePriceBadge")
    .accessibilityLabel("50% off")
```

**Decorative — hide it (no label):**
```swift
Image(systemName: "sparkles")
    .accessibilityHidden(true)
```
Note: SwiftUI's `Image(decorative:)` initializer marks an *asset* as decorative, but the most
reliable, intention-revealing treatment across image types — including SF Symbols and icons
beside text — is `.accessibilityHidden(true)`. Prefer it unless you have a reason not to.

Note: an `Image(systemName:)` is **not** unlabelled — SF Symbols carry a *default* label (a
curated name for some, e.g. "love" for `heart`; the raw symbol name for the rest). It describes
the glyph, not your meaning, so don't rely on it: set an explicit `.accessibilityLabel` for
meaningful symbols, and hide decorative ones (which also silences the default). See
[`decision-tree.md`](decision-tree.md).

**Selected state — hide the indicator, trait goes on the control:**
```swift
Button(action: select) {
    HStack {
        Text("Standard shipping")
        Spacer()
        Image(systemName: "checkmark")
            .accessibilityHidden(true)        // the tick is visual only
    }
}
.accessibilityAddTraits(isSelected ? .isSelected : [])   // selection lives on the control
```
The end user then hears the row's label plus "selected" — instead of a stray "checkmark".

**Complex image — short label, information reachable separately:**
```swift
// Prefer making the real data reachable as text, not packing it into the label.
Image("revenueChart")
    .accessibilityLabel("Revenue by quarter")
    .accessibilityValue("Q1 £1.2M, Q2 £1.5M, Q3 £1.4M, Q4 £1.9M")  // or a nearby table / detail view
```
If the same figures already appear as text on the screen, the chart is redundant — hide it.

**Remote / unknown content (`AsyncImage`) — label from data, and handle non-loaded states:**
```swift
AsyncImage(url: photo.url) { phase in
    switch phase {
    case .success(let image):
        image.accessibilityLabel(photo.caption ?? "Photo posted by \(photo.author)")
    case .failure:
        // Classify the failure by meaning: if the image mattered, say it failed; if it was
        // decorative, hide the placeholder. Here the photo is the point, so the user needs to know.
        Image(systemName: "photo")
            .accessibilityLabel("Couldn't load photo")
    case .empty:
        ProgressView().accessibilityLabel("Loading photo")
    @unknown default:
        EmptyView()
    }
}
```
If no sensible description is available and the image isn't essential, treat it as decorative.

## Required output (the deliverable)

After building, produce **both** surfaces. Do not skip this — it is the point of the skill.

### 1. Chat (short hook) — 2–4 sentences
Briefly say what you did (the developer can see the diff, so one line is enough), that you built
it with accessibility in mind, point to `ACCESSIBILITY-TESTPLAN.md`, and ask the developer to
**verify with the relevant assistive technologies** (AT-neutral — do not imply VoiceOver is the
whole story). This is the only place a "what I did" summary belongs — keep it out of the durable
file, where the diff/commit already records it.

**Call out any assumption you made about an image's meaning** — prominently, as a correctable
guess. Whenever you decided what an image *means* (rather than being told), the label is your
best guess; you can't perceive the app or be certain you read the intent, so this is the thing
the developer most needs to check. Say it plainly: "I read the green dot as 'Online' — if it
means something else, tell me and I'll fix the label." Don't bury it.

Example:
> I added the profile photo with a label describing its contents, hid the decorative header
> flourish, and labelled the status dot "Online". **Two things I assumed — please confirm or
> correct:** that the photo shows what I described, and that the green dot means connection status
> (not, say, recording). I can't see the running app, so these are guesses. I've written
> instance-specific steps in `ACCESSIBILITY-TESTPLAN.md`; please run through them with VoiceOver.

### 2. `ACCESSIBILITY-TESTPLAN.md` in the developer's repo
**Upsert by component section** — update this screen/component's heading; don't blindly append.
Fill the four headers with **instance-specific** content. Lead with the experience — it's what
the developer is here to verify.

If the file doesn't exist yet, create it with the one-time **preamble** below (which explains
"Start here" and the priorities once, so those don't repeat per component). If it already exists,
don't touch the preamble — just upsert this component's section.

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

## <Screen / component>  (updated <YYYY-MM-DD>)

### Intended accessibility experience
<e.g. "A screen reader user reaches the photo and hears a description of who/what is in it,
then moves on. They never encounter the header sparkle. A Voice Control user can ignore both —
neither is interactive.">

### How to verify it yourself
⭐ Start here: <single highest-impact check for this instance.>

<If you assumed an image's meaning, make confirming it a verify step — and if it's the
highest-impact thing to get right, it IS the "Start here". e.g. "⭐ Start here: confirm the green
dot means 'Online' — I assumed that; if it means something else the label is wrong.">

- **P1 — Blocker**
  - With VoiceOver: <action> → <what to look/listen for>
- **P2 — Significant impact**
  - With VoiceOver: ...
  - With Voice Control (if the image is interactive): say the visible label → it should activate
- **P3 — Noticeable impact** / **P4 — Doesn't follow best practice**
  - ...

### WCAG
- [wcag-1.1.1]: 1.1.1 Non-text Content — <why it applies here>
- [wcag-1.4.5]: only if an image contains text
- [wcag-4.1.2]: only for the selected-state / control case

### Learn more
- Cite any how-to / demo / blog / video references the skill declares in `references.md`.
- If none are declared yet, omit this section (don't invent links). You may instead *suggest*
  useful resources to the developer in chat, clearly marked as unverified.
```

### AT-neutrality for this skill
Name the assistive technologies that matter for *this* image, ranked, each with what to look
for — they differ. **Name only the Apple-platform ATs the developer can actually test** —
VoiceOver, Voice Control, Switch Control, Full Keyboard Access. Don't list Android ATs (TalkBack,
Voice Access): this is a SwiftUI skill, so they're irrelevant to this developer. "AT-neutral" means *don't assume
screen-reader-only* — not *list every platform's tools*.

- **Meaningful, non-interactive image** → primarily a **screen reader** (VoiceOver): does it
  announce the meaning, not just "image"?
- **Decorative image** → verify it is **not focusable by any AT** (swipe past with VoiceOver; it
  should be skipped).
- **Interactive image / image button** → screen reader **and Voice Control**: the label is both
  what VoiceOver announces *and* the phrase the end user must *speak* to activate it, so it must
  match the visible affordance. Switch Control and Full Keyboard Access should also be able to
  reach and trigger it.

### Prioritization for this skill (typical)
- **Decorative image:** "Start here" = *swipe through with VoiceOver and confirm the image is
  skipped.* Usually **P2** (a focusable decoration is noise, rarely a hard blocker) unless it
  steals focus from something critical.
- **Icon redundant with adjacent text** (e.g. a gear icon beside "Settings"): "Start here" =
  *confirm the screen reader announces the meaning once, not twice.* Usually **P3** — the meaning
  still reaches the end user, it's just repeated, so it's verbosity rather than a barrier.
- **Meaningful image carrying unique information (status, image-of-text):** "Start here" =
  *confirm the screen reader speaks the meaning/status.* Often **P1** when that image is the
  *only* source of the information.
- **Complex image (chart/diagram):** "Start here" = *confirm the underlying information is
  reachable as text, not just a short label.* **P1** if the image is the only way to get
  information the end user needs; lower if the same data is already available as text.
- **Selected-state indicator:** "Start here" = *confirm the control announces "selected", not a
  stray "checkmark".* **P1–P2** depending on whether selection is critical to the task.
- **Remote / `AsyncImage` content:** "Start here" = *confirm a sensible label (or deliberate
  hiding), and that loading/broken states don't announce as a meaningful image.* Severity depends
  on whether the image carries needed information — **P1** if it does and there's no alternative,
  lower if it's illustrative.

For a case the examples above don't cover, judge severity by asking *"if I got this treatment
wrong, what can the end user no longer do?"* — can't complete the task → **P1**; can, but with
major friction → **P2**; minor annoyance → **P3**; works but not best practice → **P4**.

Priority is **severity** — how badly the end user is affected if this treatment is wrong — not
where the image sits. A blocker is P1 wherever it lives; a decorative image that merely adds noise
stays low even on a key screen. (How often a screen is reached can guide where the developer
*starts*, but it doesn't change the P-number.)

### References
Cite by anchor from [`references.md`](references.md), which declares the WCAG criteria and docs
this skill covers (author-specified — see its provenance note). Cite only what's declared there
for the branch you took; **never choose a criterion or doc of your own.** WCAG URLs are derived
from the declared SC numbers via `wcag-slugs.yml` and checked by CI; **never invent a doc/how-to
URL** — if such a slot is blank, name it and note the link is pending.
