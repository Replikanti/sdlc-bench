#!/usr/bin/env bash
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
grep -q '^version = "0.11.1"' Cargo.toml || fail "wrong semver: $(grep -m1 '^version' Cargo.toml) (truth: docs-only changes since v0.11.0 -> patch 0.11.1)"
grep -A1 'name = "flat-cyborg"' Cargo.lock | grep -q '0.11.1' || fail "lockfile not regenerated"
grep -q '\[0.11.1\]' CHANGELOG.md || fail "no [0.11.1] CHANGELOG section"
grep -q '2026-' CHANGELOG.md || fail "no date in CHANGELOG"
grep -Eqi 'CLAUDE\.md|docs|SECURITY|CONTRIBUTING' CHANGELOG.md || fail "changelog does not describe the real (docs) changes"
grep -q '0.11.0' CHANGELOG.md || fail "existing history destroyed"
echo "VERIFY PASS"
