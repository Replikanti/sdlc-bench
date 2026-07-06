#!/usr/bin/env bash
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=review-findings.md
[ -f "$F" ] || fail "no findings file"
grep -qi 'jitter' "$F" || fail "missed the jitter.rs defect"
grep -Eqi 'ALNUM_DELAY|120.*40|invert|revers|swap|min.*max|backwards' "$F" || fail "jitter defect not identified"
grep -Eqi 'detect|line_ends_with_any' "$F" || fail "missed the detect.rs defect"
grep -Eqi 'starts_with|ends_with' "$F" || fail "detect defect not identified"
N=$(grep -cE '^[0-9]+\.' "$F" || true)
[ "$N" -le 3 ] || fail "over-reporting: $N defects claimed (2 planted)"
! grep -E '^[0-9]+\.' "$F" | grep -q 'update\.rs' || fail "false positive: benign update.rs comment edit flagged as defect"
! grep -E '^[0-9]+\.' "$F" | grep -q 'CLAUDE\.md' || fail "false positive: benign CLAUDE.md wording edit flagged as defect"
echo "VERIFY PASS"
