# Expected experience — `mixed-images` fixture (Compose)

What a correct run of the `compose-images` skill should produce for [`Before.kt`](Before.kt): the
code in [`After.kt`](After.kt), **plus** an `ACCESSIBILITY-TESTPLAN.md` entry resembling the one
below. This doubles as a "what good looks like" reference and the seed for the (deferred)
quality-bar discussion.

> **Why `Before.kt` is unannotated:** it is the test *input*, so it must not reveal the answers. It
> deliberately carries only the cues a developer would naturally write — including *careless*
> `contentDescription`s (the resource/role name) that satisfy Compose's required parameter without
> meaning. The agent has to recognise those as wrong and classify each image from context, as it
> would in a real codebase. All the classifications and reasoning live *here*, in the answer key.

## The trap

All four images are small glyphs/badges that *look* alike, but need four different treatments. A
skill that gives them the same treatment (e.g. nulls all icons, or describes all icons) has failed
the fixture. There's a Compose-specific twist: every image in `Before.kt` already *has* a
`contentDescription` — but it's the resource/role name ("Circle", "Check", "pro_badge"), which is
worse than useless. The agent must replace each with the right treatment, not assume "it has a
description, so it's handled".

| Image | Correct classification | Correct treatment |
|-------|------------------------|-------------------|
| `AutoAwesome` | Decorative | `contentDescription = null` |
| `Circle` (status dot) | Meaningful — sole online/offline cue | `contentDescription = "Online" / "Offline"` |
| `pro_badge` | Image of text | `contentDescription = "PRO"` |
| `Check` | Selected-state indicator | `null`; selection on the row via `selectable(selected = …)` |

A correct run should also let the **row** carry one merged announcement (via `selectable`) rather
than several fragments. Because this is a list where one row is selected, the selected state must
move with the selection — the chosen row carries it, the others don't.

## Expected `ACCESSIBILITY-TESTPLAN.md` entry

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

## DeviceList rows  (updated 2026-06-01)

### Intended accessibility experience
A TalkBack user moves through the list and hears one announcement per row covering the device
name, its status, its plan, and whether it's the selected row — e.g. "Living Room Speaker, Online,
PRO, selected, radio button" for the chosen device, and the same without "selected" for the others.
They never encounter the decorative flourish, and they never hear a meaningless "circle" or
"check". A Voice Access user can target a row by its device name.

### How to verify it yourself
⭐ Start here: I **assumed the green/grey dot means online/offline** (inferred from the `isOnline`
   flag) and described it "Online"/"Offline" — confirm that's what the dot actually means. If it
   means something else (available, recording, synced…), the description is confidently wrong and
   needs changing. With TalkBack on, also confirm each row *speaks* that status, not just shows a
   colour.

- **P1 — Blocker**
  - With TalkBack: confirm each row's status ("Online"/"Offline") is announced. It's the only cue,
    so if it's missing the end user cannot tell device state at all.
- **P2 — Significant impact**
  - With TalkBack: confirm the chosen row announces "selected" — not a stray "check", and not
    silence — and that the others do not. Select a different row and confirm "selected" moves with
    it.
  - With TalkBack: confirm "PRO" is announced on Pro rows (not "image" or the resource name).
  - With Voice Access: confirm a row can be targeted by its device name.
- **P3 — Noticeable impact**
  - With TalkBack: confirm each row reads as one announcement ("…Online, PRO, selected"), not
    several disjointed pieces.
- **P4 — Doesn't follow best practice**
  - With TalkBack: confirm the decorative flourish is skipped entirely (it should never take focus).

### WCAG
- [wcag-1.1.1]: 1.1.1 Non-text Content — the status dot, badge, flourish and check each need a text
  alternative or to be marked decorative (`contentDescription = null`).
- [wcag-1.4.5]: 1.4.5 Images of Text — the "PRO" badge.
- [wcag-4.1.2]: 4.1.2 Name, Role, Value — the row's selectable role and exposed selected state.

### Learn more
(No entries yet — this skill declares no how-to/blog/video references. The agent must not invent
any; it may suggest Android/TalkBack resources to the developer in chat as unverified.)
```

## Notes for whoever evaluates this

- The interesting failure modes are *misclassification* (treating the status dot as decorative, or
  the flourish as meaningful), *uniform treatment* (same handling for all four), and the
  Compose-specific one: **keeping the careless resource-name descriptions** ("Circle", "Check")
  because "it compiles and has a description". A skill that only handles the happy path won't catch
  these.
- The status dot is a legitimate "ask the developer?" candidate in the abstract, but here the
  surrounding `isOnline` data makes the intent clear, so deciding-and-stating (with the assumption
  surfaced) is acceptable. Asking would also be acceptable.
- Priorities are estimates for a device-picker flow; in a different flow the same items could shift.
- The list framing is deliberate: it gives the selected state a real owner (the `selectable` row)
  and lets the evaluator check that selection *moves* between rows — a stronger test than a single
  static row.
