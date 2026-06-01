# Decision tree — edge cases & nuance

The compact summary lives in [`SKILL.md`](SKILL.md). This file covers the cases that trip people
up. The guiding question is always the same: **what does this image mean to an end user who
cannot see it — and is that meaning already available some other way?**

## Icon + adjacent visible text (avoid double-speak)

A common pattern: an SF Symbol next to a text label that says the same thing.

```swift
Label("Settings", systemImage: "gearshape")
```

- If the text already conveys everything, the icon is **decorative** — hide it so the end user
  hears "Settings" once, not "gearshape, Settings".
- SwiftUI's `Label` often handles this well (it surfaces the title), but verify: if you build the
  icon + text yourself in an `HStack`, hide the image explicitly with `.accessibilityHidden(true)`.
- Watch for the opposite failure: hiding the icon when it carries info the text doesn't (e.g. a
  warning triangle next to neutral text). Then the *combination* needs an accessible description.

## Tappable / interactive images

An image that responds to taps is a **control**, and a control with no name is a serious
problem — a screen reader announces nothing actionable, and Voice Control has no phrase to speak.

- Prefer a real `Button`/`NavigationLink` whose accessible name describes the **action**
  ("Add to favourites"), not the picture.
- If you must keep an `Image` with `.onTapGesture`, give it a label describing the action and add
  the `.isButton` trait so its role is announced. A bare tappable image is the trap to avoid.
- This is the canonical Voice Control case: the spoken label must match what the end user sees,
  or they can't activate it by voice.

## Both meaningful *and* part of a control

E.g. a product thumbnail inside a tappable row that opens the product.

- Don't double up. Decide where the meaning lives: usually the **control** gets one combined,
  action-oriented label ("Open <product name>"), and the inner image is **hidden**.
- Use `.accessibilityElement(children: .combine)` (or label the control directly) so the end
  user hears one coherent thing, not a thumbnail announcement followed by a row announcement.

## Selected state — why the trait, not a label

Putting "selected" in a label is fragile (it doesn't toggle, doesn't localise, isn't a real
state). The platform trait does:

```swift
.accessibilityAddTraits(isSelected ? .isSelected : [])
```

Hide the visual indicator (checkmark, filled-vs-outline symbol) and let the trait carry state on
the **enclosing control**. The end user hears the control's name plus "selected". For tabs,
`TabView` largely handles this — only intervene if you've built custom selection visuals.

**Extra reason to hide the indicator symbol here:** an SF Symbol's *default* label can itself
carry state-ish wording, so a visible tick may announce something like "selected" or "checkmark"
**as label text** — separate from, and colliding with, the real `.isSelected` trait. That gives
the user a static word baked into a string instead of a genuine toggling state (or a doubled
"selected, selected"). Hiding the symbol removes its default label, so the *only* "selected" the
user hears is the trait — which toggles correctly and localises. (See the SF Symbol default-label
note below.)

## Status conveyed only by colour or shape

A green vs. red dot, a filled vs. hollow symbol — meaningless to a screen reader user, and to
many low-vision users if colour is the only cue.

- The accessibility label must state the **status in words** ("Online" / "Offline"), never the
  appearance ("green circle").
- This also touches a separate criterion — *use of colour* — which a colour/contrast skill will
  cover; here, at minimum, make the status available as text via the label.

## Images of text

- Label = the **exact text shown, verbatim** — the label is a substitute for *seeing* the image,
  so it must say what the image says. Don't summarise.
- **Don't translate it.** Mirror the on-screen text in whatever language the image is in. The two
  cases that look like exceptions but aren't:
  - **Foreign text is intentional content** (e.g. a language-learning app showing "Solde" to a
    user learning French): the foreign word *is* the meaning — label it "Solde". Translating
    would destroy the point.
  - **Foreign text is a localisation gap** (e.g. an un-localised "Sale" badge in an app set to
    French): the label still mirrors the image ("Sale") — but the real fix is to **localise the
    image** so it shows "Solde", and the label then follows. Don't paper over a localisation bug
    by translating only in the label; that leaves sighted users with the wrong language and
    desyncs the two.
  - In a well-localised app these never conflict: the image is already in the user's language, so
    "as shown" and "user's language" are the same thing.
- If the image's text language genuinely differs from the surrounding UI, the *element's* language
  may need setting so the screen reader pronounces it correctly (WCAG 3.1.2 Language of Parts) —
  out of scope for this skill, but flag it to the developer.
- If the text is long or is the primary content, flag to the developer that real text (not an
  image) is strongly preferable — images of text don't scale with Dynamic Type and may fail at
  large sizes.

## Complex images (charts, graphs, diagrams, maps)

**First ask: should this be an image at all?** If the content is real data, prefer rendering it
as data rather than as a picture of data:
- A chart → **Swift Charts** rather than an image of a graph. (It has built-in accessibility —
  VoiceOver descriptions, the Audio Graph feature — though it still benefits from good labels and
  values; "prefer it", not "it's solved".)
- Tabular data → a real **`Grid` / `List` / `Table`** rather than a screenshot of a table.
This is the build-it-in option: real data viz is accessible (and resizes, themes, and updates)
where an image has to have accessibility bolted on afterwards. The rest of this section is for when
it genuinely *has* to be an image (a static diagram, a third-party render, an exported figure).

