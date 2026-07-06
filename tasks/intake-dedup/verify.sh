#!/usr/bin/env bash
# PASS = the planted near-duplicate (#231) is detected, no new issue drafted.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=issue-draft.md
[ -f "$F" ] || fail "no issue-draft.md"
grep -q '^verdict: DUPLICATE' "$F" || fail "did not detect the duplicate ($(grep '^verdict:' "$F" || echo 'no verdict'))"
grep -Eq '^existing: #?231' "$F" || fail "wrong existing issue: $(grep '^existing:' "$F" || echo none)"
echo "VERIFY PASS"
