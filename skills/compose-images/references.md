# References — compose-images

Links cited from [`SKILL.md`](SKILL.md) and the generated test plan **by anchor** (e.g.
`[wcag-1.1.1]`). One place to maintain, so link rot is fixed in a single PR.

> The WCAG success criteria below were **specified by the skill's author** — not chosen by an
> agent. When following this skill, cite only the references listed here; never add a criterion or
> doc of your own, and never invent a URL for a blank slot — cite it by name and note it pending.
>
> (How these URLs are constructed and verified is authoring guidance — see `CONTRIBUTING.md`.)

---

## WCAG success criteria

### [wcag-1.1.1] WCAG 2.2 — 1.1.1 Non-text Content (Level A)
URL: https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html
Why it matters here: every image must either present a text alternative that serves the
equivalent purpose, or be marked decorative (`contentDescription = null`) so AT ignores it. This
is the primary criterion for this skill.
Type: wcag

### [wcag-1.4.5] WCAG 2.2 — 1.4.5 Images of Text (Level AA)
URL: https://www.w3.org/WAI/WCAG22/Understanding/images-of-text.html
Why it matters here: applies when an image contains text — the text alternative must be the text,
and real text is preferred where possible.
Type: wcag

### [wcag-4.1.2] WCAG 2.2 — 4.1.2 Name, Role, Value (Level A)
URL: https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html
Why it matters here: applies to the interactive-image and selected-state cases — the control
needs a name, a role, and its selected state exposed (via `selectable`/`selected` semantics).
Type: wcag

## How-to / assistive technology

### [compose-accessibility] Accessibility in Jetpack Compose (Android Developers)
URL: https://developer.android.com/develop/ui/compose/accessibility
Why it matters here: the canonical Compose accessibility doc — covers `contentDescription`,
semantics, and marking decoration with `null`. The platform-native reference for the treatments
this skill applies.
Type: how-to

### [compose-semantics] Semantics in Jetpack Compose (Android Developers)
URL: https://developer.android.com/develop/ui/compose/accessibility/semantics
Why it matters here: backs the `stateDescription`, `selectable`/`toggleable`, and merged-semantics
guidance in the decision-tree.
Type: how-to

## Learn more (blog / video)

### [learn-images-tutorial] W3C WAI — Images Tutorial
URL: https://www.w3.org/WAI/tutorials/images/
Why it matters here: the canonical explainer for informative vs. decorative vs. functional images
and how to describe them — maps directly onto this skill's decision summary. (Examples are
web/HTML; the decorative-vs-meaningful reasoning is platform-neutral.)
Type: blog

### [learn-alt-decision-tree] W3C WAI — An alt Decision Tree
URL: https://www.w3.org/WAI/tutorials/images/decision-tree/
Why it matters here: a step-by-step decision tree for whether and how to describe an image; the
reasoning mirrors this skill's "describe / null / ask" branches. (Web-oriented; principles transfer.)
Type: blog

### [learn-alt-tips] W3C WAI — Images Tutorial: Tips and Tricks
URL: https://www.w3.org/WAI/tutorials/images/tips/
Why it matters here: how to *phrase* a good text alternative — concise, most-important-first, no
"image"/"icon" filler — which fills the gap where this skill says "concise description" but doesn't
teach how. (Web-oriented; principles transfer.)
Type: blog

### [learn-complex-images] W3C WAI — Images Tutorial: Complex Images
URL: https://www.w3.org/WAI/tutorials/images/complex/
Why it matters here: how to make charts, graphs and diagrams accessible with a short description
plus fuller information nearby — backs this skill's complex-image branch. (Web-oriented; principles
transfer.)
Type: blog
