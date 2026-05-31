# Changelog

Repository-level history. Individual skills also carry their own `version` in `SKILL.md`
frontmatter. This project follows [semver](https://semver.org/) and
[Keep a Changelog](https://keepachangelog.com/) conventions.

## [Unreleased]

### Added
- Repository conventions: `README.md`, `CONTRIBUTING.md`, `DECISIONS.md`, and templates
  (`SKILL_TEMPLATE.md`, `references.template.md`).
- First skill: `swiftui-images` (0.1.0) — accessible handling of Images and SF Symbols in
  SwiftUI, with a build-time decision tree, AT-neutral and prioritised output contract, and a
  `mixed-images` trap fixture.
- MIT `LICENSE`.
- Fixed (single) collection versioning: root `VERSION` file, `scripts/stamp-version.sh`, a
  manual-dispatch **Release** workflow, and a CI **Check versions** workflow.
- WCAG reference verification: canonical `wcag-slugs.yml` map, `scripts/check-references.sh`
  (validates each WCAG URL against the map and that it resolves), and a CI **Check references**
  workflow. Lets the agent fill WCAG Understanding-doc URLs from author-specified SC numbers
  while a machine catches wrong slugs or dead links.
