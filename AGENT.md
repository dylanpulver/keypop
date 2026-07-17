# Agent doctrine — paste into your agent's instructions

Copy this into your `CLAUDE.md`, system prompt, or rules file so the agent uses keypop
instead of asking for secret values in chat. Adjust the path if you set a custom `VAULT_FILE`.

---

## Secrets — the vault (`~/.keypop/vault.env`)

The vault is the source of truth for credentials (`chmod 600`, outside all repos). **Before
ever asking me for a credential, check it first** (`grep -i <service> ~/.keypop/vault.env`).
"I gave you that key already" means it should be there.

**Intake — the popup, fired automatically.** The moment you need a credential that isn't in
the vault — mid-task, no need for me to ask — run:

```bash
keypop 'NAME_ONE:why it is needed' 'NAME_TWO:note'
```

One native dialog per secret pops on my screen showing the name + note (hidden ••• input). I
paste, hit Enter, done; "Skip" skips one, "Cancel all" stops the rest. The script writes
straight to the vault and prints only names + char counts. **Never ask for a secret value in
chat** — ask via the popup; in chat just say what you popped and why. Batch all needed names
into ONE invocation.

**If a credential ever appears directly in chat** (I pasted it): vault it immediately, confirm
with the name only, and note that chat-pasted values land in transcript history (mildly
rotation-worthy). Next time, remind me to let the popup collect it instead.

**Never** echo secret values back, and never write them into instructions files, memory,
commit messages, or committed code. If the current project needs a key at runtime, also write
it to the project's gitignored `.env`.
