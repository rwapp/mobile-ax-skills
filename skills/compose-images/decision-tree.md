# Decision tree — edge cases & nuance

The compact summary lives in [`SKILL.md`](SKILL.md). This file covers the cases that trip people
up. The guiding question is always the same: **what does this image mean to an end user who
cannot see it — and is that meaning already available some other way?**

## Icon + adjacent visible text (avoid double-speak)

A common pattern: an icon next to a text label that says the same thing.

```kotlin
Row {
    Icon(Icons.Filled.Settings, contentDescription = null)  // decorative — text says it
    Text("Settings")
}
```

- If the text already conveys everything, the icon is **decorative** → `contentDescription = null`,
  so the end user hears "Settings" once, not "Settings icon, Settings".
- Watch for the opposite failure: nulling the icon when it carries info the text doesn't (e.g. a
  warning triangle next to neutral text). Then the *combination* needs an accessible description —
  describe the icon, or set a combined description on the row (see below).

## Clickable / interactive images

An image that responds to clicks is a **control**, and a control with no name is a serious problem
— a screen reader announces nothing actionable, and Voice Access has no label to target.

- Prefer a real `IconButton`/`Button`/clickable whose accessible name describes the **action**
  ("Add to favourites"), not the picture. On an `IconButton`, the inner `Icon`'s
  `contentDescription` becomes the button's label — so describe the *action* there.
- A bare `Image(...).clickable { }` with `contentDescription = null` is the trap to avoid: it's
  tappable but unnamed. Give it an action description and a `role = Role.Button` via semantics.
- This is the canonical Voice Access case: the label must let the user target the control by voice.

## Both meaningful *and* part of a control

E.g. a product thumbnail inside a clickable row that opens the product.

- Don't double up. Decide where the meaning lives: usually the **control** gets one combined,
  action-oriented label ("Open <product name>"), and the inner image is `contentDescription = null`.
- Use `Modifier.semantics(mergeDescendants = true) { }` on the clickable container (or rely on the
  fact that `clickable`/`selectable` merge descendant semantics) so the end user hears one coherent
  thing, not a thumbnail announcement followed by a row announcement.

## Selected / toggled state — why state semantics, not a description

Putting "selected" or "on" in a `contentDescription` is fragile (it doesn't change as a real state,
isn't localised as state, and competes with the platform's own announcement). Let the platform
express it — but **pick the right modifier for the kind of state**, because Compose has two and
they're not interchangeable:

- **`Modifier.selectable`** — *one chosen option among mutually exclusive ones* (radio buttons,
  tabs, the selected row in a list). Exposes a `selected` boolean; TalkBack announces "…selected".
  Goes inside a `selectableGroup()` (or use the `selected` param of `NavigationBarItem` / `Tab`).
  ```kotlin
  Modifier.selectable(selected = isSelected, onClick = onSelect, role = Role.RadioButton)
  ```
- **`Modifier.toggleable`** — *an independent on/off control* (a favourite star, a mute button, a
  standalone checkbox or switch). Exposes a `ToggleableState`; TalkBack announces "on"/"off" (or a
  custom `stateDescription`). No group needed.
  ```kotlin
  Modifier.toggleable(value = isFavourite, role = Role.Switch, onValueChange = onToggle)
  // or stateDescription = if (isFavourite) "Favourited" else "Not favourited"
  ```

The quick test: *is this one-of-several (selectable) or its-own-on/off (toggleable)?* A list where
tapping one row deselects the others is `selectable`; a star that toggles favourite independently of
everything else is `toggleable`. Using `selectable` for an independent toggle (or vice-versa) makes
TalkBack announce the wrong kind of state.

Either way, the **image rule is the same**: set `contentDescription = null` on the indicator icon
(the check, the filled-vs-outline star) and let the **enclosing control** carry the state. For
`NavigationBar`/`TabRow`, the built-in `selected` parameter handles it — only intervene if you've
built custom visuals.

**Extra reason to null the indicator icon here:** an icon's own `contentDescription` (if set) is
announced as label text, separate from — and colliding with — the real state. That gives the user a
static word instead of a genuine state (or a doubled "selected, selected"). `null` removes it, so
the *only* state the user hears is the real one.

## Status conveyed only by colour or shape

A green vs. red dot, a filled vs. hollow icon — meaningless to a screen reader user, and to many
low-vision users if colour is the only cue.

- The `contentDescription` must state the **status in words** ("Online" / "Offline"), never the
  appearance ("green circle").
- This also touches a separate criterion — *use of colour* — which a colour/contrast skill will
  cover; here, at minimum, make the status available as text via the description.

## Images of text

- Description = the **exact text shown, verbatim** — it's a substitute for *seeing* the image, so
  it must say what the image says. Don't summarise.
- **Don't translate it.** Mirror the on-screen text in whatever language the image is in. Two cases
  that look like exceptions but aren't:
  - **Foreign text is intentional content** (e.g. a language-learning app showing "Solde" to a user
    learning French): the foreign word *is* the meaning — describe it "Solde". Translating destroys
    the point.
  - **Foreign text is a localisation gap** (e.g. an un-localised "Sale" badge in a French app):
    the description still mirrors the image ("Sale") — but the real fix is to **localise the image**
    so it shows "Solde", and the description follows. Don't paper over a localisation bug by
    translating only in the description; that desyncs sighted and non-sighted users.
  - In a well-localised app these never conflict: the image is already in the user's language.
- If the image's text language genuinely differs from the surrounding UI, the screen reader may
  mispronounce it (WCAG 3.1.2 Language of Parts) — out of scope for this skill, but flag it.
