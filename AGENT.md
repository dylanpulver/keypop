# Agent doctrine — paste into your agent's instructions

Copy this into your `CLAUDE.md`, system prompt, or rules file so the agent uses keypop
instead of asking for secret values in chat. Adjust the path if you set a custom `VAULT_FILE`.

---

## Secrets — the vault (`~/.keypop/vault.env`)

The vault is the source of truth for credentials (`chmod 600`, outside all repos). "I gave you
that key already" means it should be there.

**Intake — the popup, fired automatically.** The moment you need a credential, run keypop with
every name you need. keypop checks the vault itself: names it already has are skipped silently
(reported as "already set"), and a dialog pops only for the ones that are missing. So you never
have to grep first, and re-running is safe.

```bash
keypop 'NAME_ONE:why it is needed' 'NAME_TWO:note'
```

One native dialog per missing secret pops on my screen showing the name + note (masked •••
input). I paste, hit Enter, done; "Reveal" unmasks to check the paste, blank + Save skips one,
"Cancel all" stops the rest. keypop writes straight to the vault and prints only names + char
counts. To rotate a key I already have, add `--force`. **Never ask for a secret value in
chat** — ask via the popup; in chat just say what you popped and why. Batch all needed names
into ONE invocation.

**If a credential ever appears directly in chat** (I pasted it): vault it immediately, confirm
with the name only, and note that chat-pasted values land in transcript history (mildly
rotation-worthy). Next time, remind me to let the popup collect it instead.

**Never** echo secret values back, and never write them into instructions files, memory,
commit messages, or committed code. If the current project needs a key at runtime, also write
it to the project's gitignored `.env`.
