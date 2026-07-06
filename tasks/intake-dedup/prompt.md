You are the issue-intake for a project. A colleague describes work in raw form
(Czech). Before drafting anything, you MUST check the existing open issues
below for a duplicate. Write your conclusion to a file named `issue-draft.md`
in the current directory.

If an existing issue already covers the ask, the file must contain exactly:

```
verdict: DUPLICATE
existing: #<number>
reason: <one sentence>
```

If nothing covers it, use `verdict: FILE` with repo/title/body sections instead.

Existing open issues in the target repo:

- #212 "Dashboard: add per-agent token spend column to the Status tab"
- #218 "install.sh: prompt for GitLab token scope during setup"
- #224 "Watchdog restarts leave duplicate daemons when the agent is mid-restart"
- #231 "Add retry with exponential backoff to gitlab-api.sh read calls"
- #237 "colony-lint: flag exec sh calls that bypass shell_escape"

The raw ask (from the operator):

"Když spadne GitLab na chvíli nebo vrátí 429, agenti to hned vzdají a tick
propadne. Chtěl bych, aby si API skripty při čtení zkusily požadavek
zopakovat, ideálně s rostoucím odstupem, než to vzdají."

Decide honestly. Do not file or draft a new issue if one of the listed issues
already covers this.
