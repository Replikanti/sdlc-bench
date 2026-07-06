#!/usr/bin/env bash
# PASS = correct owning-repo routing + well-formed English draft.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=issue-draft.md
[ -f "$F" ] || fail "no issue-draft.md"
grep -q '^verdict: FILE' "$F" || fail "missing verdict line"
grep -q '^repo: flat-cyborg' "$F" || fail "wrong routing: $(grep '^repo:' "$F" || echo none) (truth: flat-cyborg — the ARG_MAX limit lives in the PTY wrapper's --cmd argument path)"
grep -q '^title: ' "$F" || fail "missing title"
grep -q '^## Problem' "$F" || fail "missing Problem section"
grep -q '^## Acceptance criteria' "$F" || fail "missing Acceptance criteria"
grep -q '^- \[ \]' "$F" || fail "no checkbox criteria"
! grep -qP '[ěščřžýáíéůúťďňĚŠČŘŽÝÁÍÉŮÚŤĎŇ]' "$F" || fail "body not in English (Czech diacritics found)"
! grep -q '/home/' "$F" || fail "internal absolute path leaked"
echo "VERIFY PASS"
