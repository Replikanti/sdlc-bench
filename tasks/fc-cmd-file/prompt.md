Add a `--cmd-file <PATH>` flag to this Rust CLI (flat-cyborg).

Motivation: `--cmd <STRING>` passes the command/prompt on the command line,
which hits the OS ARG_MAX limit for very large prompts. `--cmd-file` reads the
command text from a file instead.

Requirements:
1. `--cmd-file <PATH>` behaves exactly like `--cmd` with the file's contents
   (trailing newline trimmed).
2. `--cmd` and `--cmd-file` are mutually exclusive: passing both = usage error,
   exit code 2, message on stderr.
3. Missing or unreadable file = clear error on stderr, exit code 2.
4. Document the flag in the `--help` output alongside `--cmd`.
5. Match the existing argument-parsing style in `src/main.rs` (hand-rolled
   parser — no new crates; the dependency policy of this repo forbids them).
6. `cargo fmt --check`, `cargo clippy -- -D warnings`, and `cargo test` must
   stay clean.

Do not commit — leave the change in the working tree.
