Audit this repository's CLAUDE.md for documentation-vs-code drift. For every
claim it makes, check it against the actual repository state: do the files it
names exist, do the referenced docs exist, do the commands it tells you to run
actually parse/exist.

Write your findings to a file named `doc-audit-findings.md` in the current
directory as a table with columns File | Claim | Actual | Fix. Report only
real drift you verified with a command in this session. Do not fix anything.
