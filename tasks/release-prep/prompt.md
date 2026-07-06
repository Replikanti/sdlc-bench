Prepare this Rust repository's next release in the working tree (do NOT
commit, do NOT tag, do NOT push).

Cut the release covering everything merged since the last released tag.
Inspect the repository itself (tags, `git log`, `CHANGELOG.md`) to find out
what changed — do not ask, the history is all there.

Do all of the following, consistent with how this repo versions itself:
1. Decide the correct semantic version from the actual changes and bump `Cargo.toml`.
2. Regenerate the lockfile so it matches.
3. Add the release section to `CHANGELOG.md` in the repo's existing format,
   dated today, describing the actual changes. Keep the existing history intact.
