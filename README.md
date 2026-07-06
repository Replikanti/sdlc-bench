# sdlc-bench

Measures the **minimal (model, effort) tier that solves a task cheapest** for
the kind of work the Replikanti repos actually see. The results calibrate the
`model:`/`effort:` frontmatter of the envelope SDLC agents in
`~/git/Replikanti/.claude/agents/` — trust measured data over intuition.

## Design

- **Tasks are real history.** Each task re-implements a merged PR at its parent
  commit (SWE-bench pattern), or a real documented gap. The prompt is written
  as the issue would be — it never leaks the merged diff.
- **Verification is objective.** `verify.sh` runs in the attempt's worktree and
  checks behavior (functional probes, repo suites, structural asserts), exit
  0 = PASS.
- **Ladder, cheapest first.** `haiku:medium → haiku:high → sonnet:medium →
  sonnet:high → sonnet:xhigh → opus:high → opus:xhigh` (bounds per policy:
  never below haiku/medium, never above Opus 4.8/xhigh). The runner stops at
  the first passing tier — that IS the answer — unless `--full-grid`.
- **Isolation.** Every attempt gets a fresh detached `git worktree` under
  `runs/`; attempts run `claude -p --dangerously-skip-permissions` INSIDE that
  worktree. Tasks come from our own repos; review any new task's prompt before
  adding it.

## What transfers and what doesn't

The **harness transfers**: the runner knows nothing about any language or
framework — it creates a worktree, runs a headless `claude -p` attempt, runs
the task's `verify.sh`, records the exit code and cost. All stack-specific
knowledge lives in the tasks you write (`task.json` points at YOUR repo,
`verify.sh` calls YOUR test runner and linters).

The **results do not transfer**: the tier table in `runs/results.jsonl` is
calibrated to this corpus (framework-free Rust, an agent DSL, POSIX shell).
A different codebase will place the capability boundaries elsewhere. Don't
adopt our numbers — run your own corpus; that is the point of the tool.

The default ladder assumes Claude Code as the agent runtime (`claude -p`,
`--model`, `effortLevel`). Using a different agent CLI means swapping the one
invocation block in `run-bench.sh` and redefining the ladder tiers.

## Usage

```bash
./run-bench.sh --task store-sha256                  # one task, walk the ladder
./run-bench.sh --all                                # whole corpus
./run-bench.sh --task fc-cmd-file --full-grid       # don't stop at first pass
./run-bench.sh --task X --ladder "haiku:medium sonnet:high"   # custom ladder
./summarize.sh                                      # per-task min passing tier + costs
```

Results accumulate in `runs/results.jsonl`
(`{task, model, effort, pass, tokens, cost_usd, duration_ms, num_turns, ...}`).

## Corpus

| Task | Repo | Class | Source |
|------|------|-------|--------|
| `store-sha256` | agentis (storefront) | shell-small | real gap: install.sh lacks sidecar verification |
| `col-continuation-cleanup` | agentis-colonies | ag-small | merged PR #1425 re-implementation |
| `col-slots-dir-pin` | agentis-colonies | shell-small | merged PR #1418 re-implementation |
| `fc-cmd-file` | flat-cyborg | rust-small | merged PR #57 re-implementation |

## Adding a task

```
tasks/<id>/task.json   # repo_path, base_ref (merge-commit PARENT), class, timeout_s
tasks/<id>/prompt.md   # issue-style prompt; no solution leakage
tasks/<id>/verify.sh   # objective PASS check, run with cwd = worktree
```

Prefer PRs that ADDED tests: then verify.sh can copy the merged test files into
the worktree as a FAIL_TO_PASS oracle (strongest signal). The current corpus
predates that pattern for the chosen PRs (they shipped without new test files),
so verification is behavioral/structural instead.

agentis-core is not in the MVP corpus: its full validation (cargo test on 197k
LOC per attempt per tier) makes attempts expensive; add core tasks with
narrowly-scoped verify commands (`cargo test <name>`, `check-*.sh`) when a
suitable small PR lands.

## Caveats

- One attempt per tier per run: LLM runs are stochastic, so a borderline tier
  can flip between runs. For decisions that matter, run the ladder 2-3× and
  require a tier to pass consistently before pinning it in agent frontmatter.
- `cost_usd`/token fields come from `claude -p --output-format json` usage;
  on a subscription they represent metered-equivalent cost, not marginal spend.
- A task PASSING at a tier says the tier can do it; it does not certify code
  quality beyond what verify.sh checks. Spot-read cheap-tier diffs before
  trusting a downgrade.
