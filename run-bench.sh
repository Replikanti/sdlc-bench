#!/usr/bin/env bash
# sdlc-bench runner: for each task, walk the model/effort ladder from cheapest
# up and record the first (model, effort) tier that passes verification.
#
# Usage:
#   ./run-bench.sh --task <id> [--task <id> ...]   # specific tasks
#   ./run-bench.sh --all                           # every task in tasks/
#   ./run-bench.sh --task <id> --full-grid         # don't stop at first pass
#   ./run-bench.sh --task <id> --ladder "haiku:medium sonnet:high"
#
# Results: runs/results.jsonl (one row per attempt) — summarize with ./summarize.sh
#
# NOTE: attempts run `claude -p` with --dangerously-skip-permissions inside a
# disposable git worktree. Tasks come from our own repos; review task prompts
# before adding new ones.

set -euo pipefail
BENCH_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNS_DIR="$BENCH_DIR/runs"
RESULTS="$RUNS_DIR/results.jsonl"
LADDER="haiku:medium haiku:high sonnet:medium sonnet:high sonnet:xhigh opus:high opus:xhigh"
FULL_GRID=0
TASKS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASKS+=("$2"); shift 2 ;;
    --all) for d in "$BENCH_DIR"/tasks/*/; do TASKS+=("$(basename "$d")"); done; shift ;;
    --ladder) LADDER="$2"; shift 2 ;;
    --full-grid) FULL_GRID=1; shift ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done
[[ ${#TASKS[@]} -gt 0 ]] || { echo "no tasks selected (use --task <id> or --all)" >&2; exit 2; }

mkdir -p "$RUNS_DIR"

jget() { python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d$2)" "$1" 2>/dev/null || echo ""; }

for task in "${TASKS[@]}"; do
  TDIR="$BENCH_DIR/tasks/$task"
  [[ -f "$TDIR/task.json" ]] || { echo "SKIP $task: no task.json" >&2; continue; }
  REPO_PATH=$(jget "$TDIR/task.json" "['repo_path']")
  REPO_PATH="${REPO_PATH/#\~/$HOME}"
  BASE_REF=$(jget "$TDIR/task.json" "['base_ref']")
  TIMEOUT_S=$(jget "$TDIR/task.json" "['timeout_s']")
  echo "=== task $task (repo=$REPO_PATH base=$BASE_REF) ==="

  for tier in $LADDER; do
    MODEL="${tier%%:*}"; EFFORT="${tier##*:}"
    STAMP=$(date +%Y%m%dT%H%M%S)
    WT="$RUNS_DIR/$task/$MODEL-$EFFORT-$STAMP"
    mkdir -p "$(dirname "$WT")"
    echo "--- tier $MODEL/$EFFORT -> $WT"
    git -C "$REPO_PATH" worktree add --detach "$WT" "$BASE_REF" >/dev/null 2>&1

    OUTJSON="$WT/.bench-claude-output.json"
    set +e
    ( cd "$WT" && timeout "${TIMEOUT_S:-900}" claude -p "$(cat "$TDIR/prompt.md")" \
        --model "$MODEL" \
        --settings "{\"effortLevel\":\"$EFFORT\"}" \
        --output-format json \
        --dangerously-skip-permissions \
        < /dev/null > "$OUTJSON" 2> "$WT/.bench-claude-stderr.log" )
    CLAUDE_RC=$?
    ( cd "$WT" && bash "$TDIR/verify.sh" > "$WT/.bench-verify.log" 2>&1 )
    VERIFY_RC=$?
    set -e

    PASS=$([[ $VERIFY_RC -eq 0 ]] && echo true || echo false)
    PASS_PY=$([[ $VERIFY_RC -eq 0 ]] && echo True || echo False)
    python3 - "$OUTJSON" <<PYEOF >> "$RESULTS"
import json, sys, time
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    d = {}
u = d.get("usage") or {}
row = {
  "ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
  "task": "$task", "model": "$MODEL", "effort": "$EFFORT",
  "pass": $PASS_PY, "claude_rc": $CLAUDE_RC, "verify_rc": $VERIFY_RC,
  "input_tokens": u.get("input_tokens"), "output_tokens": u.get("output_tokens"),
  "cache_read": u.get("cache_read_input_tokens"), "cost_usd": d.get("total_cost_usd"),
  "duration_ms": d.get("duration_ms"), "num_turns": d.get("num_turns"),
  "worktree": "$WT",
}
print(json.dumps(row))
PYEOF
    echo "    pass=$PASS (claude_rc=$CLAUDE_RC verify_rc=$VERIFY_RC)"
    git -C "$REPO_PATH" worktree remove --force "$WT" >/dev/null 2>&1 || true

    if [[ "$PASS" == "true" && "$FULL_GRID" -eq 0 ]]; then
      echo "    CHEAPEST PASSING TIER for $task: $MODEL/$EFFORT"
      break
    fi
  done
done
echo "done — results in $RESULTS; run ./summarize.sh"
