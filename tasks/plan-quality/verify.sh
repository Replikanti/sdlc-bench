#!/usr/bin/env bash
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=plan.md
[ -f "$F" ] || fail "no plan.md"
for s in "## Approach" "## Changes" "## Tests" "## Validation" "## Out of scope"; do
  grep -q "^$s" "$F" || fail "missing section $s"
done
grep -q 'src/wrapper.rs' "$F" || fail "plan misses the real input-delivery site src/wrapper.rs"
grep -q 'src/main.rs' "$F" || fail "plan misses the CLI flag site src/main.rs"
# hallucination guard: every backticked src/*.rs path must exist at base ref
for p in $(grep -oP '`\Ksrc/[a-z_/]+\.rs(?=`)' "$F" | sort -u); do
  [ -f "$p" ] || fail "plan references nonexistent file $p"
done
echo "VERIFY PASS"