A chart or diagram carries more information than a few words. You *can* put a full description in
the `.accessibilityLabel` — there's no length limit and it isn't wrong — but a **separate text
description is the better option**, because it helps more people: a screen-reader user, yes, but
also **low-vision** users who can't make out the chart's detail, and **autistic / cognitive-load**
users who benefit from plain text they can read at their own pace. A label only reaches the
screen-reader user (and as one unskimmable block); visible/structured text reaches everyone.

- Give a **short label for what the image is** ("Revenue by quarter, bar chart"), then make the
  **fuller information reachable separately** — in preference order:
  - **Real text / a data table** adjacent to or behind a disclosure — best, because the end user
    navigates it like any other content (and it helps everyone, not just AT users).
  - **`.accessibilityValue`** for a single summarising figure ("up 12% on last quarter").
  - A **detail view / "describe this chart" affordance** the end user can open.
- The test: could a screen-reader user get the *same information* a sighted user gets from the
  chart? If the only answer is a long label, the information isn't really accessible — push for
  text/table instead.
- If the chart is purely illustrative and the real data is already in a table on the same screen,
  the image is **redundant → decorative** (hide it; don't double up).

## SF Symbols already have a default label — and it's usually wrong for your UI

`Image(systemName:)` is **not** unlabelled. SwiftUI gives many SF Symbols a default accessibility
label: a curated friendly name for some (`heart` → "love", `calendar.badge.plus` → "add to
calendar", `checkmark.seal.fill` → "Verified"), and for the rest, the **raw symbol name** read
aloud ("keyboard.chevron.compact.down" — meaningless to the user).

Either way, the default describes the *glyph*, not what it means **in your interface** — so it's
rarely what you want. Don't assume "I didn't set a label, so it says nothing": it says something,
just probably the wrong thing. So:

- **Decorative symbol** → `.accessibilityHidden(true)` — this also suppresses the default label, so
  the symbol goes silent (not "sparkles").
- **Meaningful symbol** → set an explicit `.accessibilityLabel` for the meaning; don't rely on the
  default matching your intent.
- Verify by ear with VoiceOver — the default can be a friendly word, a raw name, or (see below)
  even imply a *state*.

## Multi-state / animated SF Symbols

- A symbol that animates or changes variant for *effect* is decoration → hide it.
- A symbol whose variant encodes the **state of one thing** (e.g. `speaker.wave.2` vs
  `speaker.slash`) → put the stable identity in the **label** and the changing state in the
  **`.accessibilityValue`**, not both in the label. E.g. label `"Volume"`, value `"2"` or
  `"muted"` — VoiceOver announces "Volume, 2" and re-announces the value when it changes. This
  mirrors the label-vs-trait split used for selection: identity is fixed, state varies.

  ```swift
  Image(systemName: isMuted ? "speaker.slash" : "speaker.wave.2")
      .accessibilityLabel("Volume")
      .accessibilityValue(isMuted ? "muted" : "\(level)")
  ```
- Only let the **label** change when the symbol's *whole meaning* changes (a different thing
  entirely, not a new state of the same thing). For "same thing, different state", prefer value.

## AsyncImage and unknown content

- When the image content isn't known at build time (remote, user-supplied), the label can't be
  hardcoded. Options, in preference order: a server-provided description/alt text; a label
  derived from surrounding data ("Photo posted by <author>"); or, if genuinely unknowable and
  non-essential, treat as decorative. Surface this choice to the developer — it's often genuinely
  ambiguous, so **ask**.
- Handle the loading and failure states too — and classify the **failure** by meaning, just like
  any other image:
  - **Decorative image that failed** → hide the placeholder (silence). Its absence changes nothing.
  - **The image was the main purpose of the screen** (e.g. the photo the screen exists to show) →
    the failure *is* information; convey it in the label ("Couldn't load photo" / "Image failed to
    load — tap to retry"). The user needs to know it's broken, not loading forever.
  - **In between** → ambiguous; bias toward **not** adding noise. Only announce the failure if it
    affects what the user can do or understand; otherwise stay quiet.

## When to ask vs. decide — and always surface what you assumed

Ask the developer when the *meaning* of the image is genuinely unknowable from context — most
often: an icon that could be decorative or could be the sole status indicator, and remote/
user-supplied images. When context makes the intent clear enough to decide, decide — but don't
ask about the *mechanical* treatment, only about *intent*.

**Whenever you decide an image's meaning rather than being told it, you have made an assumption —
say so, explicitly, every time.** A label like "Online" for a green dot is your best guess at
what the dot *means*; if it actually means "recording" or "available", only the developer knows,
and a confidently-wrong label is worse than no label because it reads as correct. This is the
single most important thing to hand back: the agent cannot perceive the app or be certain it read
the intent (see SKILL.md), so the guessed meaning is exactly what the human must confirm.

- Surface every assumed meaning in **both** the chat hook ("I assumed this dot means 'Online' —
  confirm or correct") **and** the matching verify step in the test plan ("confirm 'Online' is
  what this dot means to your users").
- Phrase it as a correctable guess, not a fact: "I read this as X" / "assuming this is Y".
- This applies to the label *text* too, not just decorative-vs-meaningful: "Four colleagues
  laughing" is an assumption about a photo's content; flag it.
