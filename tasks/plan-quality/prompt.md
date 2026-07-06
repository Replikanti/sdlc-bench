Write an implementation plan for the following feature in this Rust repository
(a PTY wrapper for driving interactive CLIs). Plan only — do not implement.

Feature: an opt-in `--paste-input` flag. When set, command/prompt delivery to
the target CLI uses bracketed paste (wrap the text in the ESC[200~ / ESC[201~
markers, single write) instead of the default per-character typing path.
Default behavior must not change.

Ground the plan in THIS codebase: read the code first and name the exact
files and functions/structs you would touch. Write the plan to a file named
`plan.md` in the current directory with sections: ## Approach, ## Changes
(numbered list with backticked file paths), ## Tests, ## Validation,
## Out of scope.
