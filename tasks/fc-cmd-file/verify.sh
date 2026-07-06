#!/usr/bin/env bash
# PASS = --cmd-file works end-to-end and the suite stays green.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
cargo build 2>/dev/null || fail "cargo build"
BIN=./target/debug/flat-cyborg
$BIN --help 2>&1 | grep -q 'cmd-file' || fail "--help does not document --cmd-file"
# functional: command text read from file reaches the target
printf 'echo bench-marker-123\n' > /tmp/bench-cmd-$$.txt
OUT=$(timeout 30 $BIN --cmd-file /tmp/bench-cmd-$$.txt --timeout-ms 8000 --idle-ms 800 -- sh 2>/dev/null || true)
rm -f /tmp/bench-cmd-$$.txt
echo "$OUT" | grep -q 'bench-marker-123' || fail "file content did not reach the target CLI"
# error paths
set +e
$BIN --cmd-file /nonexistent-bench-file -- true >/dev/null 2>&1; RC1=$?
$BIN --cmd x --cmd-file /tmp/whatever -- true >/dev/null 2>&1; RC2=$?
set -e
[ "$RC1" -eq 2 ] || fail "missing file: expected exit 2, got $RC1"
[ "$RC2" -eq 2 ] || fail "--cmd + --cmd-file together: expected exit 2, got $RC2"
cargo fmt --check || fail "fmt"
cargo clippy -- -D warnings 2>/dev/null || fail "clippy"
cargo test --quiet 2>/dev/null || fail "cargo test"
echo "VERIFY PASS"
