# Security model

keypop touches your credentials, so it should be honest about exactly what it does and does
not protect. Read this before trusting it with anything real.

## What keypop is for

Keeping secret **values out of an AI agent's context**. When a coding agent needs a credential,
the naive move is to paste it into chat — where it lands in the transcript, the model's context
window, and your LLM provider's logs. keypop closes that path: the agent asks for a secret by
name, a native macOS dialog collects the value out-of-band, and the value is written straight to
a local file. The agent only ever sees the name and a character count.

That is the whole threat it addresses. It is a personal, single-machine dev tool.

## What it protects against

- **Secrets entering the model's context / transcript / provider logs.** The value is typed into
  an OS dialog, never into the conversation. The agent receives only `NAME (N chars)`.
- **Secrets in shell history.** `--paste` and `--import` never put the value on a command line.
- **Accidental commits.** The default vault lives at `~/.keypop/vault.env`, outside every repo,
  `chmod 600`, in a `chmod 700` directory.

## What it does NOT do (limits, be clear-eyed)

- **No encryption at rest.** The vault is a plaintext `KEY=value` file, exactly like a `.env`.
  Its only protection is filesystem permissions. Anyone who can read the file (a process running
  as your user, a backup, a synced folder, an attacker with disk access) can read every secret.
  keypop is *not* a substitute for an encrypted secrets manager.
- **No process isolation.** Any program running as your user can read the vault. There is no
  per-secret access control.
- **Not a team / production secrets manager.** For shared or production credentials use a real
  system (HashiCorp Vault, 1Password, AWS/GCP KMS, Doppler, Infisical). keypop is for one
  developer's laptop.
- **The macOS Keychain is not used, by design.** keypop deliberately stores a dumb, greppable,
  `source`-able file. If you want Keychain-backed storage, `envchain` is a better fit.
- **Clipboard residue is out of scope.** If you copy a key from a clipboard manager, that manager
  may retain it. keypop can't clear your clipboard.

## One disclosure worth knowing: the Reveal toggle and `argv`

On the *simple* path (open dialog, paste, Save), the value is returned from `osascript` on
stdout and never appears on any command line.

If you use the **Reveal / Hide toggle**, the value you have typed is passed *back into* the next
`osascript` invocation as an argument (so the field can re-open pre-filled with what you typed).
For that brief moment, the value is present in the argument list of the `osascript` process,
which is visible to other processes running **as the same user** (e.g. via `ps`). This is
same-user, momentary, and local — but if that matters in your threat model, don't use Reveal;
Save the value blind and verify it afterward with the `N chars` count.

## Reporting a vulnerability

Open a GitHub issue for non-sensitive reports. For anything you'd rather not disclose publicly,
email the maintainer listed on the GitHub profile. There is no formal SLA — this is a small
open-source tool maintained on a best-effort basis.
