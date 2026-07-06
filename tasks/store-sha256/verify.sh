#!/usr/bin/env bash
# PASS = install.sh gained plausible fail-closed sidecar verification and stays clean.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
[ -f install.sh ] || fail "install.sh missing"
sh -n install.sh || fail "sh -n"
if command -v shellcheck >/dev/null; then shellcheck -S warning install.sh || fail "shellcheck"; fi
grep -q 'sha256' install.sh || fail "no sha256 handling"
grep -Eq 'sha256sum|shasum' install.sh || fail "no checksum tool invocation"
grep -q 'AGENTIS_STRICT_VERIFY' install.sh || fail "no strict-verify env gate"
grep -Eq '\.sha256' install.sh || fail "no sidecar filename reference"
# bash/POSIX portability guard: no obvious bashisms
! grep -En '\[\[|function [a-z]|local ' install.sh >/dev/null || fail "bashism detected"
echo "VERIFY PASS"
