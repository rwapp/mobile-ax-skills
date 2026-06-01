---
name: compose-images
description: Use when building or adding an Image, Icon, or painter in Jetpack Compose, to make it accessible from the start — decide whether it should be described, hidden, or marked as a selected state, and hand the developer a way to verify the experience.
version: 0.1.0 # collection version (machine-managed; stamped from /VERSION — do not hand-edit)
wcag: "2.2"
platform: compose
license: MIT
---

# Accessible Images & Icons in Jetpack Compose

This skill helps the **agent** build Jetpack Compose `Image`s and `Icon`s that give the
**end user** the right experience with assistive technology, and hand the **developer** a clear
way to verify it.

It is a **build-time** skill: apply it *while authoring* the composable so accessibility is built
in from the start, not retrofitted. After building, you **must** produce the output in
["Required output"](#required-output-the-deliverable). That hand-off is the primary deliverable,
because whether an image's meaning truly lands can only be confirmed by a human using assistive
technology.

## Why images need attention in Compose

In Compose, `Image` and `Icon` take a **`contentDescription`** that becomes the element's
accessibility label for TalkBack. There is no safe default: pass a meaningful string and TalkBack
reads it; pass **`null`** and the element is removed from the accessibility tree (correct for
decoration); pass something careless (the resource name, "image", a vague word) and you mislead or
clutter the end user. Every image is one of two things to an end user: it **carries meaning** (and
must be described) or it is **decoration** (`contentDescription = null`). Getting this wrong either
hides information from end users or fills their navigation with noise.

> Note: `contentDescription` is **required** by the `Image`/`Icon` APIs — you can't skip the
> decision. That's good: it forces a choice. The job is to make the *right* choice, not to satisfy
> the compiler with a filler string.

## When this applies

Apply this skill when you are adding or editing any of:

- `Image(painter = …)`, `Image(bitmap = …)`, `Image(imageVector = …)`, `Icon(…)`.
- An `AsyncImage` (Coil) or other remote/loaded image.
- An image used *inside* a control (a button's icon, a list row's leading glyph, a selection tick).

It does **not** cover: text fields, buttons' labels in general, navigation, or font scaling —
those belong to sibling skills. If the image is purely a button's visual and the button itself
needs a label, see the buttons skill (and still apply the "image inside a control" branch below).

## How to decide what to build (compact decision summary)

Ask, in order:

1. **Does the image convey information the end user needs that *isn't already in adjacent
   text*?** → Give it a **meaningful `contentDescription`**.
   - A photo / illustration → describe its content concisely ("alt text").
   - The image **contains text** → description = that text **verbatim, as shown** (don't translate
     or summarise — it mirrors what a sighted user reads). If the on-screen text is in the wrong
     language for the user, that's a localisation gap in the *image*, not something to fix by
     translating in the description. See [`decision-tree.md`](decision-tree.md).
   - The image conveys **status** (e.g. a coloured dot, a checkmark, a warning glyph) → describe
     the *status in words*, not the shape (e.g. "Online", not "green circle").
   - The image is **complex** (a chart, graph, diagram, map) → a short description alone can't
     carry it. Give a brief description of *what it is* **plus the information reachable
     separately** (adjacent text, an expandable, or `stateDescription`). Don't cram a paragraph
     into `contentDescription`. See [`decision-tree.md`](decision-tree.md).
   - **But if visible text already conveys that same meaning, the image is redundant — treat it as
     decorative (step 2), `contentDescription = null`.** Two elements saying the same thing makes
     TalkBack announce it twice ("Settings icon, Settings"). The meaning must reach the end user
     once; it doesn't matter whether that's via the text or the image.

2. **Is the image purely decorative** — it adds no information the end user needs, either because
   it's ornamental *or because adjacent text already conveys its meaning*? → **`contentDescription
   = null`**, which removes it from the accessibility tree. (Most ornamental icons fall here.)

3. **Is the image being used to indicate a selected or toggled state** (e.g. a checkmark on the
   chosen row, a filled-vs-outline tab icon, a favourite star)? → **`contentDescription = null` on
   the image**, and express the state on the **enclosing control** — never as a separate focusable
   image. Use the modifier that matches the *kind* of state:
   - **One-of-several** (radio, tab, selected row) → `Modifier.selectable(selected = …)` inside a
     `selectableGroup()` (or the `selected` param of `NavigationBarItem`/`Tab`).
   - **Independent on/off** (favourite, mute, standalone switch/checkbox) → `Modifier.toggleable(…)`.

   Picking the right one matters (using one for the other makes TalkBack announce the wrong kind of
   state); see [`decision-tree.md`](decision-tree.md). The state-bearing control itself is really a
   *controls* concern — a future controls/buttons skill will own it; this skill's part is just
   nulling the indicator image and pointing the state at the control.

4. **Is the content unknown at build time** (`AsyncImage`/Coil, remote or user-supplied images)? →
   You can't hardcode a description. In preference order: use a **server-provided** description;
   derive one from **surrounding data** ("Photo posted by $author"); or, if genuinely unknowable
   and non-essential, set `contentDescription = null`. Handle the **loading and error** states too
   — classify the error by meaning: `null` if the image was decorative, but if the image was the
   point, describe the failure ("Couldn't load photo"). Often genuinely ambiguous, so **ask the
   developer** (step 5). See [`decision-tree.md`](decision-tree.md).

5. **Still can't tell from context which of the above it is?** → **Ask the developer** before
   applying. Only ask when it is *genuinely* ambiguous (e.g. an icon that might be decorative or
   might be the only indicator of status). Phrase it as a concrete choice:
   *"Is this <icon> purely decorative, or does it convey status the end user needs? a) decorative — I'll set contentDescription = null  b) meaningful — I'll describe the status."*

See [`decision-tree.md`](decision-tree.md) for edge cases: icon + adjacent text (avoiding
double-speak), clickable images, images that are both meaningful *and* part of a control,
complex images needing a long description, remote/`AsyncImage` content, multi-state icons, and
text-in-image / localisation caveats.

## Code treatments

**Meaningful — describe it:**
```kotlin
Image(
    painter = painterResource(R.drawable.team_photo),
    contentDescription = "Four colleagues laughing around a laptop",
)

// Status conveyed by an icon: describe the status, not the glyph.
Icon(
    imageVector = Icons.Filled.Circle,
    tint = if (isOnline) Color.Green else Color.Gray,
    contentDescription = if (isOnline) "Online" else "Offline",
)

// Image of text: description = the text itself.
Image(
    painter = painterResource(R.drawable.sale_badge),
    contentDescription = "50% off",
)
```

**Decorative — remove it from the tree (`null`):**
```kotlin
Icon(
    imageVector = Icons.Filled.AutoAwesome,
    contentDescription = null,   // decorative: not in the accessibility tree
)
```
Note: `contentDescription = null` is the idiomatic "hide from accessibility" for an image/icon —
prefer it to a blank string `""` (a blank string still creates a focusable, empty element on some
versions). For a *non-image* element you need to hide, `Modifier.clearAndSetSemantics {}` is the
general tool, but for `Image`/`Icon` use `null`.

**Selected state — null the indicator, selection goes on the control:**
```kotlin
Row(
    modifier = Modifier
        .selectable(
            selected = isSelected,
            onClick = onSelect,
            role = Role.RadioButton,   // or Tab, etc. — sets role + exposes selected state
        )
) {
    Text("Standard shipping")
    Spacer(Modifier.weight(1f))
    if (isSelected) {
        Icon(
            imageVector = Icons.Filled.Check,
            contentDescription = null,   // the tick is visual only
        )
    }
}
```
The end user then hears the row's label plus "selected" (from the selectable's state) — instead of
a stray "check".

**Complex image — short description, information reachable separately:**
```kotlin
// Prefer making the real data reachable as content, not packing it into contentDescription.
Image(
    painter = painterResource(R.drawable.revenue_chart),
    contentDescription = "Revenue by quarter",
    modifier = Modifier.semantics {
        stateDescription = "Q1 £1.2M, Q2 £1.5M, Q3 £1.4M, Q4 £1.9M"  // or a nearby table / expandable
    },
)
```
If the same figures already appear as text on the screen, the chart is redundant — `null`. And
first ask whether it should be a *real* chart at all (see decision-tree: prefer a charting library
/ a real table over an image of data).

**Remote / unknown content (Coil `AsyncImage`) — describe from data, handle non-loaded states:**
```kotlin
AsyncImage(
    model = photo.url,
    contentDescription = photo.caption ?: "Photo posted by ${photo.author}",
    // For decorative remote images, pass contentDescription = null instead.
    // For load/error UI, set the description on the state you show: a real error message
    // ("Couldn't load photo") if the image mattered, or null if it was decorative.
)
```
If no sensible description is available and the image isn't essential, set `contentDescription =
null`.

## Required output (the deliverable)

After building, produce **both** surfaces. Do not skip this — it is the point of the skill.

### 1. Chat (short hook) — 2–4 sentences
Briefly say what you did (the developer can see the diff, so one line is enough), that you built
it with accessibility in mind, point to `ACCESSIBILITY-TESTPLAN.md`, and ask the developer to
**verify with the relevant assistive technologies** (AT-neutral — do not imply TalkBack is the
whole story). This is the only place a "what I did" summary belongs — keep it out of the durable
file, where the diff/commit already records it.

**Call out any assumption you made about an image's meaning** — prominently, as a correctable
guess. Whenever you decided what an image *means* (rather than being told), the description is your
best guess; you can't perceive the app or be certain you read the intent, so this is the thing the
developer most needs to check. Say it plainly: "I read the green dot as 'Online' — if it means
something else, tell me and I'll fix the description." Don't bury it.

Example:
> I added the profile photo with a contentDescription of its contents, set the decorative header
> flourish to `null`, and described the status dot "Online". **Two things I assumed — please
> confirm or correct:** that the photo shows what I described, and that the green dot means
> connection status (not, say, recording). I can't see the running app, so these are guesses. I've
> written instance-specific steps in `ACCESSIBILITY-TESTPLAN.md`; please run through them with
> TalkBack.

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
<e.g. "A TalkBack user reaches the photo and hears a description of who/what is in it, then moves
on. They never encounter the header flourish. A Voice Access user can ignore both — neither is
interactive.">

### How to verify it yourself
⭐ Start here: <single highest-impact check for this instance.>

<If you assumed an image's meaning, make confirming it a verify step — and if it's the
highest-impact thing to get right, it IS the "Start here". e.g. "⭐ Start here: confirm the green
dot means 'Online' — I assumed that; if it means something else the description is wrong.">

- **P1 — Blocker**
  - With TalkBack: <action> → <what to look/listen for>
- **P2 — Significant impact**
  - With TalkBack: ...
  - With Voice Access (if the image is interactive): the spoken/overlaid label must let the user
    target it
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
for — they differ:

- **Meaningful, non-interactive image** → primarily a **screen reader** (TalkBack): does it
  announce the meaning, not just "image" or the resource name?
- **Decorative image** → verify it is **not focusable by any AT** (swipe through with TalkBack; it
  should be skipped — `contentDescription = null` should ensure this).
- **Interactive image / icon button** → screen reader **and Voice Access**: TalkBack announces the
  label, and Voice Access needs a usable label/number to target the control by voice. Switch
  Access should also be able to reach and trigger it.

### Prioritization for this skill (typical)
- **Decorative image:** "Start here" = *swipe through with TalkBack and confirm the image is
  skipped.* Usually **P2** (a focusable decoration is noise, rarely a hard blocker) unless it
  steals focus from something critical.
- **Icon redundant with adjacent text** (e.g. a gear icon beside "Settings"): "Start here" =
  *confirm TalkBack announces the meaning once, not twice.* Usually **P3** — the meaning still
  reaches the end user, it's just repeated, so it's verbosity rather than a barrier.
- **Meaningful image carrying unique information (status, image-of-text):** "Start here" =
  *confirm TalkBack speaks the meaning/status.* Often **P1** when that image is the *only* source
  of the information.
- **Complex image (chart/diagram):** "Start here" = *confirm the underlying information is
  reachable as content, not just a short description.* **P1** if the image is the only way to get
  information the end user needs; lower if the same data is already available as text.
- **Selected-state indicator:** "Start here" = *confirm the control announces "selected", not a
  stray "check".* **P1–P2** depending on whether selection is critical to the task.
- **Remote / `AsyncImage` content:** "Start here" = *confirm a sensible description (or deliberate
  `null`), and that loading/error states don't announce as a meaningful image.* Severity depends
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
