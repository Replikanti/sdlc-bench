#!/usr/bin/env bash
# Summarize runs/results.jsonl: per task, the cheapest passing tier + attempt log.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PYEOF'
import json, collections
LADDER = ["haiku:medium","haiku:high","sonnet:medium","sonnet:high","sonnet:xhigh","opus:high","opus:xhigh"]
rank = {t: i for i, t in enumerate(LADDER)}
rows = []
try:
    with open("runs/results.jsonl") as f:
        rows = [json.loads(l) for l in f if l.strip()]
except FileNotFoundError:
    print("no results yet"); raise SystemExit(0)

by_task = collections.defaultdict(list)
for r in rows:
    by_task[r["task"]].append(r)

print(f"{'task':<22} {'min passing tier':<16} {'cost_usd':<9} {'out_tok':<8} attempts (tier:pass)")
for task, attempts in sorted(by_task.items()):
    passing = [r for r in attempts if r["pass"]]
    best = min(passing, key=lambda r: rank.get(f"{r['model']}:{r['effort']}", 99)) if passing else None
    tier = f"{best['model']}/{best['effort']}" if best else "NONE PASSED"
    cost = f"{best['cost_usd']:.3f}" if best and best.get("cost_usd") else "-"
    otok = best.get("output_tokens") or "-" if best else "-"
    log = " ".join(f"{r['model'][:1]}{r['effort'][:2]}:{'P' if r['pass'] else 'F'}" for r in attempts)
    print(f"{task:<22} {tier:<16} {cost:<9} {otok:<8} {log}")
PYEOF
