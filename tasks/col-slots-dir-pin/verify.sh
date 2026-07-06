#!/usr/bin/env bash
# PASS = all five start-colony.sh export a guarded, fed-pinned AGENTIS_LLM_SLOTS_DIR.
set -e
fail() { echo "VERIFY FAIL: $1"; exit 1; }
n=0
for c in triage planning implementation code-review release; do
  S="dev-apprenticeship/$c/scripts/start-colony.sh"
  [ -f "$S" ] || fail "missing $S"
  bash -n "$S" || fail "bash -n $S"
  grep -q 'AGENTIS_LLM_SLOTS_DIR' "$S" || fail "$c: no AGENTIS_LLM_SLOTS_DIR"
  grep -Eq 'AGENTIS_LLM_SLOTS_DIR.*llm-slots|llm-slots.*AGENTIS_LLM_SLOTS_DIR' "$S" || fail "$c: not pinned to llm-slots path"
  grep -Eq ':-|if .*AGENTIS_LLM_SLOTS_DIR|-z .*AGENTIS_LLM_SLOTS_DIR' "$S" || fail "$c: clobbers operator-set value"
  n=$((n+1))
done
[ "$n" -eq 5 ] || fail "covered $n/5 colonies"
echo "VERIFY PASS"
