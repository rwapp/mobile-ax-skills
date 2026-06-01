# References — <skill name>

Links used by this skill, cited from `SKILL.md` and the generated test plan **by anchor**
(e.g. `[wcag-1.1.1]`). One place to maintain, so link rot is fixed in a single PR.

> **Contributor note (required):** supplying correct, **verified** URLs for every slot below
> is an expected part of contributing or maintaining a skill, and is checked in review. The
> agent never invents URLs — if a slot's URL is blank when the skill runs, the agent cites the
> slot by name and notes the link is pending.

Each entry follows this shape:

```
### [anchor-id] Human-readable title
URL: <!-- TODO(maintainer): add verified URL -->
Why it matters here: <one line tying it to this skill's guidance>
Type: wcag | how-to | demo | blog | video | apple-docs
```

---

## WCAG success criteria

> WCAG SC URLs are **derived, not guessed**: take the slug from the canonical `/wcag-slugs.yml`
> map (the SC's dashed name, e.g. `non-text-content`) and build the **Understanding** URL
>
>     https://www.w3.org/WAI/WCAG22/Understanding/<slug>.html
>
> If the SC isn't in `wcag-slugs.yml` yet, add it there (slug verified against w3.org) — don't
> invent a slug. CI (`scripts/check-references.sh`) checks every WCAG URL matches the map and
> resolves, so the agent may fill these from the author-specified SC numbers.

### [wcag-x.x.x] WCAG 2.2 — <number Name>
URL: https://www.w3.org/WAI/WCAG22/Understanding/<slug>.html
Why it matters here: <one line>
Type: wcag

## How-to / assistive technology

> **Author-only.** The generating agent must **not** add entries here — choosing which docs to
> cite is a human decision (an agent that knows useful resources *suggests them in chat* for you
> to verify, never writes them in). Add verified how-to / demo references yourself, each in the
> shape shown above. Leave empty if none.
>
> **Preferred source:** [Appt.org](https://appt.org/en/) — platform-specific mobile-accessibility
> documentation (iOS/SwiftUI, Android/Compose), with code examples and real assistive-technology
> usage data. Prefer it for how-to / AT references where it covers the topic; always verify the
> specific page resolves before adding it.

## Learn more (blog / video)

> **Author-only.** Same rule as above — the agent does not add these. Add verified blog / video
> references yourself. Leave empty if none. [Appt.org](https://appt.org/en/) is also a good first
> place to look for learning material.
