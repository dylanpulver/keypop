# Contributing to keypop

keypop is deliberately tiny — one shell script, no dependencies, no build step. Keep it that way.

## Ground rules

- **No new runtime dependencies.** It must stay a single `bash` + `osascript` script that runs
  on a stock Mac. A dependency is a much bigger ask than a feature.
- **Every change stays shellcheck-clean** (`make lint`) and keeps the tests green (`make test`).
- **Non-trivial logic ships with a test.** The parser is covered by `test-parse.sh`; the
  write/check-first/import logic by `test-behavior.sh`. Both run headless (dialogs are stubbed),
  so add cases there rather than requiring a human to click.
- **Secrets never get logged, echoed, or written anywhere but the vault / an explicit `--env`
  target.** Reports show names and character counts only, never values.

## Running it locally

```bash
make lint     # shellcheck
make test     # both suites
make install  # symlink into /usr/local/bin (override with PREFIX=~/.local)
```

## Good first issue: a Linux port

The one real limitation is that keypop is macOS-only (it uses `osascript` for the dialog). A
Linux port would roughly triple the audience. The clean shape:

- Detect the platform and pick a dialog backend: `zenity` or `kdialog` on Linux, `osascript`
  on macOS.
- The backend only has to do two things: a masked text prompt with a Reveal/Hide toggle, and a
  names-only confirmation dialog. Everything else (parsing, vault writes, check-first) is already
  platform-independent.
- Keep it behind a small `ask_masked` / confirm abstraction so the rest of the script doesn't
  branch on OS.

If you pick this up, open an issue first so we can agree on the backend detection before you build.
