Fix a slot-pool split in the dev-apprenticeship federation.

Context: `tools/lib/llm-session-slot.sh` implements a federation-wide LLM
session semaphore. Its slot directory defaults to a path derived from the
caller's environment, so sessions spawned from different working contexts can
end up using DIFFERENT slot pools — which silently breaks the global
concurrency cap.

Fix: pin the slot directory to one federation-fixed location by exporting
`AGENTIS_LLM_SLOTS_DIR` (pointing at the federation's `.agentis/llm-slots`)
in ALL FIVE colony start scripts
(`dev-apprenticeship/{triage,planning,implementation,code-review,release}/scripts/start-colony.sh`).
Requirements:
- Derive the federation dir the same way each script already derives its paths.
- Do not clobber an operator-set `AGENTIS_LLM_SLOTS_DIR` already in the env.
- Keep the change identical/idiomatic across all five scripts.

Do not commit — leave the change in the working tree.
