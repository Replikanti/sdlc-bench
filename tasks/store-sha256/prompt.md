Add fail-closed checksum verification to `install.sh` in this repo.

Context: every GitHub release of this project ships a `<binary>.sha256` sidecar
(sha256sum format) next to each binary, but install.sh currently only checks
that the download is non-empty.

Requirements:
1. After downloading the binary, download `<BINARY>.sha256` from the same release.
2. Verify the binary against it: `sha256sum -c` on Linux, `shasum -a 256 -c` on macOS (pick whichever tool exists).
3. On checksum MISMATCH: print a clear error, delete the temp file, exit non-zero (fail closed).
4. If the sidecar itself cannot be downloaded (older releases lack it): print a warning and continue — UNLESS the env var `AGENTIS_STRICT_VERIFY=1` is set, in which case abort.
5. Keep the script POSIX sh (dash-compatible, no bashisms) and `shellcheck -S warning` clean.

Do not touch anything else in the repo. Do not commit — leave the change in the working tree.
