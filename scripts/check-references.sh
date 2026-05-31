#!/usr/bin/env bash
#
# check-references.sh — verify the WCAG reference URLs in every skills/**/references.md.
#
# For each WCAG entry (an anchor like [wcag-1.1.1] followed by a `URL:` line) this checks:
#   1. the SC number maps to a known slug in /wcag-slugs.yml (else FAIL — add it to the map);
#   2. the URL is the expected Understanding URL for that slug (else FAIL — wrong/guessed slug);
#   3. the URL resolves to HTTP 200 (FAIL on 404/4xx/5xx; WARN, don't fail, on network errors).
#
# A still-blank slot (URL line is a TODO/placeholder, no http URL) is reported as PENDING and is
# NOT a failure — slots are filled over time.
#
# Usage: scripts/check-references.sh            (checks all skills)
#
# Exit non-zero if any hard check fails. Network-unreachable is a warning only (soft-fail), so a
# w3.org or CI outage doesn't produce a spurious red build.

set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
slug_map="$repo_root/wcag-slugs.yml"
base="https://www.w3.org/WAI/WCAG22/Understanding"

if [[ ! -f "$slug_map" ]]; then
  echo "error: slug map not found at $slug_map" >&2
  exit 1
fi

# Look up the canonical slug for an SC number from wcag-slugs.yml. Echoes slug or empty.
slug_for() {
  local sc="$1"
  # Match lines like:  "1.1.1": non-text-content   (tolerate optional quotes/spaces)
  grep -E "^[[:space:]]*\"?${sc//./\\.}\"?[[:space:]]*:" "$slug_map" \
    | head -n1 \
    | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]*(#.*)?$//; s/^"//; s/"$//'
}

# curl a URL, echo the HTTP status, or "NETERR" if the request itself failed.
http_status() {
  local url="$1" code
  code="$(curl -s -o /dev/null -L --max-time 20 -w '%{http_code}' "$url" 2>/dev/null)"
  if [[ -z "$code" || "$code" == "000" ]]; then
    echo "NETERR"
  else
    echo "$code"
  fi
}

hard_fail=0
checked=0
pending=0
warned=0

while IFS= read -r ref_file; do
  # Walk the file; remember the most recent wcag anchor's SC number, then act on its URL: line.
  current_sc=""
  while IFS= read -r line; do
    if [[ "$line" =~ \[wcag-([0-9]+\.[0-9]+\.[0-9]+)\] ]]; then
      current_sc="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ -n "$current_sc" && "$line" =~ ^URL: ]]; then
      url="$(printf '%s' "$line" | sed -E 's/^URL:[[:space:]]*//')"
      sc="$current_sc"
      current_sc=""   # consume

      # Blank / placeholder (no real http(s) URL) -> pending, not a failure.
      if [[ ! "$url" =~ https?:// ]]; then
        echo "PENDING  $ref_file  wcag-$sc  (URL not filled yet)"
        pending=$((pending+1))
        continue
      fi

      checked=$((checked+1))
      expected_slug="$(slug_for "$sc")"

      if [[ -z "$expected_slug" ]]; then
        echo "FAIL     $ref_file  wcag-$sc  — SC not in wcag-slugs.yml; add its verified slug there"
        hard_fail=1
        continue
      fi

      expected_url="$base/$expected_slug.html"
      if [[ "$url" != "$expected_url" ]]; then
        echo "FAIL     $ref_file  wcag-$sc  — URL '$url' != expected '$expected_url'"
        hard_fail=1
        continue
      fi

      status="$(http_status "$url")"
      case "$status" in
        200)    echo "OK       $ref_file  wcag-$sc  $url" ;;
        NETERR) echo "WARN     $ref_file  wcag-$sc  — network error reaching w3.org (not failing)"; warned=$((warned+1)) ;;
        *)      echo "FAIL     $ref_file  wcag-$sc  — HTTP $status for $url"; hard_fail=1 ;;
      esac
    fi
  done < "$ref_file"
done < <(find "$repo_root/skills" -type f -name references.md 2>/dev/null | sort)

echo ""
echo "Checked $checked WCAG URL(s); $pending pending; $warned warning(s)."

if [[ $hard_fail -ne 0 ]]; then
  echo "Reference check FAILED." >&2
  exit 1
fi
echo "Reference check passed."
exit 0
