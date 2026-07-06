#!/usr/bin/env bash
# PASS = ag_edit_reset now removes the continuation file, file still parses.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
F=dev-apprenticeship/implementation/agents/code_writer.ag
[ -f "$F" ] || fail "missing $F"
# extract the ag_edit_reset function body (from its fn line to the next top-level fn)
BODY=$(awk '/fn ag_edit_reset/{on=1} on{print} on && /^fn / && !/fn ag_edit_reset/{exit}' "$F")
[ -n "$BODY" ] || fail "ag_edit_reset not found"
echo "$BODY" | grep -Eq 'rm -f|rm "|file_delete|unlink' || fail "no deletion in ag_edit_reset"
echo "$BODY" | grep -qi 'continuation' || fail "deletion does not reference continuation file"
# the .ag must still parse if the agentis binary is available
if command -v agentis >/dev/null; then
  T=$(mktemp -d) && (cd "$T" && agentis init >/dev/null 2>&1 && agentis commit "$OLDPWD/$F" >/dev/null 2>&1) || fail "agentis parse"
  rm -rf "$T"
fi
echo "VERIFY PASS"
