#!/usr/bin/env bash
set -e
sed -i 's|jitter.rs      per-char human-like delays, SplitMix64 PRNG, type_command|jitter.rs      per-char human-like delays, SplitMix64 PRNG, type_command\nlegacy.rs      compat shims for pre-0.5 config files|' CLAUDE.md
grep -q 'legacy.rs' CLAUDE.md
sed -i 's|User docs: `docs/USAGE.md` — update it whenever flags change.|User docs: `docs/USAGE-GUIDE.md` — update it whenever flags change.|' CLAUDE.md
grep -q 'USAGE-GUIDE' CLAUDE.md
sed -i 's|cargo deny check                 # license/advisory gate|cargo denny check                 # license/advisory gate|' CLAUDE.md
grep -q 'denny' CLAUDE.md
