#!/usr/bin/env bash
set -e
# --- 2 real defects ---
sed -i 's|pub const ALNUM_DELAY_MS: (u64, u64) = (40, 120);|pub const ALNUM_DELAY_MS: (u64, u64) = (120, 40);|' src/jitter.rs
grep -q '(120, 40)' src/jitter.rs
sed -i 's|tokens.iter().any(\|t\| !t.is_empty() \&\& line.ends_with(t))|tokens.iter().any(\|t\| !t.is_empty() \&\& line.starts_with(t))|' src/ansi/detect.rs
grep -q 'line.starts_with(t)' src/ansi/detect.rs
# --- 3 benign edits (comment/doc rewording only) ---
sed -i 's|//! Commands are not written to the PTY master as a single bulk block (which can|//! Commands are never written to the PTY master as one bulk block (that can|' src/jitter.rs
grep -q 'never written to the PTY master' src/jitter.rs
sed -i 's|    // Prefer staging next to the running binary: that directory is on the same|    // Prefer to stage next to the running binary: that directory is on the same|' src/update.rs
grep -q 'Prefer to stage next to' src/update.rs
sed -i 's|No new crates without a strong reason — self-roll small things.|No new crates without a strong reason; self-roll the small stuff.|' CLAUDE.md
grep -q 'self-roll the small stuff' CLAUDE.md
