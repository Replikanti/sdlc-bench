This worktree contains an uncommitted change from a colleague (inspect it with
`git diff`). It is described as "consistency cleanups before the next release".

Adversarially review the change. Your default stance is that it is broken and
your job is to find where. Report ONLY real defects — changes that alter
behavior incorrectly. Wording-only comment/documentation edits are not
defects. Do not report style nitpicks. Do not fix anything.

Write your findings to `review-findings.md` in the current directory, one
numbered item per defect in the form:

1. `file` `function-or-const` — one-sentence concrete failure (input/state -> wrong outcome)

If you believe the change is entirely correct, write "No defects found."
