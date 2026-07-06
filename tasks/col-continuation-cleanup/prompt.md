Bug fix in `dev-apprenticeship/implementation/agents/code_writer.ag`.

Bug: the `ag_edit_reset` helper resets the per-issue caller-driven edit-loop
state, but it leaves the continuation file behind. A stale continuation file
from the previous issue then leaks its instructions into the FIRST attempt of
the next issue handled in the same job dir.

Fix: as part of `ag_edit_reset`, also delete the continuation file, following
the same conventions the rest of this .ag file uses for filesystem work (find
how the continuation file path is derived elsewhere in the file and reuse that;
wrap any dynamic values passed to `exec sh` in `shell_escape()`).

Do not change any other behavior. Do not commit — leave the change in the
working tree.
