#!/usr/bin/env bash
#
# stamp-version.sh — propagate the canonical collection version (the VERSION file) into the
# `version:` frontmatter line of every skills/**/SKILL.md.
#
# This project uses FIXED (locked) versioning: there is ONE version for the whole skill
# collection, stamped identically into every skill so a vendored skill folder stays
# self-identifying even when separated from this repo's git history. The version is
# machine-managed — do not hand-edit the `version:` line in a SKILL.md.
#
# Usage:
#   scripts/stamp-version.sh           # stamp VERSION into every SKILL.md (writes files)
#   scripts/stamp-version.sh --check   # verify every SKILL.md matches VERSION; exit 1 on drift
#
# The release GitHub Action runs this after bumping VERSION; you can also run it locally.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version_file="$repo_root/VERSION"

if [[ ! -f "$version_file" ]]; then
  echo "error: VERSION file not found at $version_file" >&2
  exit 1
fi

version="$(tr -d '[:space:]' < "$version_file")"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: VERSION '$version' is not semver (x.y.z)" >&2
  exit 1
fi

check_only=false
[[ "${1:-}" == "--check" ]] && check_only=true

skill_files=()
while IFS= read -r f; do
  skill_files+=("$f")
done < <(find "$repo_root/skills" -type f -name SKILL.md 2>/dev/null | sort)

if [[ ${#skill_files[@]} -eq 0 ]]; then
  echo "warning: no skills/**/SKILL.md files found; nothing to stamp" >&2
  exit 0
fi

drift=0
for f in "${skill_files[@]}"; do
  # Read the value, tolerating an optional trailing "# comment" (valid YAML) and whitespace.
  current="$(grep -m1 '^version:' "$f" | sed -E 's/^version:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//' || true)"
  if [[ "$current" == "$version" ]]; then
    continue
  fi
  if $check_only; then
    echo "drift: $f has version '$current', expected '$version'"
    drift=1
  else
    # Replace the existing version: line in place. Requires a version: line to exist.
    if ! grep -q '^version:' "$f"; then
      echo "error: $f has no 'version:' frontmatter line to stamp" >&2
      exit 1
    fi
    tmp="$(mktemp)"
    # Replace only the value, preserving an optional trailing "# comment".
    sed -E "s|^version:[[:space:]]*[^#]*(#.*)?$|version: $version \1|; s|[[:space:]]+$||" "$f" > "$tmp"
    mv "$tmp" "$f"
    echo "stamped $f -> $version"
  fi
done

if $check_only && [[ $drift -ne 0 ]]; then
  echo "error: one or more SKILL.md versions differ from VERSION ($version)" >&2
  exit 1
fi

$check_only && echo "ok: all SKILL.md match VERSION ($version)"
exit 0
