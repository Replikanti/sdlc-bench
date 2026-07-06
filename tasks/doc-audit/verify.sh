#!/usr/bin/env bash
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=doc-audit-findings.md
[ -f "$F" ] || fail "no findings file"
grep -q 'legacy.rs' "$F" || fail "missed planted fake source file legacy.rs"
grep -q 'USAGE-GUIDE' "$F" || fail "missed planted broken doc reference USAGE-GUIDE"
grep -q 'denny' "$F" || fail "missed planted wrong command 'cargo denny'"
echo "VERIFY PASS"