- If the text is long or is the primary content, flag to the developer that **real text** (not an
  image) is strongly preferable — images of text don't scale with the user's font-size setting and
  may clip at large sizes.

## Complex images (charts, graphs, diagrams, maps)

**First ask: should this be an image at all?** If the content is real data, prefer rendering it as
data rather than as a picture of data:
- A chart → a real **charting library** (e.g. Vico, or a custom `Canvas` with proper semantics)
  rather than an image of a graph.
- Tabular data → a real **table layout** (`LazyColumn`/`Row`s, or a Grid) rather than a screenshot
  of a table.
This is the build-it-in option: real data views are accessible (and resize, theme, and update)
where an image has accessibility bolted on afterwards. The rest of this section is for when it
genuinely *has* to be an image (a static diagram, a third-party render, an exported figure).

A chart or diagram carries more information than a few words. You *can* put a full description in
`contentDescription` — there's no length limit and it isn't wrong — but a **separate text
description is the better option**, because it helps more people: a screen-reader user, yes, but
also **low-vision** users who can't make out the chart's detail, and **autistic / cognitive-load**
users who benefit from plain text they can read at their own pace. A description only reaches the
screen-reader user (as one unskimmable block); visible/structured text reaches everyone.

- Give a **short `contentDescription` for what the image is** ("Revenue by quarter, bar chart"),
  then make the **fuller information reachable separately** — in preference order:
  - **Real text / a data table** adjacent to or behind an expandable — best, because the end user
    navigates it like any other content (and it helps everyone, not just AT users).
  - **`stateDescription`** (via `Modifier.semantics`) for a single summarising figure ("up 12% on
    last quarter").
  - A **detail screen / "describe this chart" affordance** the end user can open.
- The test: could a screen-reader user get the *same information* a sighted user gets from the
  chart? If the only answer is a long description, the information isn't really accessible — push
  for text/table instead.
- If the chart is purely illustrative and the real data is already in a table on the same screen,
  the image is **redundant → `contentDescription = null`** (don't double up).

## Don't pass a careless `contentDescription` just to satisfy the parameter

`contentDescription` is a **required** parameter on `Image`/`Icon`, so the compiler makes you pass
*something* — and the trap is passing a filler value to make it compile: the resource name
(`"ic_circle"`), the word "icon", or a vague guess. The element is then labelled exactly with that
useless string. The required parameter is a prompt to make a real decision, not a box to tick: pass
a **meaningful description** if it carries meaning, or **`null`** if it's decorative.

## Multi-state icons

- An icon that animates or changes for *effect* is decoration → `contentDescription = null`.
- An icon whose variant encodes the **state of one thing** (e.g. a volume icon: `VolumeUp` vs.
  `VolumeOff`) → put the stable identity in the **description** and the changing state in the
  **`stateDescription`**, not both in the description. E.g. description "Volume", stateDescription
  "muted" / "2". TalkBack announces "Volume, 2" and re-announces the state when it changes.

  ```kotlin
  Icon(
      imageVector = if (isMuted) Icons.Filled.VolumeOff else Icons.Filled.VolumeUp,
      contentDescription = "Volume",
      modifier = Modifier.semantics {
          stateDescription = if (isMuted) "muted" else "$level"
      },
  )
  ```
- Only let the **description** change when the icon's *whole meaning* changes (a different thing
  entirely, not a new state of the same thing). For "same thing, different state", prefer
  `stateDescription`.

## AsyncImage and unknown content

- When the image content isn't known at build time (remote, user-supplied via Coil's `AsyncImage`),
  the description can't be hardcoded. Options, in preference order: a server-provided description; a
  description derived from surrounding data ("Photo posted by $author"); or, if genuinely unknowable
  and non-essential, `contentDescription = null`. Surface this choice to the developer — it's often
  genuinely ambiguous, so **ask**.
- Handle the loading and **error** states too — and classify the **error** by meaning, just like any
  other image:
  - **Decorative image that failed** → `null` (silence). Its absence changes nothing.
  - **The image was the main purpose of the screen** (e.g. the photo the screen exists to show) →
    the failure *is* information; describe it on the error UI ("Couldn't load photo — tap to
    retry"). The user needs to know it's broken, not loading forever.
  - **In between** → ambiguous; bias toward **not** adding noise. Only announce the failure if it
    affects what the user can do or understand; otherwise stay quiet.

## When to ask vs. decide — and always surface what you assumed

Ask the developer when the *meaning* of the image is genuinely unknowable from context — most
often: an icon that could be decorative or could be the sole status indicator, and remote/
user-supplied images. When context makes the intent clear enough to decide, decide — but don't ask
about the *mechanical* treatment, only about *intent*.

**Whenever you decide an image's meaning rather than being told it, you have made an assumption —
say so, explicitly, every time.** A description like "Online" for a green dot is your best guess at
what the dot *means*; if it actually means "recording" or "available", only the developer knows,
and a confidently-wrong description is worse than none because it reads as correct. This is the
single most important thing to hand back: the agent cannot perceive the app or be certain it read
the intent (see SKILL.md), so the guessed meaning is exactly what the human must confirm.

- Surface every assumed meaning in **both** the chat hook ("I assumed this dot means 'Online' —
  confirm or correct") **and** the matching verify step in the test plan ("confirm 'Online' is what
  this dot means to your users").
- Phrase it as a correctable guess, not a fact: "I read this as X" / "assuming this is Y".
- This applies to the description *text* too, not just decorative-vs-meaningful: "Four colleagues
  laughing" is an assumption about a photo's content; flag it.
