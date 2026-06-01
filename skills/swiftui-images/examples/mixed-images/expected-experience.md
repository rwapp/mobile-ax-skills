# Expected experience — `mixed-images` fixture

What a correct run of the `swiftui-images` skill should produce for
[`Before.swift`](Before.swift): the code in [`After.swift`](After.swift), **plus** an
`ACCESSIBILITY-TESTPLAN.md` entry resembling the one below. This doubles as a "what good looks
like" reference and the seed for the (deferred) quality-bar discussion.

> **Why `Before.swift` is unannotated:** it is the test *input*, so it must not reveal the
> answers. It deliberately carries only the cues a developer would naturally write (e.g. an asset
> named `proBadge`, a status dot whose colour follows `isOnline`) — not accessibility verdicts in
> comments — so an agent has to classify each image from context, as it would in a real codebase.
> All the classifications and reasoning live *here*, in the answer key.

## The trap

All four images are small glyphs/badges that *look* alike, but need four different treatments.
A skill that gives them the same treatment (e.g. hides all icons, or labels all icons) has
failed the fixture:

| Image | Correct classification | Correct treatment |
|-------|------------------------|-------------------|
| `sparkles` | Decorative | `.accessibilityHidden(true)` |
| `circle.fill` (status dot) | Meaningful — sole online/offline cue | `.accessibilityLabel("Online" / "Offline")` |
| `proBadge` | Image of text | `.accessibilityLabel("PRO")` |
| `checkmark` | Selected-state indicator | hidden; `.isSelected` on the row (the control) |

A correct run should also **combine** each row into one accessibility element so it reads
coherently rather than as four fragments. Because this is a *list* where one row is selected, the
`.isSelected` trait must move with the selection — the chosen row carries it, the others don't.

## Expected `ACCESSIBILITY-TESTPLAN.md` entry

The file opens with a one-time preamble (written when the file is first created, never repeated),
then a section per component:

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

## DeviceList rows  (updated 2026-05-31)

### Intended accessibility experience
A screen reader user moves through the list and hears one announcement per row covering the
device name, its status, its plan, whether it's the selected row, and that it's a button — e.g.
"Living Room Speaker, Online, PRO, selected, button" for the chosen device, and the same without
"selected" for the others. They never encounter the sparkle, and they never hear a meaningless
"circle" or "checkmark." A Voice Control user can say a device name to select that row.

### How to verify it yourself
⭐ Start here: I **assumed the green/grey dot means online/offline** (inferred from the `isOnline`
   flag) and labelled it "Online"/"Offline" — confirm that's what the dot actually means. If it
   means something else (available, recording, synced…), the label is confidently wrong and needs
   changing. With VoiceOver on, also confirm each row *speaks* that status, not just shows a colour.

- **P1 — Blocker**
  - With VoiceOver: confirm each row's status ("Online"/"Offline") is announced. It's the only
    cue, so if it's missing the end user cannot tell device state at all.
- **P2 — Significant impact**
  - With VoiceOver: confirm the chosen row announces "selected" — not a stray "checkmark", and not
    silence — and that the others do not. Select a different row and confirm "selected" moves with
    it.
  - With VoiceOver: confirm "PRO" is announced on Pro rows (not "image" or an asset name).
  - With Voice Control: say a device name and confirm that row activates — the spoken label must
    match what's on screen.
- **P3 — Noticeable impact**
  - With VoiceOver: confirm each row reads as one element ("…Online, PRO, selected, button"),
    not several disjointed announcements.
- **P4 — Doesn't follow best practice**
  - With VoiceOver: confirm the decorative sparkle is skipped entirely (it should never take
    focus).

### WCAG
- [wcag-1.1.1]: 1.1.1 Non-text Content — the status dot, badge, sparkle and checkmark each need a
  text alternative or to be marked decorative.
- [wcag-1.4.5]: 1.4.5 Images of Text — the "PRO" badge.
- [wcag-4.1.2]: 4.1.2 Name, Role, Value — the row's button role and exposed selected state.

<!-- No "Learn more" section: this skill declares no how-to/blog/video references yet, so there's
     nothing to cite and the agent must not invent any. (If the agent knows useful resources, it
     suggests them to the developer in chat as unverified, for the author to add later.) -->
```

## Notes for whoever evaluates this

- The interesting failure modes are *misclassification* (treating the status dot as decorative,
  or the sparkle as meaningful) and *uniform treatment* (same handling for all four). A skill
  that only handles the happy path won't catch these.
- The status dot is a legitimate "ask the developer?" candidate in the abstract, but here the
  surrounding `isOnline` data makes the intent clear, so deciding-and-stating is acceptable.
  Asking would also be acceptable.
- Priorities above are estimates for a device-picker flow; in a different flow the same items
  could shift (e.g. selection might be P1 in a destructive-action picker).
- The list framing is deliberate: it gives the `.isSelected` trait a real parent (the row
  control) and lets the evaluator check that selection *moves* between rows — a stronger test of
  the selected-state lesson than a single static row.
